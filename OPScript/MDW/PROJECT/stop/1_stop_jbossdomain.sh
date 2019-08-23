#!/bin/bash
. /OPScript/MDW/jboss/setenv.dat
#check process JBoss Domain
RESULT=$(ps -ef |grep -v grep |egrep -c DomainController.properties)
if [ "$RESULT" == "0" ]; then
        echo "JBoss Domain is already stop!!!"
        exit 0
else
	echo "Stopping JBoss Domain..."
	su - jbusr -c "$JBOSSDOMAIN/script/stopDomainController.sh"
fi
