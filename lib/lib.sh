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
# Original project: https://github.com/pterodactyl-installer/pterodactyl-installer   #
# Original one-liner: bash <(curl -s https://pterodactyl-installer.se)               #
#              NOT affiliated with this fork. This fork is maintained by Ayanok0ji.  #
#                                                                                    #
######################################################################################

# ------------------ Variables ----------------- #

# Versioning
export GITHUB_SOURCE=${GITHUB_SOURCE:-master}
export SCRIPT_RELEASE=${SCRIPT_RELEASE:-canary}

# Pterodactyl versions - user selectable (e.g., 1.11.3, v1.11.3, or latest)
# PTERODACTYL_VERSION is the unified version used for both panel & wings (user request)
export PTERODACTYL_VERSION="${PTERODACTYL_VERSION:-}"
export PTERODACTYL_PANEL_VERSION=""
export PTERODACTYL_WINGS_VERSION=""

# Path (export everything that is possible, doesn't matter that it exists already)
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# OS
export OS=""
export OS_VER_MAJOR=""
export CPU_ARCHITECTURE=""
export ARCH=""
export SUPPORTED=false

# download URLs
export PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
export WINGS_DL_BASE_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_"
export MARIADB_URL="https://downloads.mariadb.com/MariaDB/mariadb_repo_setup"
# Fork default: Ayanok0ji ; upstream: https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer
export GITHUB_BASE_URL=${GITHUB_BASE_URL:-"https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer"}
export GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"

# Colors
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

# email input validation regex
email_regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

# Charset used to generate random passwords
password_charset='A-Za-z0-9!"#%&()*+,-./:;<=>?@[\]^_`{|}~'

# --------------------- Lib -------------------- #

lib_loaded() {
  return 0
}

# -------------- Visual functions -------------- #

output() {
  echo -e "* $1"
}

success() {
  echo ""
  output "${COLOR_GREEN}SUCCESS${COLOR_NC}: $1"
  echo ""
}

error() {
  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1" 1>&2
  echo ""
}

