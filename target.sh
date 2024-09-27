#!/bin/bash

if [ -e "workspaces" ]; then
    echo "Workspaces already exist"
    read -p "Do you want to get rid of it? [Y/n]: " SE
    case $SE in
        [Yy]*)
            rm -rf workspaces
            ;;
        [Nn]*)
            echo "Aborted rm, but note that repo may show an error so if somethings wrong, it is required to delete existing workspaces"
            ;;
        *)
            echo "Exit"
            exit 9
            ;;
    esac
fi

# VARIABLE
WORKSPACE="$(realpath .)/workspaces"
R_HOME="$(realpath .)"
if [ -e ".cache/username" ] && [ -e ".cache/email" ] ; then
    USER_=$(cat .cache/username)
    GEMAIL_=$(cat .cache/email)
    LUNCH_=$(cat .cache/lunch)
    DEVNAME_=$(cat .cache/devname)
else
    USER_=$(dialog --title "Enter Username for Git" --inputbox "Input username for Git" 0 0 2>&1 >/dev/tty)
    if [ -z "$USER_" ]; then
        echo "No entry detected"
        exit
    fi
    GEMAIL_=$(dialog --title "Enter Email for Git" --inputbox "Input email for Git" 0 0 2>&1 >/dev/tty)
    if [ -z "$GEMAIL_" ]; then
        echo "No entry detected"
        exit
    fi
    LUNCH_=$(dialog --title "Enter Build Target for device" --inputbox "Input Build Target for device (enter 'recovery' if unsure)" 0 0 "recovery" 2>&1 >/dev/tty)
    if [ -z "$LUNCH_" ]; then
        echo "No entry detected"
        exit
    fi
    DEVNAME_=$(dialog --title "Enter Device name" --inputbox "Input Device name" 0 0 "a12s" 2>&1 >/dev/tty)
    if [ -z "$DEVNAME_" ]; then
        echo "No entry detected"
        exit
    fi
fi

# CACHE ENTRY
mkdir -p .cache
echo "$USER_" > .cache/username
echo "$GEMAIL_" > .cache/email
echo "$LUNCH_" > .cache/lunch
echo "$DEVNAME_" > .cache/devname


# GO WORKSPACES
cd $WORKSPACE

pick=$(dialog  --backtitle "Repo Select Tool" \
                --title "Select what fork of TWRP do you want???" \
                --menu "Select what fork of TWRP you want from TWRP Manifest: \nhttps://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp" 0 0 0 \
                "Twrp 11" "Use TWRP 11" \
                "Twrp 12.1" "Use TWRP 12.1" \
                "Twrp 14" "Use TWRP 14"\
                2>&1 >/dev/tty)
                local erval=$?
                case $erval in
                    1)
                        clear
                        exit 1
                        ;;
                esac
                case $pick in
                    "Twrp 11")
                        clear
                        echo "Grabbing TWRP 11 Manifests"
                        git config --global user.email "$GEMAIL_"
                        git config --global user.name "$USER_"
                        repo init --depth=1 https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-11
                        ;;
                    "Twrp 12.1")
                        clear
                        echo "Grabbing TWRP 12.1 Manifests"
                        git config --global user.email "$GEMAIL_"
                        git config --global user.name "$USER_"
                        repo init --depth=1 https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-12.1
                        ;;
                    "Twrp 14")
                        clear
                        echo "Grabbing TWRP 14 Manifests"
                        git config --global user.email "$GEMAIL_"
                        git config --global user.name "$USER_"
                        repo init --depth=1 https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-14
                        ;;
                esac

# Sync REPO
repo sync -j$(nproc --all) --force-sync

# Device tree Prompt
dt=$(dialog --backtitle "Your device tree" \
            --title "Enter device tree link" \
            --inputbox "Enter device tree link" 0 0 2>&1 >/dev/tty)
            clear
            local erval=$?
            case $erval in
                1)
                    echo "No entry detected"
                    exit 1
                    ;;
            esac
device_path=$(dialog --backtitle "Device Path" \
            --title "Enter device path" \
            --inputbox "Enter device path"  0 0 \
            "./device/samsung/a12s" \
             2>&1 >/dev/tty)
            clear
            local erval=$?
            case $erval in
                1)
                    echo "No entry detected"
                    exit 1
                    ;;
            esac
    if [ -z "$dt" ]; then
        echo "No entry detected"
        exit 1
    fi
    if [ -z "$device_path" ]; then
        echo "No entry detected"
        exit 1
    fi

# Makefile name
mk=$(dialog --backtitle "Your Makefile name" \
            --title "Enter makefile name" \
            --inputbox "Enter makefile name" 0 0 twrp_a12s 2>&1 >/dev/tty)
if [ -z "$mk" ]; then
    echo "No entry detected"
    exit 1
fi
echo "$mk" > .cache/mkfile



# Common Tree
# If there's no common tree, skip

ct=$(dialog --backtitle "Your Common Tree (OPTIONAL)" \
            --title "Enter common tree link" \
            --inputbox "Enter common tree link\n\nIF THERE'S NO COMMON TREE, SKIP THIS" 0 0 2>&1 >/dev/tty)
if [ -n "$ct" ]; then
    common_path=$(dialog --backtitle "Common Path" \
                        --title "Enter common path" \
                        --inputbox "Enter common path"  0 0 \
                            2>&1 >/dev/tty)
    if [ -z "$common_path" ] && [ -z "$ct" ]; then
        echo "No entry detected"
        exit 1
    fi
    git clone $ct $common_path
fi


# Grab Build-TWRP SRC
cd $R_HOME
curl https://raw.githubusercontent.com/SUFandom/Build-TWRP/refs/heads/main/scripts/convert.sh > convert.sh
chmod +x convert.sh
conv=$(realpath convert.sh)

# Go WORKSPACES
# Conv
cd $WORKSPACE
set +e
bash $conv $device_path/true
repo sync -j$(nproc --all)
set -e

# Done
echo "Done"
echo "Exec Build on ./build.sh via $R_HOME"
exit



