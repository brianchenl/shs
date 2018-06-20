#!/bin/sh
# create by brianchenl@tyyd
# 2013-11-12

#断言函数
assert()
{
  if [ $? != 0 ];then
    echo "ERROR,$1"
    exit 1
  fi
}

BASE=`pwd`
baseRev=""
mergeFile=""

#判断入参个数，至少1个至多3个，若为3个第三个参数必须为cancel
if [ ! -e $1 ] || [ $# -eq 0 ] || [ $# -gt 3 ] || ( [ $# -eq 3 ] && [ "$3" != "cancel" ] ); then

	echo "Usage: svnmerge.sh projectName mergefile [cancel]"

	if [ $# -eq 0 ]; then
		echo  "Error: Please specify projectName!"
	  elif [ $# -eq 1 ]; then
		echo  "Error: Please specify mergefile!"
	  elif [ $# -gt 3 ]; then 
		echo  "Error: Too many args!"
	  elif [ $# -eq 3 ] && [ "cancel" != "$3" ]; then
		echo  'Error: The last args must set "cancel"!'
	  elif [ -n $2 ]; then
		echo  "Error: File $1 not exist!"
	fi

	exit 1
fi

projectName="$1"

if echo "$2" | grep -q '^/.*'; then 
	mergeFile=$2
else
	mergeFile="${BASE}/$2"
fi

#清理本地工程变动文件
echo "--------------------------------- 开始清理编译环境 --------------------------------------"

cd ${projectName}
svn revert -R .
assert "svn revert"
svn st | grep '?' | xargs -s 100000 rm -rf 
assert "rm svn st1"
svn st | xargs rm -rf 
assert "rm svn st2"
svn up
assert "svn up"

echo "--------------------------------- 清理编译环境结束 --------------------------------------"
echo "查看清理后环境状态 svn st:"
svn st

echo "---------------------------------Svn Merge start--------------------------------------"
while read LINE
do
	if [ -z "$LINE" ]; then
		continue
	fi

	branchesUrl=`echo $LINE | awk '{print $1}'`
   	branchesVer=`echo $LINE | awk '{print $2}'`
   	branchesStartVer=`echo $LINE | awk '{print $3}'`
	brancheFullUrl=${branchesUrl}
	baseRev=`svn -q log --stop-on-copy ${brancheFullUrl} | tail -n 2 |head -1 |awk '{print $1}'|sed -e 's/r//g'`
	if [ -z ${branchesVer} ] && [ "cancel" != "$2" ]; then
		echo "Merging ${brancheFullUrl} ver:HEAD"
		svn merge -r ${baseRev}:HEAD ${brancheFullUrl} --non-interactive>merge.log
		assert "svn merge -r ${baseRev}:HEAD ${brancheFullUrl} --non-interactive"
	elif [ ! -z ${branchesVer} ] && [ "cancel" != "$2" ] && [ -z ${branchesStartVer} ]; then
		echo "Merging ${brancheFullUrl} -r ${baseRev}:${branchesVer}"
		svn merge -r ${baseRev}:${branchesVer} ${brancheFullUrl} --non-interactive>merge.log
		assert "svn merge -r ${baseRev}:${branchesVer} ${brancheFullUrl} --non-interactive"
	elif [ ! -z ${branchesVer} ] && [ "cancel" != "$2" ] && [ ! -z ${branchesStartVer} ]; then
		echo "Merging ${brancheFullUrl} -r ${branchesStartVer}:${branchesVer}"
		svn merge -r ${branchesStartVer}:${branchesVer} ${brancheFullUrl} --non-interactive>merge.log
		assert "svn merge -r ${branchesStartVer}:${branchesVer} ${brancheFullUrl} --non-interactive"
	elif [ "cancel" == "$2" ]; then
		echo "Merging cancel ${brancheFullUrl} -r HEAD:${baseRev}"
		svn merge -r HEAD:${baseRev} ${brancheFullUrl} --non-interactive>merge.log
		assert "svn merge -r HEAD:${baseRev} ${brancheFullUrl} --non-interactive"
	fi

done <  ${mergeFile}
cat merge.log

echo "---------------------------------Svn Merge end--------------------------------------"

echo "---------------------------------开始判断冲突---------------------------------------"
conflict=`cat merge.log|grep 'Summary of conflicts:'`
if [ ! -n "${conflict}" ];then
  echo "merge无冲突"
else
  echo "merge有冲突："
  cat merge.log|grep 'conflicts:'
  cat merge.log|grep ^C
  exit 1
fi  
echo "---------------------------------冲突判断结束---------------------------------------"
