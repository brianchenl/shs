#!/bin/sh

dateMark=`date +"%Y%m%d"`
prefix=userInfo
outfileName=${prefix}${dateMark}.csv
dataPath="/home/data"

if [ -s ${dataPath}/${outfileName} ]; then
	echo test
fi
