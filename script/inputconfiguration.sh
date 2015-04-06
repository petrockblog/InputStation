#!/usr/bin/env bash

# This file is part of InputStation.
#
# See the LICENSE.md file at the top-level directory of this distribution
#

function inputconfiguration() {

    declare -a inputConfigButtonList=("dpadup" "dpadright" "dpaddown" "dpadleft" "a" "b" "x" "y" "leftbottom" "rightbottom" "lefttop" "righttop" "leftthumb" "rightthumb" "start" "select" "leftanalogright" "leftanalogleft" "leftanalogdown" "leftanalogup" "rightanalogright" "rightanalogleft" "rightanalogdown" "rightanalogup")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    # get input configuration from 
    pushd $inputscriptdir
    $inputscriptdir/../program/inputstation

    # now we should have the file "./inputconfiguration.cfg"
    if [[ -f $inputscriptdir/inputconfiguration.cfg ]]; then
        
        deviceType=$(getDeviceType)
        deviceName=$(getDeviceName)

        # now we have the file ./userinput/inputconfig.xml and we use this information to configure all registered emulators
        for module in $(find "$inputscriptdir/configscripts/" -maxdepth 1 -name "*.sh" | sort); do

            source "$module"  # register functions from emulatorconfigs folder
            local onlyFilename=$(basename "$module")
            echo "Configuring '$onlyFilename'"

            # loop through all buttons and use corresponding config function if it exists
            for button in "${inputConfigButtonList[@]}"; do
                funcname=$button"_inputconfig_"${onlyFilename::-3}

                # if interface function is implemented
                if fn_exists "$funcname"; then  

                    inputName=$(getInputAttribute "$button" "name")
                    inputType=$(getInputAttribute "$button" "type")
                    inputID=$(getInputAttribute "$button" "id")
                    inputValue=$(getInputAttribute "$button" "value")

                    # if input was defined
                    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName='$deviceName']/input[@name='$inputName'])" ./inputconfiguration.cfg) -ne 0 ]]; then
                        "$funcname" "$deviceType" "$deviceName" "$inputName" "$inputType" "$inputID" "$inputValue"
                    fi
                fi
            done

            # at the end, the onleave_inputconfig_X function is called
            funcname="onleave_inputconfig_"${onlyFilename::-3}
            fn_exists "$funcname"

            # if interface function is implemented
            fn_exists "$funcname" && "$funcname" "$deviceType" "$deviceName"

        done

    fi
    popd

}

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

function getDeviceType() {
    xmlstarlet sel -t -v /inputList/inputConfig/@type ./inputconfiguration.cfg
}

function getDeviceName() {
    xmlstarlet sel -t -v /inputList/inputConfig/@deviceName ./inputconfiguration.cfg
}

function getInputAttribute() {
    inputName=\'$1\'
    attribute=$2
    deviceName=\'$(getDeviceName)\'
    xmlstarlet sel -t -v "/inputList/inputConfig[@deviceName=$deviceName]/input[@name=$inputName]/@$attribute" ./inputconfiguration.cfg
}

###### main ######

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)
home="$(eval echo ~$user)"

inputconfiguration
