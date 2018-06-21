dateMark=`date +"%Y%m%d"`
prefix=config
outFileName=${dateMark}${prefix}.csv
dirPath=`pwd`

cp ${dirPath}/data/${outFileName} ${dirPath}/config.csv
/usr/bin/java -jar ${dirPath}/csSendSms.jar && /usr/bin/java -jar ${dirPath}/sendSms.jar
