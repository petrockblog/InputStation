#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

function getDeviceType() {
    xmlstarlet sel -t -v /inputList/inputConfig/@type ./userinput/inputconfig.xml
}

function getDeviceName() {
    xmlstarlet sel -t -v /inputList/inputConfig/@deviceName ./userinput/inputconfig.xml
}

function getInputAttribute() {
    inputName=\'$1\'
    attribute=$2
    deviceName=\'$(getDeviceName)\'
    xmlstarlet sel -t -v "/inputList/inputConfig[@deviceName=$deviceName]/input[@name=$inputName]/@$attribute" ./userinput/inputconfig.xml
}

function inputconfiguration() {

    declare -a inputConfigButtonList=("up" "right" "down" "left" "a" "b" "x" "y" "l" "r" "l2" "r2" "l3" "r3" "start" "select" "l_x_plus_axis" "l_x_minus_axis" "l_y_plus_axis" "l_y_minus_axis" "r_x_plus_axis" "r_x_minus_axis" "r_y_plus_axis" "r_y_minus_axis")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    # get input configuration from user
    ./userinput/userinput.sh

    deviceType=$(getDeviceType)
    deviceName=$(getDeviceName)

    # now we have the file ./userinput/inputconfig.xml and we use this information to configure all registered emulators
    for module in $(find "$inputscriptdir/emulatorconfigs/" -maxdepth 1 -name "*.sh" | sort); do

        source "$module"  # register functions from emulatorconfigs folder
        local onlyFilename=$(basename "$module")
        echo "Configuring '$onlyFilename'"

        # loop through all buttons and use corresponding config function if it exists
        for button in "${inputConfigButtonList[@]}"; do
            funcname=$button"_inputconfig_"${onlyFilename::-3}

            inputName=$(getInputAttribute "$button" "name")
            inputType=$(getInputAttribute "$button" "type")
            inputID=$(getInputAttribute "$button" "id")
            inputValue=$(getInputAttribute "$button" "value")

            fn_exists "$funcname" && "$funcname" "$deviceType" "$deviceName" "$inputName" "$inputType" "$inputID" "$inputValue"
        done

        # at the end, the onleave_inputconfig_X function is called
        funcname="onleave_inputconfig_"${onlyFilename::-3}
        fn_exists "$funcname" && "$funcname" "$deviceType" "$deviceName"

    done

}

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)

home="$(eval echo ~$user)"
inputconfiguration
