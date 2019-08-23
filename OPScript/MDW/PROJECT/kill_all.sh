#!/bin/bash
for PID in $(ps -ef |grep java |grep jboss |grep -v grep |grep jbusr |grep -v pconsole |grep -v kill_all.sh |awk '{print $2}')
do
echo "---kill process $PID---"
kill -9 $PID
done

echo "Success!!! Kill JBoss completed"
