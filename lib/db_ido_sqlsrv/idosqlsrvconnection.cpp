/******************************************************************************
 * Icinga 2                                                                   *
 * Copyright (C) 2012-2015 Icinga Development Team (http://www.icinga.org)    *
 *                                                                            *
 * This program is free software; you can redistribute it and/or              *
 * modify it under the terms of the GNU General Public License                *
 * as published by the Free Software Foundation; either version 2             *
 * of the License, or (at your option) any later version.                     *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program; if not, write to the Free Software Foundation     *
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ******************************************************************************/

#include "db_ido_sqlsrv/idosqlsrvconnection.hpp"
#include "db_ido_sqlsrv/idosqlsrvconnection.tcpp"
#include "db_ido/dbtype.hpp"
#include "db_ido/dbvalue.hpp"
#include "icinga/perfdatavalue.hpp"
#include "icinga/perfdatavalue.tcpp"
#include "base/logger.hpp"
#include "base/objectlock.hpp"
#include "base/convert.hpp"
#include "base/utility.hpp"
#include "base/application.hpp"
#include "base/dynamictype.hpp"
#include "base/exception.hpp"
#include "base/statsfunction.hpp"
#include <boost/tuple/tuple.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/foreach.hpp>

using namespace icinga;

REGISTER_TYPE(IdoSqlsrvConnection);
REGISTER_STATSFUNCTION(IdoSqlsrvConnectionStats, &IdoSqlsrvConnection::StatsFunc);

/**
 * @def	ALIGNSIZE
 *
 * @brief	Alignment size of 4 bytes. See https://msdn.microsoft.com/en-us/library/ms710118%28v=vs.85%29.aspx
 */
#define ALIGNSIZE 4

/**
 * @fn	static size_t ALIGNBUF(size_t length)
 *
 * @brief	Define a macro to increase the size of a buffer so that it is a multiple of the alignment size. Thus, if a
 * 			buffer starts on an alignment boundary, it will end just before the next alignment boundary.
 * 			See https://msdn.microsoft.com/en-us/library/ms710118%28v=vs.85%29.aspx
 *
 * @param	length	The length.
 *
 * @return	A size_t.
 */

static size_t ALIGNBUF(size_t length)
{
	size_t res = length % ALIGNSIZE ? \
		length + ALIGNSIZE - (length % ALIGNSIZE) : length;
	VERIFY(res >= length);
	return res;
}

/**
 * @def	CHECK_ODBC_ERROR(rc, h, ht)
 *
 * @brief	A macro that to use after an ODBC call to check that the call was successful and log an error if not.
 * 			if the result is SQL_INVALID_HANDLE an exception is thrown.
 * 			In all other cases, it is down to the application to decide on how to handle the error.
 *
 * @param	rc 	SQLReturn Code.
 * @param	h 	A ODBC connection or environment handle.
 * @param	ht	The ODBC handle type.
 *
 */
#define CHECK_ODBC_ERROR(rc, h, ht)   {   \
	if (!SQL_SUCCEEDED(rc)) { \
		if (rc == SQL_INVALID_HANDLE) { \
			Log(LogCritical, "IdoSqlsrvConnection", "Return code is invalid database handle!"); \
			BOOST_THROW_EXCEPTION(std::runtime_error("Invalid SQL Handle")); \
		} else { \
			InternalDumpErrors(ht, h); \
		} \
	} \
	if (rc == SQL_ERROR) { \
		Log(LogCritical, "IdoSqlsrvConnection", "Error executing ODBC Call: Verify that your database is operational!"); \
	}  \
}

/**
 * @fn	IdoSqlsrvConnection::IdoSqlsrvConnection(void)
 *
 * @brief	Default constructor. Sets initial Query queue size.
 */
IdoSqlsrvConnection::IdoSqlsrvConnection(void)
	: m_QueryQueue(500000) // ask shroud should the 500,000 be a #define in db_ido/dbconnection.hpp for mysql/pgsql/sqlsrv?
{ }

/**
 * @fn	void IdoSqlsrvConnection::StatsFunc(const Dictionary::Ptr& status, const Array::Ptr& perfdata)
 *
 * @brief	Statistics function. Returns status for the database connection which is currently schema version,
 * 			instance_name of the instance, and query_queue_items i.e. the number of outstanding queries.
 *
 * @param	status  	The status.
 * @param	perfdata	The perfdata.
 */
void IdoSqlsrvConnection::StatsFunc(const Dictionary::Ptr& status, const Array::Ptr& perfdata)
{
	Dictionary::Ptr nodes = new Dictionary();

	BOOST_FOREACH(const IdoSqlsrvConnection::Ptr& idosqlsrvconnection, DynamicType::GetObjectsByType<IdoSqlsrvConnection>()) {
		size_t items = idosqlsrvconnection->m_QueryQueue.GetLength();

		Dictionary::Ptr stats = new Dictionary();
		stats->Set("version", idosqlsrvconnection->GetSchemaVersion());
		stats->Set("instance_name", idosqlsrvconnection->GetInstanceName());
		stats->Set("query_queue_items", items);

		nodes->Set(idosqlsrvconnection->GetName(), stats);

		perfdata->Add(new PerfdataValue("idosqlsrvconnection_" + idosqlsrvconnection->GetName() + "_query_queue_items", items));
	}

	status->Set("idosqlsrvconnection", nodes);
}

