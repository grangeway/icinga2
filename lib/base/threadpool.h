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

#ifndef THREADPOOL_H
#define THREADPOOL_H

#include "base/i2-base.h"
#include <stack>
#include <boost/function.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition_variable.hpp>

namespace icinga
{

/**
 * A thread pool.
 *
 * @ingroup base
 */
class I2_BASE_API ThreadPool
{
public:
	typedef boost::function<void ()> WorkFunction;

	ThreadPool(void);
	~ThreadPool(void);

	void Stop(void);
	void Join(void);

	bool Post(const WorkFunction& callback);

private:
	enum ThreadState
	{
		ThreadUnspecified,
		ThreadDead,
		ThreadIdle,
		ThreadBusy
	};

	struct WorkerThread
	{
		ThreadState State;
		bool Zombie;
		double Utilization;
		double LastUpdate;
		boost::thread *Thread;

		WorkerThread(ThreadState state = ThreadDead)
			: State(state), Zombie(false), Utilization(0), LastUpdate(0), Thread(NULL)
		{ }
	};

	int m_ID;
	static int m_NextID;

	boost::thread_group m_ThreadGroup;
	WorkerThread m_Threads[4096];

	double m_WaitTime;
	double m_ServiceTime;
	int m_TaskCount;

	double m_MaxLatency;

	boost::mutex m_Mutex;
	boost::condition_variable m_WorkCV;
	boost::condition_variable m_MgmtCV;

	bool m_Stopped;

	struct WorkItem
	{
		WorkFunction Callback;
		double Timestamp;
	};


	std::deque<WorkItem> m_WorkItems;

	void QueueThreadProc(int tid);
	void ManagerThreadProc(void);
	void StatsThreadProc(void);

	void SpawnWorker(void);
	void KillWorker(void);

	void UpdateThreadUtilization(int tid, ThreadState state = ThreadUnspecified);
};

}

#endif /* EVENTQUEUE_H */
