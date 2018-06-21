#!/bin/sh

dateMark=`date +"%Y%m%d"`
prefix=userInfo
outfileName=${prefix}${dateMark}.csv
dataPath="/home/data"
dirPath=`pwd`

if [ -s ${dataPath}/${outfileName} ]; then
	cp ${dataPath}/${outfileName} ${dirPath}/userInfo.csv
	/usr/bin/java -jar ${dirPath}/skulDemo-V1.jar

	resultFileName=result${dateMark}.log
	resultPath=${dirPath}/log
	resultFile=${resultPath}/${resultFileName}

	successNum=`grep 'ExchangeProductCard.java 97' ${resultPath}/info.log | wc -l`
	echo "${dateMark} result:" >> ${resultFile}
	echo "Success Count: ${successNum}" >> ${resultFile}
	echo "Error List: " >> ${resultFile}
	grep 'ExchangeProductCard.java 99' ${resultPath}/info.log >>  ${resultFile}
	grep 'ExchangeProductCard.java 106' ${resultPath}/info.log >>  ${resultFile}

	cp ${resultFile} ${dataPath}
fi