/**
 * @fn	void IdoSqlsrvConnection::Resume(void)
 *
 * @brief	Resumes the database connection.
 */
void IdoSqlsrvConnection::Resume(void)
{
	DbConnection::Resume();

	SetConnected(false); // ask shroud - surely this shouldn't be needed here as to resume, we'd never to be paused and pause should be disconnecting ?

	m_QueryQueue.SetExceptionCallback(boost::bind(&IdoSqlsrvConnection::ExceptionHandler, this, _1));

	m_TxTimer = new Timer();
	m_TxTimer->SetInterval(1);
	m_TxTimer->OnTimerExpired.connect(boost::bind(&IdoSqlsrvConnection::TxTimerHandler, this));
	m_TxTimer->Start();

	m_ReconnectTimer = new Timer();
	m_ReconnectTimer->SetInterval(10);
	m_ReconnectTimer->OnTimerExpired.connect(boost::bind(&IdoSqlsrvConnection::ReconnectTimerHandler, this));
	m_ReconnectTimer->Start();
	m_ReconnectTimer->Reschedule(0);
}

/**
 * @fn	void IdoSqlsrvConnection::Pause(void)
 *
 * @brief	Pauses the database connection. This queues a disconnect and flushes the database connection.
 */
void IdoSqlsrvConnection::Pause(void)
{
	m_ReconnectTimer.reset();

	DbConnection::Pause();

	m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::Disconnect, this));
	m_QueryQueue.Join();
}

/**
 * @fn	void IdoSqlsrvConnection::ExceptionHandler(boost::exception_ptr exp)
 *
 * @brief	Exception Handler, called when an exception occurs within the database layer.
 *
 * @param	exp	The exception.
 */
void IdoSqlsrvConnection::ExceptionHandler(boost::exception_ptr exp)
{
	Log(LogCritical, "IdoSqlsrvConnection", "Exception during database operation: Verify that your database is operational!");

	Log(LogDebug, "IdoSqlsrvConnection")
	    << "Exception during database operation: " << DiagnosticInformation(exp);

	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if (GetConnected()) {
		InternalDisconnect();
	}
}

/**
 * @fn	void IdoSqlsrvConnection::AssertOnWorkQueue(void)
 *
 * @brief	Assert on work queue.
 */
void IdoSqlsrvConnection::AssertOnWorkQueue(void)
{
	ASSERT(m_QueryQueue.IsWorkerThread());
}

/**ably 
 * @fn	void IdoSqlsrvConnection::Disconnect(void)
 *
 * @brief	Disconnects this object. We commit any outstanding transactions then close the connection.
 */
void IdoSqlsrvConnection::Disconnect(void)
{
	AssertOnWorkQueue();

	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if (!GetConnected())
		return;

	SQLRETURN rc = SQLEndTran(SQL_HANDLE_DBC, m_Connection, SQL_COMMIT);
	CHECK_ODBC_ERROR(rc, m_Connection, SQL_HANDLE_DBC);

	InternalDisconnect();

}

/**
 * @fn	void IdoSqlsrvConnection::TxTimerHandler(void)
 *
 * @brief	Handler, called to commit outstanding transactions
 */
void IdoSqlsrvConnection::TxTimerHandler(void)
{
	NewTransaction();
}

/**
 * @fn	void IdoSqlsrvConnection::NewTransaction(void)
 *
 * @brief	Creates a new transaction.
 */
void IdoSqlsrvConnection::NewTransaction(void)
{
	m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::InternalNewTransaction, this));
}

/**
 * @fn	void IdoSqlsrvConnection::InternalNewTransaction(void)
 *
 * @brief	Internal new transaction. The ODBC connection is not in autocommit mode, so we call SQLEndTran to COMMIT
 * 			any outstanding sql connections.
 */
void IdoSqlsrvConnection::InternalNewTransaction(void)
{
	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if (!GetConnected())
		return;
	
	SQLRETURN rc = SQLEndTran(SQL_HANDLE_DBC, m_Connection, SQL_COMMIT);	// ask shroud - does this meanwe have a 1second lock on the DB - aka time between SQLEndTrans - if so, how to test/optimise ?
	CHECK_ODBC_ERROR(rc, m_Connection, SQL_HANDLE_DBC);
}

/**
 * @fn	void IdoSqlsrvConnection::ReconnectTimerHandler(void)
 *
 * @brief	Handler, called by the reconnect timer to test the connection and reconnect if necessary.
 */
void IdoSqlsrvConnection::ReconnectTimerHandler(void)
{
	m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::Reconnect, this));
}

/**
 * @fn	void IdoSqlsrvConnection::Reconnect(void)
 *
 * @brief	Reconnects the database connection if necessary. We test the current connection status, 
 * 			check the schema version then update the database/icinga state as part of the reconnection process.
 */
