#!/bin/bash

# Check if user is on root (and auto run to root if not)
if [ ! "$(/usr/bin/id -u)" == '0']; then
    sudo ./pre-start.sh
    exit
fi

# Download Repo from Google using curl
curl curl https://storage.googleapis.com/git-repo-downloads/repo 
chmod +x repo
mv repo /usr/bin/repo


# Install Dependencies
apt update
apt upgrade
apt install openjdk-8-jdk dialog aria2 libncurses5 git python-is-python3 python2 python3 wget curl libc6-dev tar cpio default-jdk git-core gnupg flex bison gperf build-essential zip curl aria2 libc6-dev libncurses5-dev x11proto-core-dev libx11-dev libreadline6-dev libgl1-mesa-glx libgl1-mesa-dev python3 make sudo gcc g++ bc grep tofrodos python3-markdown libxml2-utils xsltproc zlib1g-dev -y

echo "Done"
exit