warning() {
  echo ""
  output "${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_list() {
  print_brake 30
  for word in $1; do
    output "$word"
  done
  print_brake 30
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

# ---------------- Version helpers --------------- #

# Normalize version input: latest -> latest, 1.11.3 -> v1.11.3, v1.11.3 -> v1.11.3
normalize_version() {
  local ver="$1"
  ver="$(echo "$ver" | tr -d '[:space:]')"
  if [[ -z "$ver" || "$ver" == "latest" ]]; then
    echo "latest"
    return
  fi
  [[ "$ver" != v* ]] && ver="v$ver"
  echo "$ver"
}

# Set PANEL_DL_URL / WINGS_DL_BASE_URL based on PTERODACTYL_VERSION
# Supports unified version (PTERODACTYL_VERSION) and separate overrides
set_pterodactyl_urls() {
  # Allow separate overrides: PTERODACTYL_PANEL_VERSION / PTERODACTYL_WINGS_VERSION
  # If they are set individually, use them; otherwise use unified PTERODACTYL_VERSION
  local panel_ver wings_ver unified_ver
  unified_ver="$(normalize_version "${PTERODACTYL_VERSION:-latest}")"
  export PTERODACTYL_VERSION="$unified_ver"

  # Panel version resolution
  if [[ -n "${PTERODACTYL_PANEL_VERSION:-}" && "$PTERODACTYL_PANEL_VERSION" != "" ]]; then
    panel_ver="$(normalize_version "$PTERODACTYL_PANEL_VERSION")"
  else
    panel_ver="$unified_ver"
  fi
  # Wings version resolution
  if [[ -n "${PTERODACTYL_WINGS_VERSION:-}" && "$PTERODACTYL_WINGS_VERSION" != "" ]]; then
    wings_ver="$(normalize_version "$PTERODACTYL_WINGS_VERSION")"
  else
    wings_ver="$unified_ver"
  fi

  export PTERODACTYL_PANEL_VERSION="$panel_ver"
  export PTERODACTYL_WINGS_VERSION="$wings_ver"

  if [[ "$panel_ver" == "latest" ]]; then
    export PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
  else
    export PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/download/$panel_ver/panel.tar.gz"
  fi

  if [[ "$wings_ver" == "latest" ]]; then
    export WINGS_DL_BASE_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_"
  else
    export WINGS_DL_BASE_URL="https://github.com/pterodactyl/wings/releases/download/$wings_ver/wings_linux_"
  fi

  # Keep unified var in sync if both same; otherwise keep as is
  if [[ "$panel_ver" == "$wings_ver" ]]; then
    export PTERODACTYL_VERSION="$panel_ver"
  fi
}

# Fetch available Pterodactyl versions (panel releases) - returns newline separated tags
get_available_versions() {
  local api_url="https://api.github.com/repos/pterodactyl/panel/releases?per_page=40"
  local tags
  tags=$(curl -sL "$api_url" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [[ -z "$tags" ]]; then
    return 1
  fi
  echo "$tags"
  return 0
}

# Prompt user to select Pterodactyl version (panel & wings same version)
# Supports: menu selection [0]=latest, [1..N]=tags, or manual input like 1.11.3 / v1.11.3
ask_pterodactyl_version() {
  # If already set via env (e.g., PTERODACTYL_VERSION=1.11.3 bash install.sh), just apply and return
  if [[ -n "$PTERODACTYL_VERSION" && "$PTERODACTYL_VERSION" != "" ]]; then
    set_pterodactyl_urls
    output "Using Pterodactyl version: $PTERODACTYL_VERSION (pre-selected via env)"
    if [[ "$PTERODACTYL_VERSION" != "latest" ]]; then
      output "Panel: $PTERODACTYL_PANEL_VERSION -> $PANEL_DL_URL"
      output "Wings: $PTERODACTYL_WINGS_VERSION -> ${WINGS_DL_BASE_URL}${ARCH}"
    fi
    return
  fi

  output "Pterodactyl version selection - you can install ANY version"
  output "Panel & Wings will use the SAME version by default (e.g., 1.11.3)"
  output ""

  # Try to fetch list from GitHub
  local versions_list=()
  local fetched=""
  output "Fetching available versions from GitHub..."
  if fetched=$(get_available_versions 2>/dev/null); then
    # Convert to array
    readarray -t versions_list <<<"$fetched"
    # Filter: keep only tags that look like versions (allow vX.Y.Z or vX.Y.Z-*)
    # but keep all for now, limit to 30
    if [[ ${#versions_list[@]} -gt 0 ]]; then
      output "Available versions (showing up to 30 recent):"
      output "[0] latest  (recommended - always newest stable)"
      local i=1
      for ver in "${versions_list[@]}"; do
        # limit display
        if [[ $i -gt 30 ]]; then break; fi
        output "[$i] $ver"
        i=$((i+1))
      done
      output ""
      output "You can: type number [0-30], or type custom like 1.11.3 / v1.11.3 / 1.11.1 / v1.12.0-rc1, or 'latest'"
      echo -n "* Choose version [0] or type version [latest]: "
      read -r version_input
      version_input="$(echo "$version_input" | tr -d '[:space:]')"

      if [ -z "$version_input" ]; then
        version_input="latest"
      fi

      # If input is purely numeric, treat as menu selection
      if [[ "$version_input" =~ ^[0-9]+$ ]]; then
        local sel=$version_input
        if [[ $sel -eq 0 ]]; then
          version_input="latest"
        elif [[ $sel -ge 1 && $sel -le ${#versions_list[@]} && $sel -le 30 ]]; then
          version_input="${versions_list[$((sel-1))]}"
        else
          warning "Selection $sel out of range, defaulting to 'latest'"
          version_input="latest"
        fi
      fi
      # Otherwise treat input as direct version string - accept ANY format (relaxed)
      # Normalize later
    else
      # fallback manual
      output "No versions fetched, falling back to manual input"
      echo -n "* Enter Pterodactyl version [latest] (e.g., 1.11.3, v1.11.1, any tag): "
      read -r version_input
      version_input="$(echo "$version_input" | tr -d '[:space:]')"
      [ -z "$version_input" ] && version_input="latest"
    fi
  else
    warning "Could not fetch version list (API rate limit or offline). Manual input only."
    echo -n "* Enter Pterodactyl version [latest] (e.g., 1.11.3, v1.11.1, any tag): "
    read -r version_input
    version_input="$(echo "$version_input" | tr -d '[:space:]')"
    [ -z "$version_input" ] && version_input="latest"
  fi

  export PTERODACTYL_VERSION="$version_input"
  set_pterodactyl_urls
  if [[ "$PTERODACTYL_VERSION" == "latest" ]]; then
    output "Selected version: latest"
    output "Panel URL: $PANEL_DL_URL"
    output "Wings URL: ${WINGS_DL_BASE_URL}${ARCH}"
  else
    output "Selected Pterodactyl version: $PTERODACTYL_VERSION (panel + wings)"
    output "Panel: $PTERODACTYL_PANEL_VERSION -> $PANEL_DL_URL"
    output "Wings: $PTERODACTYL_WINGS_VERSION -> ${WINGS_DL_BASE_URL}${ARCH}"
    if [[ "$PTERODACTYL_PANEL_VERSION" != "$PTERODACTYL_WINGS_VERSION" ]]; then
      warning "Panel and Wings versions differ - ensure they are compatible!"
    fi
  fi
}

# First argument is wings / panel / neither
welcome() {
  # Ensure URLs reflect any pre-selected version before fetching latest
  if [[ -n "$PTERODACTYL_VERSION" && "$PTERODACTYL_VERSION" != "latest" ]]; then
    set_pterodactyl_urls
  fi

  get_latest_versions

  print_brake 70
  output "Pterodactyl panel installation script @ $SCRIPT_RELEASE"
  output ""
  output "Copyright (C) 2018 - 2026, Vilhelm Prytz, <vilhelm@prytznet.se>"
  output "Fork by Ayanok0ji (https://github.com/Ayanok0ji) - version selection added"
  output "Original: https://github.com/pterodactyl-installer/pterodactyl-installer"
  output "Original one-liner bash <(curl -s https://pterodactyl-installer.se) is NOT this fork"
  output ""
  output "This script is not associated with the official Pterodactyl Project."
  output ""
  output "Running $OS version $OS_VER."
  if [ "$1" == "panel" ]; then
    if [[ "$PTERODACTYL_VERSION" != "latest" && -n "$PTERODACTYL_VERSION" ]]; then
      output "Selected pterodactyl/panel version: $PTERODACTYL_PANEL_VERSION (selected)"
      output "Latest pterodactyl/panel is $(get_latest_release "pterodactyl/panel" 2>/dev/null || echo "unknown")"
    else
      output "Latest pterodactyl/panel is $PTERODACTYL_PANEL_VERSION"
    fi
  elif [ "$1" == "wings" ]; then
    if [[ "$PTERODACTYL_VERSION" != "latest" && -n "$PTERODACTYL_VERSION" ]]; then
      output "Selected pterodactyl/wings version: $PTERODACTYL_WINGS_VERSION (selected)"
      output "Latest pterodactyl/wings is $(get_latest_release "pterodactyl/wings" 2>/dev/null || echo "unknown")"
    else
      output "Latest pterodactyl/wings is $PTERODACTYL_WINGS_VERSION"
    fi
  else
    if [[ -n "$PTERODACTYL_VERSION" && "$PTERODACTYL_VERSION" != "latest" ]]; then
      output "Selected Pterodactyl version: $PTERODACTYL_VERSION (panel & wings)"
    fi
  fi
  print_brake 70
}

# ---------------- Lib functions --------------- #

get_latest_release() {
  curl -sL "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                       # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                               # Pluck JSON value
}

get_latest_versions() {
  output "Retrieving release information..."
  # If user already selected a specific version, keep it and just set URLs
  if [[ -n "$PTERODACTYL_VERSION" && "$PTERODACTYL_VERSION" != "latest" ]]; then
    local normalized
    normalized="$(normalize_version "$PTERODACTYL_VERSION")"
    export PTERODACTYL_VERSION="$normalized"
    export PTERODACTYL_PANEL_VERSION="$normalized"
    export PTERODACTYL_WINGS_VERSION="$normalized"
    set_pterodactyl_urls
    return
  fi
  PTERODACTYL_PANEL_VERSION=$(get_latest_release "pterodactyl/panel")
  PTERODACTYL_WINGS_VERSION=$(get_latest_release "pterodactyl/wings")
  # Ensure latest URLs are set
  set_pterodactyl_urls
}

update_lib_source() {
  GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"
  rm -rf /tmp/lib.sh
  if ! curl -fSsL -o /tmp/lib.sh "$GITHUB_URL/lib/lib.sh" 2>/dev/null; then
    # fallback try master/main and refs/heads variants
    curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/master/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/main/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/main/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/master/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "$GITHUB_BASE_URL/refs/heads/$GITHUB_SOURCE/lib/lib.sh" 2>/dev/null || true
  fi
  if [ ! -s /tmp/lib.sh ] || grep -q "404" /tmp/lib.sh 2>/dev/null; then
    echo "* Warning: lib.sh not found at $GITHUB_URL, trying upstream..."
    curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/$GITHUB_SOURCE/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/lib/lib.sh" 2>/dev/null || \
    curl -fSsL -o /tmp/lib.sh "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/refs/heads/main/lib/lib.sh" 2>/dev/null || true
  fi
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh
}

run_installer() {
  local url="$GITHUB_URL/installers/$1.sh"
  bash <(curl -fSsL "$url" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/main/installers/$1.sh" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/refs/heads/main/installers/$1.sh" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/refs/heads/$GITHUB_SOURCE/installers/$1.sh" 2>/dev/null || curl -fSsL "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/installers/$1.sh" 2>/dev/null || curl -sSL "$url")
}

run_ui() {
  local url="$GITHUB_URL/ui/$1.sh"
  bash <(curl -fSsL "$url" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/main/ui/$1.sh" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/refs/heads/main/ui/$1.sh" 2>/dev/null || curl -fSsL "$GITHUB_BASE_URL/refs/heads/$GITHUB_SOURCE/ui/$1.sh" 2>/dev/null || curl -fSsL "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/ui/$1.sh" 2>/dev/null || curl -sSL "$url")
}

# Helper to fetch any file from GITHUB_URL with fallback to refs/heads and upstream
github_fetch() {
  local src_path="$1"
  local dest="$2"
  for base in "$GITHUB_URL" "$GITHUB_BASE_URL/main" "$GITHUB_BASE_URL/refs/heads/main" "$GITHUB_BASE_URL/master" "$GITHUB_BASE_URL/refs/heads/master" "$GITHUB_BASE_URL/refs/heads/$GITHUB_SOURCE" "$GITHUB_BASE_URL/$GITHUB_SOURCE"; do
    if curl -fSsL -o "$dest" "$base/$src_path" 2>/dev/null && [ -s "$dest" ] && ! grep -q "404" "$dest" 2>/dev/null; then
      return 0
    fi
  done
  # upstream final fallback
  if curl -fSsL -o "$dest" "https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/$src_path" 2>/dev/null && [ -s "$dest" ]; then
    return 0
  fi
  return 1
}

array_contains_element() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

valid_email() {
  [[ $1 =~ ${email_regex} ]]
}

invalid_ip() {
  ip route get "$1" >/dev/null 2>&1
  echo $?
}

gen_passwd() {
  local length=$1
  local password=""
  while [ ${#password} -lt "$length" ]; do
    password=$(echo "$password""$(head -c 100 /dev/urandom | LC_ALL=C tr -dc "$password_charset")" | fold -w "$length" | head -n 1)
  done
  echo "$password"
}

# -------------------- MYSQL ------------------- #

create_db_user() {
  local db_user_name="$1"
  local db_user_password="$2"
  local db_host="${3:-127.0.0.1}"

  output "Creating database user $db_user_name..."

  mariadb -u root -e "CREATE USER '$db_user_name'@'$db_host' IDENTIFIED BY '$db_user_password';"
  mariadb -u root -e "FLUSH PRIVILEGES;"

  output "Database user $db_user_name created"
}

grant_all_privileges() {
  local db_name="$1"
  local db_user_name="$2"
  local db_host="${3:-127.0.0.1}"

  output "Granting all privileges on $db_name to $db_user_name..."

  mariadb -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user_name'@'$db_host' WITH GRANT OPTION;"
  mariadb -u root -e "FLUSH PRIVILEGES;"

  output "Privileges granted"

}

create_db() {
  local db_name="$1"
  local db_user_name="$2"
  local db_host="${3:-127.0.0.1}"

  output "Creating database $db_name..."

  mariadb -u root -e "CREATE DATABASE $db_name;"
  grant_all_privileges "$db_name" "$db_user_name" "$db_host"

  output "Database $db_name created"
}

# --------------- Package Manager -------------- #

update_repos() {
  local args=""
  
  [[ "$1" == true ]] && args="-qq"

  case "$OS" in
    ubuntu | debian)
      output "Updating package repositories..."
      if ! apt-get update -y $args; then
        error "Failed to update repositories."
        return 1
      fi
      ;;
    centos | almalinux | rockylinux)
      # Skip since these distros auto-refresh metadata
      output "Skipping repository update (handled automatically on $OS)."
      ;;
    *)
      warning "Unsupported OS: $OS — skipping repository update."
      ;;
  esac
}


# First argument list of packages to install, second argument for quite mode
install_packages() {
  local args=""
  if [[ $2 == true ]]; then
    case "$OS" in
    ubuntu | debian) args="-qq" ;;
    *) args="-q" ;;
    esac
  fi

  # Eval needed for proper expansion of arguments
  case "$OS" in
  ubuntu | debian)
    eval apt-get -y $args install "$1"
    ;;
  rocky | almalinux)
    eval dnf -y $args install "$1"
    ;;
  esac
}

# ------------ User input functions ------------ #

required_input() {
  local __resultvar=$1
  local result=''

  while [ -z "$result" ]; do
    echo -n "* ${2}"
    read -r result

    if [ -z "${3}" ]; then
      [ -z "$result" ] && result="${4}"
    else
      [ -z "$result" ] && error "${3}"
    fi
  done

  eval "$__resultvar="'$result'""
}

email_input() {
  local __resultvar=$1
  local result=''

  while ! valid_email "$result"; do
    echo -n "* ${2}"
    read -r result

    valid_email "$result" || error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local __resultvar=$1
  local result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    # modified from https://stackoverflow.com/a/22940001
    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && {
        printf '\n'
        break
      }                               # ENTER pressed; output \n and break.
      if [[ $char == $'\x7f' ]]; then # backspace was pressed
        # Only if variable is not empty
        if [ -n "$result" ]; then
          # Remove last char from output variable.
          [[ -n $result ]] && result=${result%?}
          # Erase '*' to the left.
          printf '\b \b'
        fi
      else
        # Add typed char to output variable.  [ -z "$result" ] && [ -n "
        result+=$char
        # Print '*' in its stead.
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && error "${3}"
  done

  eval "$__resultvar="'$result'""
}

# ------------------ Firewall ------------------ #

ask_firewall() {
  local __resultvar=$1

  case "$OS" in
  ubuntu | debian)
    echo -e -n "* Do you want to automatically configure UFW (firewall)? (y/N): "
    read -r CONFIRM_UFW

    if [[ "$CONFIRM_UFW" =~ [Yy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  rocky | almalinux)
    echo -e -n "* Do you want to automatically configure firewall-cmd (firewall)? (y/N): "
    read -r CONFIRM_FIREWALL_CMD

    if [[ "$CONFIRM_FIREWALL_CMD" =~ [Yy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  esac
}

install_firewall() {
  case "$OS" in
  ubuntu | debian)
    output ""
    output "Installing Uncomplicated Firewall (UFW)"

    if ! [ -x "$(command -v ufw)" ]; then
      update_repos true
      install_packages "ufw" true
    fi

    ufw --force enable

    success "Enabled Uncomplicated Firewall (UFW)"

    ;;
  rocky | almalinux)

    output ""
    output "Installing FirewallD"+

    if ! [ -x "$(command -v firewall-cmd)" ]; then
      install_packages "firewalld" true
    fi

    systemctl --now enable firewalld >/dev/null

    success "Enabled FirewallD"

    ;;
  esac
}

firewall_allow_ports() {
  case "$OS" in
  ubuntu | debian)
    for port in $1; do
      ufw allow "$port"
    done
    ufw --force reload
    ;;
  rocky | almalinux)
    for port in $1; do
      firewall-cmd --zone=public --add-port="$port"/tcp --permanent
    done
    firewall-cmd --reload -q
    ;;
  esac
}

# ---------------- System checks --------------- #

# panel x86_64 check
check_os_x86_64() {
  if [ "${ARCH}" != "amd64" ]; then
    warning "Detected CPU architecture $CPU_ARCHITECTURE"
    warning "Using any other architecture than 64 bit (x86_64) will cause problems."

    echo -e -n "* Are you sure you want to proceed? (y/N):"
    read -r choice

    if [[ ! "$choice" =~ [Yy] ]]; then
      error "Installation aborted!"
      exit 1
    fi
  fi
}

# wings virtualization check
check_virt() {
  output "Installing virt-what..."

  update_repos true
  install_packages "virt-what" true

  # Export sbin for virt-what
  export PATH="$PATH:/sbin:/usr/sbin"

  virt_serv=$(virt-what)

  case "$virt_serv" in
  *openvz* | *lxc*)
    warning "Unsupported type of virtualization detected. Please consult with your hosting provider whether your server can run Docker or not. Proceed at your own risk."
    echo -e -n "* Are you sure you want to proceed? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      error "Installation aborted!"
      exit 1
    fi
    ;;
  *)
    [ "$virt_serv" != "" ] && warning "Virtualization: $virt_serv detected."
    ;;
  esac

  if uname -r | grep -q "xxxx"; then
    error "Unsupported kernel detected."
    exit 1
  fi

  success "System is compatible with docker"
}

# Exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  error "This script must be executed with root privileges."
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$(echo "$ID" | awk '{print tolower($0)}')
  OS_VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si | awk '{print tolower($0)}')
  OS_VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
  OS_VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS="debian"
  OS_VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
  # Older SuSE/etc.
  OS="SuSE"
  OS_VER="?"
elif [ -f /etc/redhat-release ]; then
  # Older Red Hat, CentOS, etc.
  OS="Red Hat/CentOS"
  OS_VER="?"
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  OS_VER=$(uname -r)
fi

OS=$(echo "$OS" | awk '{print tolower($0)}')
OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
CPU_ARCHITECTURE=$(uname -m)

case "$CPU_ARCHITECTURE" in
x86_64)
  ARCH=amd64
  ;;
arm64 | aarch64)
  ARCH=arm64
  ;;
*)
  error "Only x86_64 and arm64 are supported!"
  exit 1
  ;;
esac

case "$OS" in
ubuntu)
  [ "$OS_VER_MAJOR" == "22" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "24" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "26" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
debian)
  [ "$OS_VER_MAJOR" == "10" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "11" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "12" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "13" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
rocky | almalinux)
  [ "$OS_VER_MAJOR" == "8" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "9" ] && SUPPORTED=true
  ;;
*)
  SUPPORTED=false
  ;;
esac

# exit if not supported
if [ "$SUPPORTED" == false ]; then
  output "$OS $OS_VER is not supported"
  error "Unsupported OS"
  exit 1
fi