void IdoSqlsrvConnection::Reconnect(void)
{
	AssertOnWorkQueue();

	Log(LogNotice, "IdoSqlsrvConnection", "Calling Reconnect...");

	CONTEXT("Reconnecting to SQL Server IDO database '" + GetName() + "'");

	SQLRETURN rc;

	SetShouldConnect(true);

	std::vector<DbObject::Ptr> active_dbobjs;

	{
		boost::mutex::scoped_lock lock(m_ConnectionMutex);

		bool reconnect = false;

		if (GetConnected()) {
			/* execute a simple query and catch any exceptions to check connection status */
			try {
				Query("SELECT 1");
				return;
			}
			catch (const std::exception&) {
				InternalDisconnect();
				reconnect = true;
			}
		}

		ClearIDCache();

		String connection_string;

		connection_string = GetConnectionString();

		/* connection */
		rc = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &m_environment);
		CHECK_ODBC_ERROR(rc, SQL_NULL_HANDLE, SQL_HANDLE_ENV);

		rc = SQLSetEnvAttr(m_environment, SQL_ATTR_ODBC_VERSION, (SQLPOINTER)SQL_OV_ODBC3, 0);
		CHECK_ODBC_ERROR(rc, m_environment, SQL_HANDLE_ENV);

		rc = SQLAllocHandle(SQL_HANDLE_DBC, m_environment, &m_Connection);
		CHECK_ODBC_ERROR(rc, m_environment, SQL_HANDLE_ENV);

		/* set autocommit on the sql connection to OFF */
		rc = SQLSetConnectAttr(m_Connection, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER)SQL_AUTOCOMMIT_OFF, SQL_IS_INTEGER);
		CHECK_ODBC_ERROR(rc, m_Connection, SQL_HANDLE_DBC);

		rc = SQLDriverConnect(m_Connection, NULL, (SQLTCHAR *)connection_string.CStr(), SQL_NTS, NULL, 0, NULL, SQL_DRIVER_NOPROMPT);
		if (!SQL_SUCCEEDED(rc)) {
			Log(LogCritical, "IdoSqlsrvConnection")
				<< "sqlsrv connection failed: \"" << InternalDumpErrors(SQL_HANDLE_DBC, m_Connection) << "\"";

			BOOST_THROW_EXCEPTION(std::runtime_error("SQLSrv Connection Failed"));
		}

		SetConnected(true);

		String dbVersionName = "idoutils";
		IdoSqlsrvResult result = Query("SELECT version FROM " + GetTablePrefix() + "dbversion WHERE name='" + Escape(dbVersionName) + "'");

		Dictionary::Ptr row = FetchRow(result);

		if (!row) {
			/* todo - close connection */
			Log(LogCritical, "IdoSqlsrvConnection", "Schema does not provide any valid version! Verify your schema installation.");
			
			Application::Exit(EXIT_FAILURE);
		}

		DiscardRows(result);

		String version = row->Get("version");

		SetSchemaVersion(version);

		if (Utility::CompareVersion(IDO_CURRENT_SCHEMA_VERSION, version) < 0) {
			/* todo - close connection */
			Log(LogCritical, "IdoSqlsrvConnection")
			    << "Schema version '" << version << "' does not match the required version '"
				<< IDO_CURRENT_SCHEMA_VERSION  << "'! Please check the upgrade documentation.";

			Application::Exit(EXIT_FAILURE);
		}

		String instanceName = GetInstanceName();

		result = Query("SELECT instance_id FROM " + GetTablePrefix() + "instances WHERE instance_name = '" + Escape(instanceName) + "'");
		row = FetchRow(result);

		if (!row) {
			Query("INSERT INTO " + GetTablePrefix() + "instances (instance_name, instance_description) VALUES ('" + Escape(instanceName) + "', '" + Escape(GetInstanceDescription()) + "')");
			m_InstanceID = GetLastInsertID(GetTablePrefix() + "instances");
		} else {
			m_InstanceID = DbReference(row->Get("instance_id"));
		}

		DiscardRows(result);

		Endpoint::Ptr my_endpoint = Endpoint::GetLocalEndpoint();

		/* we have an endpoint in a cluster setup, so decide if we can proceed here */
		if (my_endpoint && GetHAMode() == HARunOnce) {
			/* get the current endpoint writing to programstatus table */
			result = Query("SELECT UNIX_TIMESTAMP(status_update_time) AS status_update_time, endpoint_name FROM " +
			    GetTablePrefix() + "programstatus WHERE instance_id = " + Convert::ToString(m_InstanceID));
			row = FetchRow(result);
			DiscardRows(result);

			String endpoint_name;

			if (row)
				endpoint_name = row->Get("endpoint_name");
			else
				Log(LogNotice, "IdoSqlsrvConnection", "Empty program status table");

			/* if we did not write into the database earlier, another instance is active */
			if (endpoint_name != my_endpoint->GetName()) {
				double status_update_time;

				if (row)
					status_update_time = row->Get("status_update_time");
				else
					status_update_time = 0;

				double status_update_age = Utility::GetTime() - status_update_time;

				Log(LogNotice, "IdoSqlsrvConnection")
				    << "Last update by '" << endpoint_name << "' was " << status_update_age << "s ago.";

				if (status_update_age < GetFailoverTimeout()) {
					InternalDisconnect();

					SetShouldConnect(false);

					return;
				}

				/* activate the IDO only, if we're authoritative in this zone */
				if (IsPaused()) {
					Log(LogNotice, "IdoSqlsrvConnection")
					    << "Local endpoint '" << my_endpoint->GetName() << "' is not authoritative, bailing out.";

					InternalDisconnect();

					return;
				}
			}

			Log(LogNotice, "IdoSqlsrvConnection", "Enabling IDO connection.");
		}

		Log(LogInformation, "IdoSqlsrvConnection")
		    << "SQLsrv IDO instance id: " << static_cast<long>(m_InstanceID) << " (schema version: '" + version + "')";

		/* record connection */
		Query("INSERT INTO " + GetTablePrefix() + "conninfo " +
		    "(instance_id, connect_time, last_checkin_time, agent_name, agent_version, connect_type, data_start_time) VALUES ("
		    + Convert::ToString(static_cast<long>(m_InstanceID)) + ", GETUTCDATE(), GETUTCDATE(), 'icinga2 db_ido_sqlsrv', '" + Escape(Application::GetVersion())
		    + "', '" + (reconnect ? "RECONNECT" : "INITIAL") + "', GETUTCDATE())");
		
		/* clear config tables for the initial config dump */
		PrepareDatabase();

		std::ostringstream q1buf;
		q1buf << "SELECT object_id, objecttype_id, name1, name2, is_active FROM " + GetTablePrefix() + "objects WHERE instance_id = " << static_cast<long>(m_InstanceID);
		result = Query(q1buf.str());

		while ((row = FetchRow(result))) {
			DbType::Ptr dbtype = DbType::GetByID(row->Get("objecttype_id"));

			if (!dbtype)
				continue;

			DbObject::Ptr dbobj = dbtype->GetOrCreateObjectByName(row->Get("name1"), row->Get("name2"));
			SetObjectID(dbobj, DbReference(row->Get("object_id")));
			SetObjectActive(dbobj, row->Get("is_active"));

			if (GetObjectActive(dbobj))
				active_dbobjs.push_back(dbobj);
		}
	}

	UpdateAllObjects();

	/* deactivate all deleted configuration objects */
	BOOST_FOREACH(const DbObject::Ptr& dbobj, active_dbobjs) {
		if (dbobj->GetObject() == NULL) {
			Log(LogNotice, "IdoSqlsrvConnection")
			    << "Deactivate deleted object name1: '" << dbobj->GetName1()
			    << "' name2: '" << dbobj->GetName2() + "'.";
			DeactivateObject(dbobj);
		}
	}
}

