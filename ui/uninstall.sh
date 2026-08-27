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
# https://github.com/Ayanok0ji/pterodactyl-installer/blob/main/LICENSE               #
#                                                                                    #
# This script is not associated with the official Pterodactyl Project.               #
# https://github.com/Ayanok0ji/pterodactyl-installer                                 #
#                                                                                    #
######################################################################################

# Check if script is loaded, load if not or fail otherwise.
fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_BASE_URL/$GITHUB_SOURCE"/lib/lib.sh)
  ! fn_exists lib_loaded && echo "* ERROR: Could not load lib script" && exit 1
fi

# ------------------ Variables ----------------- #

export RM_PANEL=false
export RM_WINGS=false
export RM_SSL=false

# --------------- Main functions --------------- #

main() {
  welcome ""

  output "Pterodactyl Uninstallation Assistant"
  output "Select the components you want to remove from this system."
  echo ""

  local panel_detected=false
  local wings_detected=false

  [ -d "/var/www/pterodactyl" ] || [ -f "/etc/nginx/sites-available/pterodactyl.conf" ] || [ -f "/etc/nginx/conf.d/pterodactyl.conf" ] || [ -f "/etc/systemd/system/pteroq.service" ] && panel_detected=true
  [ -d "/etc/pterodactyl" ] || [ -f "/usr/local/bin/wings" ] || [ -f "/etc/systemd/system/wings.service" ] || [ -d "/var/lib/pterodactyl" ] && wings_detected=true

  if [ "$panel_detected" == true ]; then
    output "Panel installation detected on this system."
    echo -e -n "* Do you want to uninstall and remove Pterodactyl Panel? (y/N): "
    read -r RM_PANEL_INPUT
    [[ "$RM_PANEL_INPUT" =~ [Yy] ]] && RM_PANEL=true
  else
    echo -e -n "* Panel was not detected. Run Panel cleanup anyway? (y/N): "
    read -r RM_PANEL_INPUT
    [[ "$RM_PANEL_INPUT" =~ [Yy] ]] && RM_PANEL=true
  fi

  if [ "$wings_detected" == true ]; then
    output "Wings installation detected on this system."
    warning "Uninstalling Wings will stop and delete all game servers and Docker containers on this node!"
    echo -e -n "* Do you want to uninstall and remove Pterodactyl Wings? (y/N): "
    read -r RM_WINGS_INPUT
    [[ "$RM_WINGS_INPUT" =~ [Yy] ]] && RM_WINGS=true
  else
    echo -e -n "* Wings was not detected. Run Wings cleanup anyway? (y/N): "
    read -r RM_WINGS_INPUT
    [[ "$RM_WINGS_INPUT" =~ [Yy] ]] && RM_WINGS=true
  fi

  if [ -d "/etc/letsencrypt" ]; then
    output "Let's Encrypt SSL directory detected (/etc/letsencrypt)."
    echo -e -n "* Do you want to remove Let's Encrypt SSL certificates (Certbot)? (y/N): "
    read -r RM_SSL_INPUT
    [[ "$RM_SSL_INPUT" =~ [Yy] ]] && RM_SSL=true
  else
    echo -e -n "* Do you want to clean up any Certbot / Let's Encrypt SSL files? (y/N): "
    read -r RM_SSL_INPUT
    [[ "$RM_SSL_INPUT" =~ [Yy] ]] && RM_SSL=true
  fi

  if [ "$RM_PANEL" == false ] && [ "$RM_WINGS" == false ] && [ "$RM_SSL" == false ]; then
    error "Nothing selected to uninstall! System was not modified."
    exit 1
  fi

  summary

  # confirm uninstallation
  echo -e -n "* Are you sure you want to proceed with uninstallation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    run_installer "uninstall"
  else
    error "Uninstallation aborted."
    exit 1
  fi
}

summary() {
  print_brake 40
  output "Uninstall panel? $RM_PANEL"
  output "Uninstall wings? $RM_WINGS"
  output "Remove SSL certificates? $RM_SSL"
  print_brake 40
}

goodbye() {
  print_brake 62
  [ "$RM_PANEL" == true ] && output "Panel uninstallation and cleanup completed."
  [ "$RM_WINGS" == true ] && output "Wings uninstallation and cleanup completed."
  [ "$RM_SSL" == true ] && output "Let's Encrypt / Certbot SSL cleanup completed."
  output "Thank you for using this script."
  print_brake 62
}

main
goodbye
