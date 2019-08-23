#!/bin/bash
. /OPScript/MDW/jboss/setenv.dat
#check JBoss Host Controller process
RESULT=$(ps -ef |grep -v grep |egrep -c HostController.properties)
if [ "$RESULT" == "0" ]; then
        echo "JBoss Host Contraller is already stop!!!"
        exit 0
else
	echo "Stopping JBoss Host controller..."
	su - jbusr -c "$JBOSSDOMAIN/script/stopHostController.sh"
fi
