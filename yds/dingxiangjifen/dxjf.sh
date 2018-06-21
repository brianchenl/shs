#!/bin/sh

dateMark=`date +"%y%m%d"`
prefix=outfile
outfileName=${prefix}_${dateMark}.txt
dirPath=`pwd`

cp ${dirPath}/${outfileName} ${dirPath}/user.csv
/usr/bin/java -jar ${dirPath}/loginGiveGo.jar
