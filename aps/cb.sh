#!/bin/sh

echo "# create branches #"

SVN_BASE_URL="https://svn.189read.net:4443/read/"

echo "******************************************************************"
echo "cb.sh [project_name] [redmine_id] [message] [SVN_BASE_URL_REPLACE]"
echo "******************************************************************"

project_name=$1
redmine_id=$2 
message=$3
SVN_BASE_URL_REPLACE=$4

if [ -z "$SVN_BASE_URL_REPLACE" ]; then
	SVN_BASE_URL_REPLACE="https://svn.189read.net:4443/read/"
fi

echo "SVN_BASE_URL_REPLACE:$SVN_BASE_URL_REPLACE"

datemk=`date +%Y%m%d`

cd ~/
project_trunk_path=`grep '^'${project_name}'\>' ${project_name} ~/project.csv  2>/dev/null | awk -F, '{print $2}'` 
project_branches_path=`grep '^'${project_name}'\>' ${project_name} ~/project.csv  2>/dev/null | awk -F, '{print $3}'` 

echo "project.csv:$project_trunk_path"
echo "project.csv:$project_branches_path"

if [ ! -f "$SVN_BASE_URL_REPLACE" ]; then
    project_trunk_path=${project_trunk_path/$SVN_BASE_URL/$SVN_BASE_URL_REPLACE}
    project_branches_path=${project_branches_path/$SVN_BASE_URL/$SVN_BASE_URL_REPLACE}	
    echo "REPLACE:$project_trunk_path"
	echo "REPLACE:$project_branches_path"
fi 
 
create_branches_path=${project_branches_path}/${datemk}_${redmine_id}

echo $project_trunk_path
echo $project_branches_path

brancheIsExit=`svn list ${project_branches_path} | grep ${datemk}_${redmine_id}`
echo "******************$brancheIsExit************************"

if [ ! -z "$brancheIsExit" ]; then
		echo "Failed: $brancheIsExit has already existed"
		exit 1
fi

svn cp $project_trunk_path  $create_branches_path -m "create branches #${redmine_id} ${message}"

echo branches:$create_branches_path
 
