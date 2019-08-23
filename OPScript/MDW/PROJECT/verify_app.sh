#!/bin/bash
. ./setenv.dat
SCOUNT=0

checkDomainStatus() {
	RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=master:read-attribute(name=server-state)' |egrep -c success")

	if [ "$RESULT" != "0" ] && [ "$(netstat -an |grep :9999 |grep LISTEN |wc -l)" != "0" ]; then
		echo "JBoss Domain is already RUNNING!!!"
		SCOUNT=`expr $SCOUNT + 1`
	else
		echo "JBoss Domain is DOWN!!!"
	fi
}

checkControllerStatus() {
	RESULT=$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=$DOMAINHOSTNAME:read-attribute(name=running-mode)' |egrep -c NORMAL")
	if [ "$RESULT" != "0" ] && [ "$(netstat -an |grep :19999 |grep LISTEN |wc -l)" != "0" ]; then
		echo "JBoss HostController is already RUNNING!!!"
		SCOUNT=`expr $SCOUNT + 1`
	else
			echo "JBoss HostController is DOWN!!!"
	fi
}

checkJVMStatus() {
	for i in ${JVM[@]}
        do
		COUNT=5
		while [ true ]; do
		if [ "$(su - jbusr -c "$JBOSSLIB/bin/jboss-cli.sh --connect --controller=$CONTROLLERHOSTNAME:9999 --command='/host=$DOMAINHOSTNAME/server-config=${i}:read-attribute(name=status)' |egrep -c STARTED")" != "0" ]; then
                        echo "JBoss JVM ${i} is already RUNNING!!!"
						SCOUNT=`expr $SCOUNT + 1`
						break
        else
			COUNT=`expr $COUNT - 1`
			sleep 1
			echo "waiting! $COUNT sec"
			if [ $COUNT -eq 0 ]; then
                        echo "JBoss JVM ${i} DOWN!!!"
			break
			fi
                fi
		done
    done
}


checkDomainStatus
checkControllerStatus
checkJVMStatus

NUMJVM=0
NUMJVM=${#JVM[@]}
ALLJVM=`expr $NUMJVM + 2`

if [ $SCOUNT == $ALLJVM ]; then
	echo "SUCCESS::JBoss status are normal RUNNING!!!"
else
	echo "FAIL::JBoss status are DOWN or STOPPED!!!"
	exit 1
fi
