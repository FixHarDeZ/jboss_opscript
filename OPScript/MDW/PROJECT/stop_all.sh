#!/bin/bash
. ./setenv.dat

$STOPPATH/0*
$STOPPATH/1*

echo "waiting 30 sec."
sleep 30
echo "Checking remain processes"
if [ "$(ps -ef|grep java|grep jbusr|grep -v grep|wc -l)" != "0" ]; then
        echo "Found processes left"
        /OPScript/MDW/$PROJECT/kill_all.sh
		exit 0
else
        echo "Not found remain processes"
        echo "Stop JBoss completed!!!"
fi
