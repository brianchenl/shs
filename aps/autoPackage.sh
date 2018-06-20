#!/bin/sh
#接收最少一个最多两个传参:若传参为一个则表示不merge直接编译打包；若传参为二个则表示先merge再编译打包
if [ $# == 0 ];then
    echo "错误，请传入参数！"
    exit 1
  elif [ $# == 1 ];then
    projectName=$1
  elif [ $# == 2 ];then
    projectName=$1
    mergeFile=$2
  else
    echo "错误，入参最多两个！"
	exit 1
fi

#断言函数
assert()
{
  if [ $? != 0 ];then
    exit 1
  fi
}

#系统变量分隔符
IFS=','
count=1
appNameLine=`cat ~/project.csv | awk -F, '{if ($1=="'$projectName'") {count++;print}}'`
projectDir=`echo ${appNameLine} | awk '{print $4}'`
projectBuildMode=`echo ${appNameLine} | awk '{print $5}'`
projectPackageList=`echo ${appNameLine} | awk '{print $6}'`
projectPackageSubDirList=`echo ${appNameLine} | awk '{print $7}'`

echo "*************************************** Message ****************************************************"
echo "projectName:$projectName"
echo "mergeFile:$mergeFile"
echo "projectDir:${projectDir}"
echo "projectBuildMode: ${projectBuildMode}" 
echo "projectPackageList:${projectPackageList}"
echo "projectPackageSubDirList:${projectPackageSubDirList}"

#判断上述变量是否都能获取到值
if [ ! -n "${projectDir}" ]||[ ! -n "${projectBuildMode}" ]||[ ! -n "${projectPackageList}" ]||[ ! -n "${projectPackageSubDirList}" ];then
  echo "错误，message有部分字段为空，请检查入参或project.csv"
  exit 1
fi

#若传参为二个则需要merge
if [ -n "${mergeFile}" ];then
  mergeFilePath=$PWD/$mergeFile
  if [ ! -f "${mergeFilePath}" ];then
    echo "错误，mergeFile不存在！"
	exit 1
  fi
  echo "*************************************** Merging ****************************************************"
  ~/svnmerge.sh  ${projectName} ${mergeFilePath}
  assert
fi

echo "*************************************** Building ****************************************************"
cd ${projectName}

if [ "$projectBuildMode" == "ant" ];then
	    echo "***build:ant"
        ant
		assert
	elif [ "$projectName" == "Pay" ] || [ "$projectName" == "OpenAPI" ] || [ "$projectName" == "duandai_new" ] || [ "$projectName" == "cs_search_sys" ] || [ "$projectName" == "soudelor" ];then
	    echo "***build: mvn clean install -Dmaven.test.skip=true -Ppe"
     	mvn clean install -Dmaven.test.skip=true -Ppe
		assert
    elif [ "$projectName" == "sms-duancai" ];then
        echo "***build: mvn clean install -Denv=online -Dmaven.test.skip=true"
        mvn clean install -Denv=online -Dmaven.test.skip=true
		assert
    else
        echo "***build:mvn clean install -Dmaven.test.skip=true"
    	mvn clean install -Dmaven.test.skip=true
		assert
fi

echo "********************************** copy *******************************************************"
cd  ${projectDir}

IFS='|'
for projectPackage in ${projectPackageList}
do
        projectPackageSubDir=`echo ${projectPackageSubDirList} | awk '{print $"'"$count"'"}'`
        let count+=1

        projectPackageDir=${projectDir}/${projectName}/${projectPackageSubDir}
	echo "projectPackageDir:${projectPackageDir}"
        projectPackagePath=${projectPackageDir}/${projectPackage}
	if [ ! -f "$projectPackagePath" ]; then
		projectPackagePath=${projectPackageSubDir}${projectPackage}
	fi
	yes | mv ${projectPackagePath} ./
	assert
	MD5 ${projectPackage}
	cd  ${projectDir}
done

