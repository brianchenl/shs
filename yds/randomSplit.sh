#!/bin/sh

[ $# -eq 0 ] && echo "usage: randomSplit.sh FileName." && exit 1
splitFile=$1
tempFile="tempFile.txt"
tempFile2="tempFile2.txt"
cp ${splitFile} ./${tempFile}
base=6500
seed=1500
fileRows=`cat ${tempFile} | wc -l`
prefix=outfile
countNum=0
outfileName=""

while [ ${fileRows} -ge ${base} ]; do
	#echo $countNum
	dateMark=`date -d "${countNum} day" +"%y%m%d"`
	outfileName=${prefix}_${dateMark}.txt
	#echo $outfileName
	splitRows=$(($RANDOM%$seed+$base))
	remainingRows=$(($fileRows-$splitRows+1))
	head -${splitRows} ${tempFile} > ${outfileName}
	tail -${remainingRows} ${tempFile} > ${tempFile2}
	cp ${tempFile2} ${tempFile}
	echo "${outfileName} : ${splitRows}"
	countNum=$(($countNum+1))
	fileRows=`cat ${tempFile} | wc -l`
done

dateMark=`date -d "${countNum} day" +"%y%m%d"`
outfileName=${prefix}_${dateMark}.txt
cp ./${tempFile} ./${outfileName}
echo "${outfileName} : ${fileRows}"
