#!/bin/sh
#
# chkconfig: 35 90 12
# description: Icinga 2
#
### BEGIN INIT INFO
# Provides:          icinga2
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: icinga2 host/service/network monitoring and management system
# Description:       Icinga 2 is a monitoring and management system for hosts, services and networks.
### END INIT INFO

DAEMON=@CMAKE_INSTALL_FULL_SBINDIR@/icinga2
ICINGA2_CONFIG_FILE=@CMAKE_INSTALL_FULL_SYSCONFDIR@/icinga2/icinga2.conf
ICINGA2_PID_FILE=@CMAKE_INSTALL_FULL_LOCALSTATEDIR@/run/icinga2/icinga2.pid
ICINGA2_ERROR_LOG=@CMAKE_INSTALL_FULL_LOCALSTATEDIR@/log/icinga2/error.log
ICINGA2_USER=@ICINGA2_USER@
ICINGA2_GROUP=@ICINGA2_GROUP@

test -x $DAEMON || exit 0

if [ ! -e $ICINGA2_CONFIG_FILE ]; then
        echo "Config file '$ICINGA2_CONFIG_FILE' does not exist."
        exit 1
fi

# Get function from functions library
if [ -f /etc/rc.d/init.d/functions ]; then
        . /etc/rc.d/init.d/functions
elif [ -f /etc/init.d/functions ]; then
        . /etc/init.d/functions
fi

# Load extra environment variables
if [ -f /etc/sysconfig/icinga ]; then
        . /etc/sysconfig/icinga
fi
if [ -f /etc/default/icinga ]; then
        . /etc/default/icinga
fi

# Start Icinga 2
start() {
	mkdir -p `dirname -- $ICINGA2_PID_FILE`
	mkdir -p `dirname -- $ICINGA2_ERROR_LOG`

        echo "Validating the configuration file:"
        if ! $DAEMON -c $ICINGA2_CONFIG_FILE -C; then
                echo "Not starting Icinga 2 due to configuration errors."
                exit 1
        fi

        echo "Starting Icinga 2: "
        ulimit -n 32768
	ulimit -s 512
	ulimit -u 16384
        $DAEMON -c $ICINGA2_CONFIG_FILE -d -e $ICINGA2_ERROR_LOG -u $ICINGA2_USER -g $ICINGA2_GROUP

        echo "Done"
        echo
}

# Restart Icinga 2
stop() {
        printf "Stopping Icinga 2: "
        if [ ! -e $ICINGA2_PID_FILE ]; then
                echo "The PID file '$ICINGA2_PID_FILE' does not exist."
                if [ "x$1" = "xnofail" ]; then
			return
		else
			exit 1
		fi
        fi

	pid=`cat $ICINGA2_PID_FILE`
	
        if kill -INT $pid >/dev/null 2>&1; then
		for i in 1 2 3 4 5 6 7 8 9 10; do
			if ! kill -CHLD $pid >/dev/null 2>&1; then
				break
			fi
		
			printf '.'
			
			sleep 1
		done
	fi

        if kill -CHLD $pid >/dev/null 2>&1; then
                kill -KILL $pid
        fi

	echo "Done"
}

# Reload Icinga 2
reload() {
	printf "Reloading Icinga 2: "
	if [ ! -e $ICINGA2_PID_FILE ]; then
		echo "The PID file '$ICINGA2_PID_FILE' does not exist."
		exit 1
	fi

	pid=`cat $ICINGA2_PID_FILE`

	if ! kill -HUP $pid >/dev/null 2>&1; then
		echo "Failed - Icinga 2 is not running."
	else
		echo "Done"
	fi
}

# Check the Icinga 2 configuration
checkconfig() {
	printf "Checking configuration:"

	echo "Validating the configuration file:"
	exec $DAEMON -c $ICINGA2_CONFIG_FILE -C
}

# Print status for Icinga 2
status() {
	printf "Icinga 2 status: "

	pid=`cat $ICINGA2_PID_FILE`
	if kill -CHLD $pid >/dev/null 2>&1; then
		echo "Running"
	else
		echo "Not running"
	fi
}

### main logic ###
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status
        ;;
  restart|condrestart)
        stop nofail
        start
        ;;
  reload)
	reload
	;;
  checkconfig)
	checkconfig
	;;
  *)
        echo "Usage: $0 {start|stop|restart|reload|checkconfig|status}"
        exit 1
esac
exit 0
