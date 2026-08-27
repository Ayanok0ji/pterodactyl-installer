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

RM_PANEL="${RM_PANEL:-false}"
RM_WINGS="${RM_WINGS:-false}"
RM_SSL="${RM_SSL:-false}"

# ---------- Uninstallation functions ---------- #

rm_panel_files() {
  output "Removing panel files..."
  rm -rf /var/www/pterodactyl

  case "$OS" in
  debian | ubuntu)
    [ -L /etc/nginx/sites-enabled/pterodactyl.conf ] && rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    [ -f /etc/nginx/sites-available/pterodactyl.conf ] && rm -f /etc/nginx/sites-available/pterodactyl.conf
    [ ! -L /etc/nginx/sites-enabled/default ] && [ -f /etc/nginx/sites-available/default ] && ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    ;;
  rocky | almalinux | centos)
    [ -f /etc/nginx/conf.d/pterodactyl.conf ] && rm -f /etc/nginx/conf.d/pterodactyl.conf
    ;;
  esac

  systemctl restart nginx 2>/dev/null || true
  success "Removed panel files and webserver configuration."
}

rm_docker_containers() {
  output "Removing docker containers and images..."

  if [ -x "$(command -v docker)" ]; then
    local containers
    containers=$(docker ps -aq 2>/dev/null || true)
    if [ -n "$containers" ]; then
      output "Stopping running containers..."
      docker stop $containers 2>/dev/null || true
      output "Removing containers..."
      docker rm -f $containers 2>/dev/null || true
    fi
    docker system prune -a -f --volumes 2>/dev/null || true
  fi

  success "Removed docker containers and images."
}

rm_wings_files() {
  output "Removing wings files..."

  systemctl stop wings 2>/dev/null || true
  systemctl disable --now wings 2>/dev/null || true
  [ -f /etc/systemd/system/wings.service ] && rm -f /etc/systemd/system/wings.service
  systemctl daemon-reload 2>/dev/null || true

  [ -d /etc/pterodactyl ] && rm -rf /etc/pterodactyl
  [ -f /usr/local/bin/wings ] && rm -rf /usr/local/bin/wings
  [ -d /var/lib/pterodactyl ] && rm -rf /var/lib/pterodactyl
  [ -d /tmp/pterodactyl ] && rm -rf /tmp/pterodactyl

  success "Removed wings files and systemd service."
}

rm_services() {
  output "Removing services..."

  systemctl stop pteroq 2>/dev/null || true
  systemctl disable --now pteroq 2>/dev/null || true
  [ -f /etc/systemd/system/pteroq.service ] && rm -f /etc/systemd/system/pteroq.service
  systemctl daemon-reload 2>/dev/null || true

  case "$OS" in
  debian | ubuntu)
    systemctl stop redis-server 2>/dev/null || true
    ;;
  rocky | almalinux | centos)
    systemctl stop redis 2>/dev/null || true
    systemctl stop php-fpm 2>/dev/null || true
    [ -f /etc/php-fpm.d/www-pterodactyl.conf ] && rm -f /etc/php-fpm.d/www-pterodactyl.conf
    ;;
  esac

  success "Removed services."
}

rm_cron() {
  output "Removing cron jobs..."
  if crontab -l 2>/dev/null | grep -q "artisan schedule:run"; then
    crontab -l 2>/dev/null | grep -vF "artisan schedule:run" | crontab - 2>/dev/null || true
  fi
  success "Removed cron jobs."
}

