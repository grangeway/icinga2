/******************************************************************************
 * Icinga 2                                                                   *
 * Copyright (C) 2012-2013 Icinga Development Team (http://www.icinga.org/)   *
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

#include "db_ido/dbtype.h"
#include "db_ido/dbconnection.h"
#include "base/objectlock.h"
#include "base/debug.h"
#include <boost/thread/once.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/foreach.hpp>

using namespace icinga;

DbType::DbType(const String& name, const String& table, long tid, const String& idcolumn, const DbType::ObjectFactory& factory)
	: m_Name(name), m_Table(table), m_TypeID(tid), m_IDColumn(idcolumn), m_ObjectFactory(factory)
{ }

String DbType::GetName(void) const
{
	return m_Name;
}

String DbType::GetTable(void) const
{
	return m_Table;
}

long DbType::GetTypeID(void) const
{
	return m_TypeID;
}

String DbType::GetIDColumn(void) const
{
	return m_IDColumn;
}

void DbType::RegisterType(const DbType::Ptr& type)
{
	boost::mutex::scoped_lock lock(GetStaticMutex());
	GetTypes()[type->GetName()] = type;
}

DbType::Ptr DbType::GetByName(const String& name)
{
	boost::mutex::scoped_lock lock(GetStaticMutex());
	DbType::TypeMap::const_iterator it = GetTypes().find(name);

	if (it == GetTypes().end())
		return DbType::Ptr();

	return it->second;
}

DbType::Ptr DbType::GetByID(long tid)
{
	String name;
	DbType::Ptr type;
	BOOST_FOREACH(boost::tie(name, type), GetTypes()) {
		if (type->GetTypeID() == tid)
			return type;
	}

	return DbType::Ptr();
}

DbObject::Ptr DbType::GetOrCreateObjectByName(const String& name1, const String& name2)
{
	ASSERT(!OwnsLock());

	ObjectLock olock(this);

	DbType::ObjectMap::const_iterator it = m_Objects.find(std::make_pair(name1, name2));

	if (it != m_Objects.end())
		return it->second;

	DbObject::Ptr dbobj = m_ObjectFactory(GetSelf(), name1, name2);
	m_Objects[std::make_pair(name1, name2)] = dbobj;

	return dbobj;
}

boost::mutex& DbType::GetStaticMutex(void)
{
	static boost::mutex mutex;
	return mutex;
}

/**
 * Caller must hold static mutex.
 */
DbType::TypeMap& DbType::GetTypes(void)
{
	static DbType::TypeMap tm;
	return tm;
}
