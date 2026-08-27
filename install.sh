#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'pterodactyl-installer'                                                    #
#                                                                                    #
# Forked & Customized by Ayanok0ji:                                                  #
# https://github.com/Ayanok0ji/pterodactyl-installer                                 #
#                                                                                    #
# Credits to Owner (CCTO):                                                           #
# Originally created by Vilhelm Prytz, <vilhelm@prytznet.se>                         #
# Copyright (C) 2018 - 2026, Vilhelm Prytz and pterodactyl-installer contributors    #
# https://github.com/pterodactyl-installer/pterodactyl-installer                     #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   You should have received a copy of the GNU General Public License                #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.           #
#                                                                                    #
# https://github.com/Ayanok0ji/pterodactyl-installer/blob/master/LICENSE             #
#                                                                                    #
# This script is not associated with the official Pterodactyl Project.               #
# https://github.com/Ayanok0ji/pterodactyl-installer                                 #
#                                                                                    #
######################################################################################

export GITHUB_SOURCE="${GITHUB_SOURCE:-master}"
export SCRIPT_RELEASE="${SCRIPT_RELEASE:-master}"
export GITHUB_BASE_URL="${GITHUB_BASE_URL:-https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer}"

LOG_PATH="/var/log/pterodactyl-installer.log"

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# Always remove lib.sh and cached version file before starting
[ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh
[ -f /tmp/pterodactyl_installer_version ] && rm -rf /tmp/pterodactyl_installer_version

if ! curl -sSfL -o /tmp/lib.sh "$GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh"; then
  echo "* ERROR: Failed to download lib.sh from $GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh"
  exit 1
fi
# shellcheck source=lib/lib.sh
source /tmp/lib.sh

execute() {
  echo -e "\n\n* pterodactyl-installer $(date) \n\n" >>$LOG_PATH

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="canary"
  update_lib_source
  run_ui "${1//_canary/}" |& tee -a $LOG_PATH

  if [[ -n $2 ]]; then
    echo -e -n "* Installation of $1 completed. Do you want to proceed to $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      error "Installation of $2 aborted."
      exit 1
    fi
  fi
}

welcome ""

done=false
while [ "$done" == false ]; do
  options=(
    "Install the panel"
    "Install Wings"
    "Install both [0] and [1] on the same machine (wings script runs after panel)"
    # "Uninstall panel or wings\n"

    "Install panel with canary version of the script (the versions that lives in master, may be broken!)"
    "Install Wings with canary version of the script (the versions that lives in master, may be broken!)"
    "Install both [3] and [4] on the same machine (wings script runs after panel)"
    "Uninstall panel or wings with canary version of the script (the versions that lives in master, may be broken!)"
  )

  actions=(
    "panel"
    "wings"
    "panel;wings"
    # "uninstall"

    "panel_canary"
    "wings_canary"
    "panel_canary;wings_canary"
    "uninstall_canary"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done

# Remove temporary files
rm -rf /tmp/lib.sh
rm -rf /tmp/pterodactyl_installer_version