/**
 * @fn	void IdoSqlsrvConnection::ClearConfigTable(const String& table)
 *
 * @brief	Clears the database configuration in the table described by table for the current instance.
 *
 * @param	table	The table.
 */
void IdoSqlsrvConnection::ClearConfigTable(const String& table)
{
	Query("DELETE FROM " + GetTablePrefix() + table + " WHERE instance_id = " + Convert::ToString(static_cast<long>(m_InstanceID)));
}

/**
 * @fn	IdoSqlsrvResult IdoSqlsrvConnection::Query(const String& query)
 *
 * @brief	Executes the given query.
 *
 * @param	query	The query.
 *
 * @return	An IdoSqlsrvResult.
 */
IdoSqlsrvResult IdoSqlsrvConnection::Query(const String& query)
{
	AssertOnWorkQueue();

	Log(LogDebug, "IdoSqlsrvConnection")
	    << "Query: " << query;

	IncreaseQueryCount();

	SQLHSTMT h_statement;
	SQLRETURN rc;

	rc = SQLAllocHandle(SQL_HANDLE_STMT, m_Connection, (SQLHANDLE *)&h_statement);
	CHECK_ODBC_ERROR(rc, h_statement, SQL_HANDLE_STMT);

	rc = SQLExecDirect(h_statement, (SQLCHAR *)query.CStr(), SQL_NTS);
	CHECK_ODBC_ERROR(rc, h_statement, SQL_HANDLE_STMT);

	if (!SQL_SUCCEEDED(rc) && rc != SQL_NO_DATA) {
		std::ostringstream msgbuf;
		String message = InternalDumpErrors(SQL_HANDLE_STMT, h_statement);
		msgbuf << "Error \"" << message << "\" when executing query \"" << query << "\"";
		Log(LogCritical, "IdoSqlsrvConnection", msgbuf.str());

		BOOST_THROW_EXCEPTION(
		    database_error()
			<< errinfo_message(message)
			<< errinfo_database_query(query)
		);
	}

	SQLRowCount(h_statement, &m_AffectedRows);

	SQLHSTMT *p_statement = new SQLHSTMT;
	*p_statement = h_statement;
	return IdoSqlsrvResult(p_statement, IdoSqlsrvConnection::CloseCursor);
}

/**
 * @fn	void IdoSqlsrvConnection::CloseCursor(SQLHSTMT *phandle)
 *
 * @brief	Closes the cursor associated with SQLHSTMT Statement Handle (if one was defined)
 * 			and discards all pending results.
 *
 * @param [in,out]	phandle	If non-null, the phandle.
 */
void IdoSqlsrvConnection::CloseCursor(SQLHSTMT *phandle)
{
	SQLRETURN rc = SQLFreeStmt(*phandle, SQL_CLOSE);
	if (!SQL_SUCCEEDED(rc)) {
		Log(LogNotice, "IdoSqlsrvConnection", "Unable to free odbc statement handle");
	}

	delete phandle;
}

/**
 * @fn	DbReference IdoSqlsrvConnection::GetLastInsertID(const String& table)
 *
 * @brief	Gets the last insert identifier for a given table.
 *
 * @param	table	The table.
 *
 * @return	The last insert identifier.
 */