rm_database() {
  output "Checking for database..."
  local db_cmd="mariadb"
  type mariadb >/dev/null 2>&1 || db_cmd="mysql"

  if ! type "$db_cmd" >/dev/null 2>&1; then
    output "Database client ($db_cmd) not found, skipping database removal."
    return
  fi

  local valid_db
  valid_db=$($db_cmd -u root -e "SELECT schema_name FROM information_schema.schemata;" 2>/dev/null | grep -v -E -- 'schema_name|information_schema|performance_schema|mysql' || true)
  if [[ -z "$valid_db" ]]; then
    warning "No valid databases found."
    return
  fi

  warning "Be careful! Selected database will be permanently deleted!"
  local DATABASE=""
  if [[ "$valid_db" == *"panel"* ]]; then
    echo -n "* Database called 'panel' was detected. Delete this database? (y/N): "
    read -r is_panel
    if [[ "$is_panel" =~ [Yy] ]]; then
      DATABASE=panel
    else
      print_list "$valid_db"
    fi
  else
    print_list "$valid_db"
  fi

  while [ -z "$DATABASE" ]; do
    echo -n "* Enter database name to delete (or press Enter to skip): "
    read -r database_input
    if [[ -n "$database_input" ]]; then
      if [[ "$valid_db" == *"$database_input"* ]]; then
        DATABASE="$database_input"
      else
        warning "Invalid database name. Try again."
      fi
    else
      break
    fi
  done

  if [[ -n "$DATABASE" ]]; then
    $db_cmd -u root -e "DROP DATABASE \`$DATABASE\`;" 2>/dev/null && success "Database '$DATABASE' dropped." || warning "Failed to drop database '$DATABASE'."
  else
    output "No database selected, skipping database removal."
  fi

  output "Checking for database user..."
  local valid_users
  valid_users=$($db_cmd -u root -e "SELECT user FROM mysql.user;" 2>/dev/null | grep -v -E -- 'user|root' || true)
  if [[ -z "$valid_users" ]]; then
    warning "No database users found to remove."
    return
  fi

  warning "Be careful! Selected database user will be deleted!"
  local DB_USER=""
  if [[ "$valid_users" == *"pterodactyl"* ]]; then
    echo -n "* Database user 'pterodactyl' was detected. Delete this user? (y/N): "
    read -r is_user
    if [[ "$is_user" =~ [Yy] ]]; then
      DB_USER=pterodactyl
    else
      print_list "$valid_users"
    fi
  else
    print_list "$valid_users"
  fi

  while [ -z "$DB_USER" ]; do
    echo -n "* Enter database username to delete (or press Enter to skip): "
    read -r user_input
    if [[ -n "$user_input" ]]; then
      if [[ "$valid_users" == *"$user_input"* ]]; then
        DB_USER=$user_input
      else
        warning "Invalid username. Try again."
      fi
    else
      break
    fi
  done

  if [[ -n "$DB_USER" ]]; then
    $db_cmd -u root -e "DROP USER '$DB_USER'@'127.0.0.1';" 2>/dev/null || true
    $db_cmd -u root -e "DROP USER '$DB_USER'@'%';" 2>/dev/null || true
    $db_cmd -u root -e "DROP USER '$DB_USER'@'localhost';" 2>/dev/null || true
    $db_cmd -u root -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    success "Database user '$DB_USER' removed."
  else
    output "No user selected, skipping user removal."
  fi
}

rm_ssl() {
  output "Removing Let's Encrypt / Certbot SSL certificates..."
  if [ -d "/etc/letsencrypt" ]; then
    if [ -x "$(command -v certbot)" ]; then
      certbot certificates 2>/dev/null | grep "Certificate Name:" | awk '{print $3}' | while read -r cert_name; do
        if [ -n "$cert_name" ]; then
          certbot delete --cert-name "$cert_name" --non-interactive 2>/dev/null || true
        fi
      done
    fi
    rm -rf /etc/letsencrypt/live
    rm -rf /etc/letsencrypt/archive
    rm -rf /etc/letsencrypt/renewal
    rm -rf /etc/letsencrypt/renewal-hooks
    rm -rf /etc/letsencrypt
    rm -rf /var/log/letsencrypt
    success "Removed Let's Encrypt / Certbot SSL certificates."
  else
    output "No Let's Encrypt certificates directory found."
  fi
}

# --------------- Main functions --------------- #

perform_uninstall() {
  [ "$RM_PANEL" == true ] && rm_panel_files
  [ "$RM_PANEL" == true ] && rm_cron
  [ "$RM_PANEL" == true ] && rm_database
  [ "$RM_PANEL" == true ] && rm_services
  [ "$RM_WINGS" == true ] && rm_docker_containers
  [ "$RM_WINGS" == true ] && rm_wings_files
  [ "$RM_SSL" == true ] && rm_ssl

  return 0
}

# ------------------ Uninstall ----------------- #

perform_uninstall
