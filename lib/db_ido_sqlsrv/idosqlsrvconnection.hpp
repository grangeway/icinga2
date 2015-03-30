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

#ifndef IDOSQLSRVCONNECTION_H
#define IDOSQLSRVCONNECTION_H

#define _SQLNCLI_ODBC_

#include "db_ido_sqlsrv/idosqlsrvconnection.thpp"
#include "base/array.hpp"
#include "base/timer.hpp"
#include "base/workqueue.hpp"
#include "sqlncli.h"
#include "sqlext.h"

namespace icinga
{

typedef boost::shared_ptr<SQLHSTMT> IdoSqlsrvResult;

/**
 * An IDO Sqlsrv database connection.
 *
 * @ingroup ido
 */
class IdoSqlsrvConnection : public ObjectImpl<IdoSqlsrvConnection>
{
public:
	DECLARE_OBJECT(IdoSqlsrvConnection);
	DECLARE_OBJECTNAME(IdoSqlsrvConnection);

	IdoSqlsrvConnection(void);

	static void StatsFunc(const Dictionary::Ptr& status, const Array::Ptr& perfdata);

	virtual int GetPendingQueryCount(void) const;

protected:
	virtual void Resume(void);
	virtual void Pause(void);

	virtual void ActivateObject(const DbObject::Ptr& dbobj);
	virtual void DeactivateObject(const DbObject::Ptr& dbobj);
	virtual void ExecuteQuery(const DbQuery& query);
	virtual void CleanUpExecuteQuery(const String& table, const String& time_key, double time_value);
	virtual void FillIDCache(const DbType::Ptr& type);
	virtual void NewTransaction(void);

private:
	DbReference m_InstanceID;

	WorkQueue m_QueryQueue;

	boost::mutex m_ConnectionMutex;
	HENV m_environment;     /* environment handle */
	SQLHANDLE m_Connection; /* connection handle */
	//SQLHANDLE m_Statement;  /* statement handle */
	SQLINTEGER m_AffectedRows;

	Timer::Ptr m_ReconnectTimer;
	Timer::Ptr m_TxTimer;

	IdoSqlsrvResult Query(const String& query);
	DbReference GetLastInsertID(const String& table);
	int GetAffectedRows(void);
	String Escape(const String& s);
	Dictionary::Ptr FetchRow(const IdoSqlsrvResult& result);
	void DiscardRows(const IdoSqlsrvResult& result);

	bool FieldToEscapedString(const String& key, const Value& value, Value *result);
	void InternalActivateObject(const DbObject::Ptr& dbobj);
	static void CloseCursor(SQLHSTMT *phandle);
	static SQLSMALLINT GetDefaultCType(SQLINTEGER sqltype);
	static String EscapeColumn(const String& column);

	void Disconnect(void);
	void Reconnect(void);

	void AssertOnWorkQueue(void);

	void TxTimerHandler(void);
	void ReconnectTimerHandler(void);

	void InternalExecuteQuery(const DbQuery& query, DbQueryType *typeOverride = NULL);
	void InternalCleanUpExecuteQuery(const String& table, const String& time_key, double time_value);
	void InternalNewTransaction(void);
	String InternalDumpErrors(SQLSMALLINT HandleType, HANDLE Handle);
	void InternalDisconnect();

	virtual void ClearConfigTable(const String& table);

	void ExceptionHandler(boost::exception_ptr exp);
};

}

#endif /* IDOSQLSRVCONNECTION_H */