DbReference IdoSqlsrvConnection::GetLastInsertID(const String& table)
{
	AssertOnWorkQueue();

	IdoSqlsrvResult result = Query("SELECT IDENT_CURRENT('" + Escape(table) + "') AS id");

	Dictionary::Ptr row = FetchRow(result);

	ASSERT(row);

	Log(LogDebug, "IdoSqlsrvConnection")
	    << "Sequence Value: " << row->Get("id");

	return DbReference(Convert::ToLong(row->Get("id")));
}

/**
 * @fn	int IdoSqlsrvConnection::GetAffectedRows(void)
 *
 * @brief	Gets affected rows.
 *
 * @return	The affected rows.
 */
int IdoSqlsrvConnection::GetAffectedRows(void)
{
	AssertOnWorkQueue();

	return m_AffectedRows;
}

/**
 * @fn	String IdoSqlsrvConnection::Escape(const String& s)
 *
 * @brief	Escapes the given string for use in database queries. ODBC does not have a built-in escape function, so
 * 			we look to do our own. Currently this replaces a single quote with a double quote.
 *
 * @param	s	The const String&amp; to process.
 *
 * @return	A String.
 */
String IdoSqlsrvConnection::Escape(const String& s)
{
	AssertOnWorkQueue();

	String result = s;
	boost::algorithm::replace_all(result, "'", "''");

	return result;
}

/**
 * @fn	SQLSMALLINT IdoSqlsrvConnection::GetDefaultCType(SQLINTEGER sqltype)
 *
 * @brief	Gets default C type.
 *
 * @param	sqltype	The sqltype.
 *
 * @return	The default C type.
 */
SQLSMALLINT IdoSqlsrvConnection::GetDefaultCType(SQLINTEGER sqltype)
{
	switch (sqltype) {
		case SQL_SMALLINT:
		case SQL_INTEGER:
		case SQL_NUMERIC:
			return SQL_C_LONG;
		case SQL_REAL:
		case SQL_FLOAT:
		case SQL_DOUBLE:
			return SQL_C_DOUBLE;

		default:
			return SQL_C_CHAR;
	}
}

/**
 * @fn	Dictionary::Ptr IdoSqlsrvConnection::FetchRow(const IdoSqlsrvResult& result)
 *
 * @brief	Fetches a row. We convert the ODBC result to a Dictionary, and handle type conversions.
 * 			This function is based on example code at https://msdn.microsoft.com/en-us/library/ms710118(v=vs.85).aspx 
 *
 * @param	result	An IdoSqlsrvResult result.
 *
 * @return	The row.
 */
Dictionary::Ptr IdoSqlsrvConnection::FetchRow(const IdoSqlsrvResult& result)
{
	AssertOnWorkQueue();

	SQLSMALLINT columns;
	SQLNumResultCols(*result.get(), &columns); /* how many columns do we have ? */

	if (!columns)
		return Dictionary::Ptr();

	SQLSMALLINT *CTypeArray = new SQLSMALLINT[columns];
	SQLINTEGER *ColLenArray = new SQLINTEGER[columns];
	SQLINTEGER *OffsetArray = new SQLINTEGER[columns];

	OffsetArray[0] = 0;

	for (int column = 0; column < columns; column++) {
		SQLINTEGER SQLType;
		SQLColAttribute(*result.get(), ((SQLUSMALLINT)column) + 1, SQL_DESC_TYPE, NULL, 0, NULL, (SQLPOINTER)&SQLType);
		CTypeArray[column] = GetDefaultCType(SQLType);

		SQLColAttribute(*result.get(), ((SQLUSMALLINT)column) + 1, SQL_DESC_OCTET_LENGTH, NULL, 0, NULL, &ColLenArray[column]);
		ColLenArray[column] = ALIGNBUF(ColLenArray[column]);
		if (column)
			OffsetArray[column] = OffsetArray[column - 1] + ColLenArray[column - 1] + ALIGNBUF(sizeof(SQLINTEGER));
	}

	size_t len = OffsetArray[columns - 1] +
		ColLenArray[columns - 1] + ALIGNBUF(sizeof(SQLINTEGER));
	char *DataPtr = new char [len];

	SQLRETURN rc;

	for (int column = 0; column < columns; column++) {
		rc = SQLBindCol(*result.get(),
			column + 1,
			CTypeArray[column],
			(SQLPOINTER)((SQLCHAR *)DataPtr + OffsetArray[column]),
			ColLenArray[column],
			(SQLINTEGER *)((SQLCHAR *)DataPtr + OffsetArray[column] + ColLenArray[column]));
		CHECK_ODBC_ERROR(rc, *result.get(), SQL_HANDLE_STMT);

	}

	rc = SQLFetch(*result.get());
	CHECK_ODBC_ERROR(rc, *result.get(), SQL_HANDLE_STMT);

	if (rc == SQL_NO_DATA)
		return Dictionary::Ptr();

	Dictionary::Ptr dict = new Dictionary();

	for (int column = 0; column < columns; column++) {
		SQLCHAR column_name[128 + 1];
		SQLSMALLINT column_name_length;
		SQLSMALLINT data_type;
		SQLUINTEGER column_size;
		SQLSMALLINT decimal_digits;
		SQLSMALLINT nullable;

		rc = SQLDescribeCol(
			*result.get(),                /* handle of stmt */
			column + 1,                   /* Column number */
			column_name,                  /* where to put Column name */
			sizeof(column_name),          /* = 128+1 ... allow for \0 */
			&column_name_length,          /* where to put name length */
			&data_type,                   /* where to put <data type> */
			&column_size,                 /* where to put Column size */
			&decimal_digits,              /* where to put scale/frac precision */
			&nullable);                   /* where to put null/not-null flag */

		CHECK_ODBC_ERROR(rc, *result.get(), SQL_HANDLE_STMT);

		Value value;

		char *columnData = (char *)DataPtr + OffsetArray[column];
		SQLINTEGER ind = *(SQLINTEGER *)(columnData + ColLenArray[column]);

		if (ind != SQL_NULL_DATA) {
			switch (CTypeArray[column]) {
				case SQL_C_CHAR:
					value = String(columnData, columnData + ind);
					break;
				case SQL_C_LONG:
					value = *(long *)columnData;
					break;
				case SQL_C_DOUBLE:
					value = *(double *)columnData;
					break;
			}
		}

		dict->Set((char *)column_name, value);
	}

	delete [] DataPtr;
	delete [] CTypeArray;
	delete [] ColLenArray;
	delete [] OffsetArray;

	return dict;
}

