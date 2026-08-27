#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'pterodactyl-installer'                                                    #
#                                                                                    #
# Copyright (C) 2018 - 2026, Vilhelm Prytz, <vilhelm@prytznet.se>                    #
# Fork modifications Copyright (C) 2026, Ayanok0ji <https://github.com/Ayanok0ji>    #
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
# https://github.com/pterodactyl-installer/pterodactyl-installer/blob/master/LICENSE #
#                                                                                    #
# This script is not associated with the official Pterodactyl Project.               #
# https://github.com/pterodactyl-installer/pterodactyl-installer                     #
# Fork: https://github.com/Ayanok0ji/pterodactyl-installer                           #
# Original project CCTO: Vilhelm Prytz & contributors                                #
# Original one-liner: bash <(curl -s https://pterodactyl-installer.se)               #
#              ^ NOT owned by Ayanok0ji. This fork is maintained by Ayanok0ji.       #
#              Use this fork via: bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh) #
#                                                                                    #
######################################################################################

export GITHUB_SOURCE="main"
export SCRIPT_RELEASE="main"
# Fork default: Ayanok0ji's repo branch main. Upstream: https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer
export GITHUB_BASE_URL="${GITHUB_BASE_URL:-https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer}"
# To use upstream instead: export GITHUB_BASE_URL="https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer"

LOG_PATH="/var/log/pterodactyl-installer.log"

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# Helper to check if function exists (needed before lib.sh is fully loaded)
fn_exists() { declare -F "$1" >/dev/null 2>&1; }

# Always remove lib.sh, before downloading it
[ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh

# Try to download lib.sh from fork - try plain and refs/heads forms (GitHub raw needs refs/heads/main sometimes)
if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh" 2>/dev/null; then
  if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/master/lib/lib.sh" 2>/dev/null; then
    if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/main/lib/lib.sh" 2>/dev/null; then
      if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/main/lib/lib.sh" 2>/dev/null; then
        if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/master/lib/lib.sh" 2>/dev/null; then
          curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/$GITHUB_SOURCE/lib/lib.sh" 2>/dev/null || true
        fi
      fi
    fi
  fi
fi

# If fork lib.sh still missing (404), fallback to upstream (ensures installer always works)
if [ ! -s /tmp/lib.sh ] || grep -q "404" /tmp/lib.sh 2>/dev/null; then
  echo "* Warning: fork lib.sh not found at $GITHUB_BASE_URL, falling back to upstream..."
  rm -rf /tmp/lib.sh
  curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/$GITHUB_SOURCE/lib/lib.sh" 2>/dev/null || \
  curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/lib/lib.sh" 2>/dev/null || \
  curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/refs/heads/main/lib/lib.sh" 2>/dev/null || true
fi

# shellcheck source=lib/lib.sh
if [ -f /tmp/lib.sh ]; then
  # shellcheck disable=SC1090
  source /tmp/lib.sh || { echo "* ERROR: Could not load lib.sh"; cat /tmp/lib.sh; exit 1; }
else
  echo "* ERROR: Could not download lib.sh from $GITHUB_BASE_URL"
  exit 1
fi

# Verify lib loaded
if ! fn_exists lib_loaded; then
  echo "* ERROR: lib.sh loaded but lib_loaded not found - likely 404 HTML"
  cat /tmp/lib.sh
  exit 1
fi

# Allow user to pre-select Pterodactyl version via env var e.g. PTERODACTYL_VERSION=1.11.3
export PTERODACTYL_VERSION="${PTERODACTYL_VERSION:-}"

execute() {
  echo -e "\n\n* pterodactyl-installer $(date) \n\n" >>$LOG_PATH

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="canary"
  update_lib_source
  # Ensure PTERODACTYL_VERSION propagates to UI/installer (set URLs)
  if [[ -n "$PTERODACTYL_VERSION" ]]; then
    export PTERODACTYL_VERSION
    set_pterodactyl_urls 2>/dev/null || true
  fi
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
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option" && continue

  if [[ " ${valid_input[*]} " =~ ${action} ]]; then
    # ---- Pterodactyl version selection (fork by Ayanok0ji) ----
    # Skip version prompt for uninstall
    if [[ "${actions[$action]}" != *"uninstall"* ]]; then
      # Use lib helper to list ALL versions with menu (supports any version)
      if fn_exists ask_pterodactyl_version; then
        echo ""
        ask_pterodactyl_version
        echo ""
      else
        # Fallback if lib helper missing
        if [[ -z "$PTERODACTYL_VERSION" ]]; then
          echo ""
          output "Version selection: panel & wings will use SAME version. Any tag allowed."
          echo -n "* Enter Pterodactyl version [latest] (e.g., 1.11.3, 1.11.1, v1.11.3): "
          read -r PTERODACTYL_VERSION_INPUT
          if [ -z "$PTERODACTYL_VERSION_INPUT" ]; then
            export PTERODACTYL_VERSION="latest"
          else
            export PTERODACTYL_VERSION="$PTERODACTYL_VERSION_INPUT"
          fi
          PTERODACTYL_VERSION="$(echo "$PTERODACTYL_VERSION" | tr -d '[:space:]')"
          [[ "$PTERODACTYL_VERSION" != "latest" && "$PTERODACTYL_VERSION" != v* ]] && export PTERODACTYL_VERSION="v$PTERODACTYL_VERSION"
          output "Selected version: $PTERODACTYL_VERSION"
          echo ""
        fi
      fi
    fi
    done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
  fi
done

# Remove lib.sh, so next time the script is run the, newest version is downloaded.
rm -rf /tmp/lib.sh
