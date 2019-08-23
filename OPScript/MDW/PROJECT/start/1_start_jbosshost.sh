#!/bin/bash
. /OPScript/MDW/jboss/setenv.dat
SUM=0
checkJVMStatus() {
	for i in ${JVM[@]}
    do      
		COUNT=$SLEEP
		while [ true ]; do
		sleep 5
		RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=$DOMAINHOSTNAME/server-config=${i}:read-attribute(name=status)'|egrep -c STARTED")
		if [ "$RESULT" != "0" ]; then
                        echo "SUCCESS!!! JBoss JVM ${i} already RUNNING!!!"
			break
                else
					COUNT=`expr $COUNT - 1`
					sleep 1
					echo "waiting! $COUNT sec"
					if [ $COUNT -eq 0 ]; then
                        echo "start JBoss JVM ${i} FAIL!!!"
					break
					fi
		fi
		done
    done
}

checkAlreadyStarted() {
        RESULT=$(ps -ef |grep -v grep |grep HostController.properties |wc -l)
        if [ "$RESULT" != "0" ]; then
                echo "JBoss Host Contraller is already start!!!"
                checkJVMStatus
                exit 0
        fi
}

startJBossController() {
	echo "Starting JBoss Host Controller and Application Server(JVM)..."
	su - jbusr -c "$JBOSSDOMAIN/script/startHostController.sh > /dev/null &"
}

checkControllerStatus() {
	COUNT=$SLEEP
	while [ true ]; do
	sleep 5
	RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=$DOMAINHOSTNAME:read-attribute(name=running-mode)' |egrep -c NORMAL")
	if [ "$RESULT" != "0" ] && [ "$(netstat -an |grep 19999 |grep LISTEN |wc -l)" != "0" ]; then
		echo "SUCCESS!!! start JBoss Host controller completed"
		break
	else
		COUNT=`expr $COUNT - 1`
		sleep 1
		echo "waiting!!! for start HostController for $COUNT sec."
		if [ $COUNT -eq 0 ]; then
			echo "ERROR!!! can't start JBoss host please contact support"
			exit 1
		fi
	fi
	done
}

#Main
checkAlreadyStarted
startJBossController
checkControllerStatus
checkJVMStatus