/**
 * @fn	void IdoSqlsrvConnection::DiscardRows(const IdoSqlsrvResult& result)
 *
 * @brief	Discard rows.
 *
 * @param	result	The result.
 */
void IdoSqlsrvConnection::DiscardRows(const IdoSqlsrvResult& result)
{
	Dictionary::Ptr row;

	while ((row = FetchRow(result)))
		; /* empty loop body */
}

/**
 * @fn	void IdoSqlsrvConnection::ActivateObject(const DbObject::Ptr& dbobj)
 *
 * @brief	Activates the object described by dbobj.
 *
 * @param	dbobj	The dbobj.
 */
void IdoSqlsrvConnection::ActivateObject(const DbObject::Ptr& dbobj)
{
	boost::mutex::scoped_lock lock(m_ConnectionMutex);
	InternalActivateObject(dbobj);
}

/**
 * @fn	void IdoSqlsrvConnection::InternalActivateObject(const DbObject::Ptr& dbobj)
 *
 * @brief	Internal activate object.
 *
 * @param	dbobj	The dbobj.
 */
void IdoSqlsrvConnection::InternalActivateObject(const DbObject::Ptr& dbobj)
{
	if (!GetConnected())
		return;

	DbReference dbref = GetObjectID(dbobj);
	std::ostringstream qbuf;

	if (!dbref.IsValid()) {
		if (!dbobj->GetName2().IsEmpty()) {
			qbuf << "INSERT INTO " + GetTablePrefix() + "objects (instance_id, objecttype_id, name1, name2, is_active) VALUES ("
			     << static_cast<long>(m_InstanceID) << ", " << dbobj->GetType()->GetTypeID() << ", "
			     << "'" << Escape(dbobj->GetName1()) << "', '" << Escape(dbobj->GetName2()) << "', 1)";
		} else {
			qbuf << "INSERT INTO " + GetTablePrefix() + "objects (instance_id, objecttype_id, name1, is_active) VALUES ("
			     << static_cast<long>(m_InstanceID) << ", " << dbobj->GetType()->GetTypeID() << ", "
			     << "'" << Escape(dbobj->GetName1()) << "', 1)";
		}

		Query(qbuf.str());
		SetObjectID(dbobj, GetLastInsertID(GetTablePrefix() + "objects"));
	} else {
		qbuf << "UPDATE " + GetTablePrefix() + "objects SET is_active = 1 WHERE object_id = " << static_cast<long>(dbref);
		Query(qbuf.str());
	}
}

/**
 * @fn	void IdoSqlsrvConnection::DeactivateObject(const DbObject::Ptr& dbobj)
 *
 * @brief	Deactivate object.
 *
 * @param	dbobj	The dbobj.
 */
void IdoSqlsrvConnection::DeactivateObject(const DbObject::Ptr& dbobj)
{
	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if (!GetConnected())
		return;

	DbReference dbref = GetObjectID(dbobj);

	if (!dbref.IsValid())
		return;

	std::ostringstream qbuf;
	qbuf << "UPDATE " + GetTablePrefix() + "objects SET is_active = 0 WHERE object_id = " << static_cast<long>(dbref);
	Query(qbuf.str());

	/* Note that we're _NOT_ clearing the db refs via SetReference/SetConfigUpdate/SetStatusUpdate
	 * because the object is still in the database. */
}

/**
 * @fn	bool IdoSqlsrvConnection::FieldToEscapedString(const String& key, const Value& value, Value *result)
 *
 * @brief	Field to escaped string. Converts timestamp values within icinga appropriately for the database.
 * 			caller must hold m_ConnectionMutex
 *
 * @param	key		  	The key.
 * @param	value	  	The value.
 * @param [out]	result	If non-null, the result.
 *
 * @return	true if it succeeds, false if it fails.
 */
