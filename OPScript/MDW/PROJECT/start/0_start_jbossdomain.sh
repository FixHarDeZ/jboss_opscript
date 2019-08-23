#!/bin/bash
. /OPScript/MDW/jboss/setenv.dat
checkAlreadyStarted() {
	if [ $(ps -ef |grep -v grep |egrep -c DomainController.properties) != "0" ] && [ $(netstat -an |grep 9999 |egrep -c LISTEN) != "0" ]; then
	RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=master:read-attribute(name=server-state)' |egrep -c success")
		if [ "$RESULT" != "0" ]; then
			echo "JBoss Domain is already RUNNING!!!"
			exit 0
		fi
	fi

}

startJBossDomain() {
	echo "Starting JBoss Domain..."
	su - jbusr -c "$JBOSSDOMAIN/script/startDomainController.sh > /dev/null &"
	COUNT=20
	while [ true ]; do
	sleep 5
	RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=master:read-attribute(name=server-state)' |egrep -c success")
		if [ "$RESULT" != "0" ]; then
                        echo "SUCCESS!!! start JBoss domain completed"
						break
		else
			COUNT=`expr $COUNT - 1`
			sleep 1
			echo "waiting!!! for start DomainController for $COUNT sec."
			if [ $COUNT -eq 0 ]; then
			echo "ERROR!!! can't start JBoss domain please contact support"
			exit 1
			fi
		fi
	done
}

#Main
checkAlreadyStarted
startJBossDomain
