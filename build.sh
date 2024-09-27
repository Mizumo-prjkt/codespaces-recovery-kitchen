#!/bin/bash

WORKSPACE="$(realpath .)/workspaces"
R_HOME="$(realpath .)"
LUNCH_=$(cat .cache/lunch)
MKFILE_=$(cat .cache/mkfile)
DEVNAME_=$(cat .cache/devname)



if [ ! -e "workspaces" ]; then
    echo "Workspaces doesnt exist"
    echo "Exiting"
    exit 1
fi

# BUILD!
echo "Building recovery"
cd $WORKSPACE

source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch $MKFILE_-eng && make clean && make "$LUNCH_"image -j$(nproc --all)

clear
# Check if present
echo "Done"
if [ -e "out/target/product/$DEVNAME_/$LUNCH_.img" ] || [ -e "out/target/product/$DEVNAME_/*.zip" ] || [ -e "out/target/product/$DEVNAME_/*vendor*.img" ]; then
    echo "Output confirmed at $(realpath out/target/product/$DEVNAME_)"
else
    echo "Output not found"
    echo "Exiting"
    exit 1
fi