bool IdoSqlsrvConnection::FieldToEscapedString(const String& key, const Value& value, Value *result)
{
	if (key == "instance_id") {
		*result = static_cast<long>(m_InstanceID);
		return true;
	}
	if (key == "notification_id") {
		*result = static_cast<long>(GetNotificationInsertID(value));
		return true;
	}

	Value rawvalue = DbValue::ExtractValue(value);

	if (rawvalue.IsObjectType<DynamicObject>()) {
		DbObject::Ptr dbobjcol = DbObject::GetOrCreateByObject(rawvalue);

		if (!dbobjcol) {
			*result = 0;
			return true;
		}

		DbReference dbrefcol;

		if (DbValue::IsObjectInsertID(value)) {
			dbrefcol = GetInsertID(dbobjcol);

			if (!dbrefcol.IsValid())
				return false;
		} else {
			dbrefcol = GetObjectID(dbobjcol);

			if (!dbrefcol.IsValid()) {
				InternalActivateObject(dbobjcol);

				dbrefcol = GetObjectID(dbobjcol);

				if (!dbrefcol.IsValid())
					return false;
			}
		}

		*result = static_cast<long>(dbrefcol);
	} else if (DbValue::IsTimestamp(value)) {
		long ts = rawvalue;
		std::ostringstream msgbuf;
		msgbuf << "DATEADD(s, " << ts << ", '1/1/1970')";
		*result = Value(msgbuf.str());
	} else if (DbValue::IsTimestampNow(value)) {
		*result = "GETUTCDATE()";
	} else {
		Value fvalue;

		if (rawvalue.IsBoolean())
			fvalue = Convert::ToLong(rawvalue);
		else
			fvalue = rawvalue;

		*result = "'" + Escape(fvalue) + "'";
	}

	return true;
}

/**
 * @fn	void IdoSqlsrvConnection::ExecuteQuery(const DbQuery& query)
 *
 * @brief	Executes the query operation.
 *
 * @param	query	The query.
 */
void IdoSqlsrvConnection::ExecuteQuery(const DbQuery& query)
{
	ASSERT(query.Category != DbCatInvalid);

	m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::InternalExecuteQuery, this, query, (DbQueryType *)NULL), true);
}

/**
 * @fn	String IdoSqlsrvConnection::EscapeColumn(const String& column)
 *
 * @brief	Escape column for use in a database query.
 * 			We enclose the column name with brackets as some of the existing columns in icinga use reserved names
 *
 * @param	column	The column.
 *
 * @return	A String.
 */
String IdoSqlsrvConnection::EscapeColumn(const String& column)
{
	return "[" + column + "]";
}

/**
 * @fn	void IdoSqlsrvConnection::InternalExecuteQuery(const DbQuery& query, DbQueryType *typeOverride)
 *
 * @brief	Internal execute query.
 *
 * @param	query					The query.
 * @param [in,out]	typeOverride	If non-null, the type override.
 */
void IdoSqlsrvConnection::InternalExecuteQuery(const DbQuery& query, DbQueryType *typeOverride)
{
	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if ((query.Category & GetCategories()) == 0)
		return;

	if (!GetConnected())
		return;

	if (query.Object && query.Object->GetObject()->GetExtension("agent_check").ToBool())
		return;

	std::ostringstream qbuf, where;
	int type;

	if (query.WhereCriteria) {
		where << " WHERE ";

		ObjectLock olock(query.WhereCriteria);
		Value value;
		bool first = true;

		BOOST_FOREACH(const Dictionary::Pair& kv, query.WhereCriteria) {
			if (!FieldToEscapedString(kv.first, kv.second, &value)) {
				m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::InternalExecuteQuery, this, query, (DbQueryType *)NULL)); // ??? todo remove or leave?
				return;
			}

			if (!first)
				where << " AND ";

			where << EscapeColumn(kv.first) << " = " << value;

			if (first)
				first = false;
		}
	}

	type = typeOverride ? *typeOverride : query.Type;

	bool upsert = false;

	if ((type & DbQueryInsert) && (type & DbQueryUpdate)) {
		bool hasid = false;

		ASSERT(query.Object);

		if (query.ConfigUpdate)
			hasid = GetConfigUpdate(query.Object);
		else if (query.StatusUpdate)
			hasid = GetStatusUpdate(query.Object);

		if (!hasid)
			upsert = true;

		type = DbQueryUpdate;
	}

	switch (type) {
		case DbQueryInsert:
			qbuf << "INSERT INTO " << GetTablePrefix() << query.Table;
			break;
		case DbQueryUpdate:
			qbuf << "UPDATE " << GetTablePrefix() << query.Table << " SET";
			break;
		case DbQueryDelete:
			qbuf << "DELETE FROM " << GetTablePrefix() << query.Table;
			break;
		default:
			VERIFY(!"Invalid query type.");
	}

	if (type == DbQueryInsert || type == DbQueryUpdate) {
		std::ostringstream colbuf, valbuf;

		ObjectLock olock(query.Fields);

		bool first = true;
		BOOST_FOREACH(const Dictionary::Pair& kv, query.Fields) {
			Value value;

			if (kv.second.IsEmpty() && !kv.second.IsString())
				continue;

			if (!FieldToEscapedString(kv.first, kv.second, &value))
				return;

			if (type == DbQueryInsert) {
				if (!first) {
					colbuf << ", ";
					valbuf << ", ";
				}

				colbuf << EscapeColumn(kv.first);
				valbuf << value;
			} else {
				if (!first)
					qbuf << ", ";

				qbuf << " " << EscapeColumn(kv.first) << " = " << value;
			}

			if (first)
				first = false;
		}

		if (type == DbQueryInsert)
			qbuf << " (" << colbuf.str() << ") VALUES (" << valbuf.str() << ")";
	}

	if (type != DbQueryInsert)
		qbuf << where.str();

	Query(qbuf.str());

	if (upsert && GetAffectedRows() == 0) {
		lock.unlock();

		DbQueryType to = DbQueryInsert;
		InternalExecuteQuery(query, &to);

		return;
	}

	if (type == DbQueryInsert && query.Object) {
		if (query.ConfigUpdate) {
			SetInsertID(query.Object, GetLastInsertID(GetTablePrefix() + query.Table));
			SetConfigUpdate(query.Object, true);
		} else if (query.StatusUpdate)
			SetStatusUpdate(query.Object, true);
	}

	if (type == DbQueryInsert && query.Table == "notifications" && query.NotificationObject) { // FIXME remove hardcoded table name
		SetNotificationInsertID(query.NotificationObject, GetLastInsertID(GetTablePrefix() + query.Table));
		Log(LogDebug, "IdoSqlsrvConnection")
			<< "saving contactnotification notification_id=" << static_cast<long>(GetLastInsertID(GetTablePrefix() + query.Table));
	}
}

