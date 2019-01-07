#!/bin/bash
SLEEP_TIME=$1
HOST_NUMBER=$2
LOG_PATH=/var/log/curl.log
while true
do
date +"%y-%m-%d %H:%M:%S" >$LOG_PATH
curl -s "http://sdsdwesdfsdfsdfa.gstai.com/$HOST_NUMBER" >>$LOG_PATH
sleep $SLEEP_TIME
done
