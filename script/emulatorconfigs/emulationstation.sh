#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

###### input configuration interface functions ######

#######################################
# Interface functions
# All interface functions get the same arguments. The naming scheme of the interface 
# functions is defined as following:
#
# function <button name>_inputconfig_<filename without extension>(),
#
# where <button name> is one of [ "up",
#                                 "right",
#                                 "down",
#                                 "left",
#                                 "a_btn",
#                                 "b_btn",
#                                 "x_btn",
#                                 "y_btn",
#                                 "l_btn",
#                                 "r_btn",
#                                 "l2_btn",
#                                 "r2_btn",
#                                 "l3_btn",
#                                 "r3_btn",
#                                 "start_btn",
#                                 "select_btn",
#                                 "l_x_plus_axis",
#                                 "l_x_minus_axis",
#                                 "l_y_plus_axis",
#                                 "l_y_minus_axis",
#                                 "r_x_plus_axis",
#                                 "r_x_minus_axis",
#                                 "r_y_plus_axis",
#                                 "r_y_minus_axis" ].
#
# Globals:
#   $home - the home directory of the user
#
# Arguments:
#   $1 - device type
#   $2 - device name
#   $3 - input name
#   $4 - input type
#   $5 - input ID
#   $6 - input value
#
# Returns:
#   None
#######################################

function up_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "up" "key" "1073741906" "1"
}

function right_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "right" "key" "1073741903" "1"
}

function down_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "down" "key" "1073741905" "1"
}

function left_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "left" "key" "1073741904" "1"
}

function a_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "a" "key" "97" "1"
}

function b_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "b" "key" "115" "1"
}

function l_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "pagedown" "key" "1073741902" "1"
}

function r_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "pageup" "key" "1073741899" "1"
}

function start_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "start" "key" "13" "1"
}

function select_inputconfig_emulationstation() {
    setESInputConfig_inputconfig_emulationstation "$1" "$2" "$3" "$4" "$5" "$6"
    setESInputConfig_inputconfig_emulationstation "keyboard" "Keyboard" "select" "key" "32" "1"
}

###### helper functions ######
# to circumvent name collisions we use quite long function names in the following

# add or update input configuration for a given device and input
function setESInputConfig_inputconfig_emulationstation() {
    local deviceType=$1
    local deviceName=$2
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    local confFile="$home/.emulationstation/es_input.cfg"
    mkdir -p "$home/.emulationstation"
    if [[ ! -f "$confFile" ]]; then
        echo "<inputList />" >"$confFile"
    fi

    cp "$confFile" "$confFile.bak"

    # make sure that device exists
    deviceNameString=\'$deviceName\'
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName=$deviceNameString])" "$confFile") -eq 0 ]]; then
        xmlstarlet ed -L -s "/inputList" -t elem -n newInputConfig -v "" \
            -i //newInputConfig -t attr -n "type" -v "$deviceType" \
            -i //newInputConfig -t attr -n "deviceName" -v "$deviceName" \
            -r //newInputConfig -v inputConfig \
            "$confFile"
    else
        xmlstarlet ed -L \
                      -u "/inputList/inputConfig[@deviceName=$deviceNameString]/@deviceType" -v "$deviceType" \
                      -d "/inputList/inputConfig[@deviceName=$deviceNameString]/@deviceGUID" \
                      "$confFile"
    fi

    # add or update element
    inputNameString=\'$inputName\'
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName=$deviceNameString]/input[@name=$inputNameString])" "$confFile") -eq 0 ]]; then
        xmlstarlet ed -L -s "/inputList/inputConfig[@deviceName=$deviceNameString]" -t elem -n newinput -v "" \
            -i //newinput -t attr -n "name" -v "$inputName" \
            -i //newinput -t attr -n "type" -v "$inputType" \
            -i //newinput -t attr -n "id" -v "$inputID" \
            -i //newinput -t attr -n "value" -v "$inputValue" \
            -r //newinput -v input \
            "$confFile"                      
    else  # if device already exists, update it
        xmlstarlet ed -L \
                      -u "/inputList/inputConfig[@deviceName=$deviceNameString]/input[@name=$inputNameString]/@type" -v "$inputType" \
                      -u "/inputList/inputConfig[@deviceName=$deviceNameString]/input[@name=$inputNameString]/@id" -v "$inputID" \
                      -u "/inputList/inputConfig[@deviceName=$deviceNameString]/input[@name=$inputNameString]/@value" -v "$inputValue" \
                      "$confFile"
    fi
}