/**
 * @fn	void IdoSqlsrvConnection::CleanUpExecuteQuery(const String& table, const String& time_column, double max_age)
 *
 * @brief	Clean up execute query.
 *
 * @param	table	   	The table.
 * @param	time_column	The time column.
 * @param	max_age	   	The maximum age.
 */
void IdoSqlsrvConnection::CleanUpExecuteQuery(const String& table, const String& time_column, double max_age)
{
	m_QueryQueue.Enqueue(boost::bind(&IdoSqlsrvConnection::InternalCleanUpExecuteQuery, this, table, time_column, max_age), true);
}

/**
 * @fn	void IdoSqlsrvConnection::InternalCleanUpExecuteQuery(const String& table, const String& time_column, double max_age)
 *
 * @brief	Internal clean up execute query.
 *
 * @param	table	   	The table.
 * @param	time_column	The time column.
 * @param	max_age	   	The maximum age.
 */
void IdoSqlsrvConnection::InternalCleanUpExecuteQuery(const String& table, const String& time_column, double max_age)
{
	boost::mutex::scoped_lock lock(m_ConnectionMutex);

	if (!GetConnected())
		return;

	Query("DELETE FROM " + GetTablePrefix() + table + " WHERE instance_id = " +
	    Convert::ToString(static_cast<long>(m_InstanceID)) + " AND " + time_column +
	    " < FROM_UNIXTIME(" + Convert::ToString(static_cast<long>(max_age)) + ")");		// shroud TODO
}

/**
 * @fn	void IdoSqlsrvConnection::FillIDCache(const DbType::Ptr& type)
 *
 * @brief	Fill identifier cache.
 *
 * @param	type	The type.
 */
void IdoSqlsrvConnection::FillIDCache(const DbType::Ptr& type)
{
	String query = "SELECT " + type->GetIDColumn() + " AS object_id, " + type->GetTable() + "_id FROM " + GetTablePrefix() + type->GetTable() + "s";
	IdoSqlsrvResult result = Query(query);

	Dictionary::Ptr row;

	while ((row = FetchRow(result))) {
		SetInsertID(type, DbReference(row->Get("object_id")), DbReference(row->Get(type->GetTable() + "_id")));
	}
}

/**
 * @fn	int IdoSqlsrvConnection::GetPendingQueryCount(void) const
 *
 * @brief	Gets pending query count.
 *
 * @return	The pending query count.
 */
int IdoSqlsrvConnection::GetPendingQueryCount(void) const
{
	return m_QueryQueue.GetLength();
}

/**
 * @fn	void IdoSqlsrvConnection::InternalDisconnect()
 *
 * @brief	Performs the actual disconnection from the sql server
 */
void IdoSqlsrvConnection::InternalDisconnect() {
	SQLRETURN rc;

	rc = SQLDisconnect(m_Connection);
	CHECK_ODBC_ERROR(rc, m_Connection, SQL_HANDLE_DBC);

	rc = SQLFreeHandle(SQL_HANDLE_DBC, m_Connection);
	CHECK_ODBC_ERROR(rc, m_Connection, SQL_HANDLE_DBC);

	rc = SQLFreeHandle(SQL_HANDLE_ENV, m_environment);
	CHECK_ODBC_ERROR(rc, m_environment, SQL_HANDLE_ENV);

	SetConnected(false);
	m_Connection = NULL;
	m_environment = NULL;
}

/**
 * @fn	String IdoSqlsrvConnection::InternalDumpErrors(SQLSMALLINT HandleType, HANDLE Handle)
 *
 * @brief	Dumps the errors.
 *
 * @param	HandleType	Type of the handle.
 * @param	Handle	  	Handle of the handle.
 *
 * @return	A String.
 */
String IdoSqlsrvConnection::InternalDumpErrors(SQLSMALLINT HandleType, HANDLE Handle)
{
	SQLSMALLINT iRec = 0;
	SQLCHAR SQLState[10];
	SQLINTEGER NativeError;
	SQLCHAR MessageText[512];

	std::ostringstream msgbuf;

	if (Handle == SQL_NULL_HANDLE)
		return "";

	while (SQL_SUCCESS == SQLGetDiagRec(
		HandleType,
		Handle,
		++iRec,
		SQLState,
		&NativeError,
		MessageText,
		sizeof(MessageText),
		NULL)) {
		msgbuf << "SQL State: " << SQLState << ", Native Error: " << NativeError << "\nMessage: " << MessageText;
	}

	return msgbuf.str();
}