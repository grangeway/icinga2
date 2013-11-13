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

#include "icinga/scheduleddowntime.h"
#include "base/timer.h"
#include "base/dynamictype.h"
#include "base/initialize.h"
#include "base/utility.h"
#include <boost/foreach.hpp>

using namespace icinga;

REGISTER_TYPE(ScheduledDowntime);

INITIALIZE_ONCE(&ScheduledDowntime::StaticInitialize);

static Timer::Ptr l_Timer;

void ScheduledDowntime::StaticInitialize(void)
{
	l_Timer = make_shared<Timer>();
	l_Timer->SetInterval(60);;
	l_Timer->OnTimerExpired.connect(boost::bind(&ScheduledDowntime::TimerProc));
}

void ScheduledDowntime::Start(void)
{
	DynamicObject::Start();

	CreateNextDowntime(true);
}

void ScheduledDowntime::TimerProc(void)
{
	BOOST_FOREACH(const ScheduledDowntime::Ptr& sd, DynamicType::GetObjects<ScheduledDowntime>()) {
		sd->CreateNextDowntime(false);
	}
}

Service::Ptr ScheduledDowntime::GetService(void) const
{
	Host::Ptr host = Host::GetByName(GetHostRaw());

	if (!host)
		return Service::Ptr();

	if (GetServiceRaw().IsEmpty())
		return host->GetCheckService();
	else
		return host->GetServiceByShortName(GetServiceRaw());
}

std::pair<double, double> ScheduledDowntime::FindNextSegment(void)
{
	return std::make_pair(0, 0);
}

void ScheduledDowntime::CreateNextDowntime(bool overwrite)
{
	GetService()->AddDowntime(GetAuthor(), GetComment(), Utility::GetTime(), Utility::GetTime() + 60, true, String(), 0, GetName());
}