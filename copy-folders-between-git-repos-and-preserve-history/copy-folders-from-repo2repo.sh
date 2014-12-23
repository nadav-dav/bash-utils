#!/bin/bash

REPO_A="[SOURCE REPO]" # example git@github.com:user/my-awsome-repo.git
REPO_A_NAME="[SOURCE REPO NAME]" # exmple my-awsome-repo
COPY_FOLDER_FROM_A="[FOLDER IN SOURCE REPO]" # exmaple src/myfolder

DEST_REPO_B="[DEST REPO LOCATION]" # example /Users/username/projects/my-other-repo
COPY_TO_FOLDER_IN_B="[DEST FOLDER IN DEST REPO]" # example src/files-from-other-repo

GREEN="\x1B[01;92m"
BLUE="\x1B[01;96m"
RESET="\x1B[0m"

function announce(){ 
	echo "====================================="
	echo -e "$GREEN$1$RESET"
	echo "=====================================" 
}
function confirm(){
	read -p "$1" -n 1 -r
	echo 
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
	    exit 1
	fi
}


echo -e "You are about to copy a repo from $GREEN $REPO_A $RESET"
echo -e "and copy the folder $BLUE $COPY_FOLDER_FROM_A $RESET"
echo -e "into a folder $BLUE $COPY_TO_FOLDER_IN_B $RESET"
echo -e "in this repository $GREEN $DEST_REPO_B $RESET"
confirm "Are these values right? [hit Y to continue]"

announce "Cloning source to a temp repo"
git clone $REPO_A /tmp/repo_a
cd /tmp/repo_a
git remote rm origin

announce "Extracting wanted folder"
git filter-branch --subdirectory-filter $COPY_FOLDER_FROM_A -- --all

announce "Creating destination folder"
mkdir -p $COPY_TO_FOLDER_IN_B
mv * $COPY_TO_FOLDER_IN_B

announce "Commiting changes in a temp repo"
git add .
git commit -am "moved from $REPO_A_NAME [$REPO_A]"

announce "Adding remote pointing to the temp repo"
cd $DEST_REPO_B
git remote add repo-A-branch /tmp/repo_a

announce "Merging temp repo"
git pull --no-edit repo-A-branch master

announce "Cleaning up"
git remote rm repo-A-branch
rm -rf /tmp/repo_a