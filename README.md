# :bird: pterodactyl-installer

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Ayanok0ji/pterodactyl-installer?include_prereleases)](https://github.com/Ayanok0ji/pterodactyl-installer/releases)
[![made-with-bash](https://img.shields.io/badge/-Made%20with%20Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

Unofficial scripts for installing Pterodactyl Panel & Wings with **custom version selection** support (e.g., `1.11.3`, `1.11.1`, `latest`, or any release).

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

## Credits to Owner (CCTO) & Attribution ✨

> [!NOTE]
> This repository is a customized fork maintained by [Ayanok0ji](https://github.com/Ayanok0ji).
> 
> **Credits to Owner (CCTO)**:
> - Originally created by **[Vilhelm Prytz](https://github.com/vilhelmprytz)** (`<vilhelm@prytznet.se>`) and contributors at **[pterodactyl-installer/pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer)**.
> - Distributed under the **GNU General Public License v3.0 (GPLv3)**.
> - Full credit goes to the original authors and maintainers for the core installer framework.

## Features

- **Select Any Version**: Choose specific versions for Pterodactyl Panel and Wings (e.g. `1.11.3`, `1.11.1`, `1.14.0`, or `latest`).
- Automatic installation of the Pterodactyl Panel (dependencies, database, cronjob, nginx).
- Automatic installation of the Pterodactyl Wings (Docker, systemd).
- Panel: (optional) automatic configuration of Let's Encrypt.
- Panel: (optional) automatic configuration of firewall.
- Uninstallation support for both panel and wings.

## Supported installations

List of supported installation setups for panel and Wings (installations supported by this installation script).

### Supported panel and wings operating systems

| Operating System | Version | Supported          | PHP Version |
| ---------------- | ------- | ------------------ | ----------- |
| Ubuntu           | 14.04   | :red_circle:       |             |
|                  | 16.04   | :red_circle: \*    |             |
|                  | 18.04   | :red_circle: \*    |             |
|                  | 20.04   | :red_circle: \*    |             |
|                  | 22.04   | :white_check_mark: | 8.3         |
|                  | 24.04   | :white_check_mark: | 8.3         |
|                  | 26.04   | :white_check_mark: | 8.3         |
| Debian           | 8       | :red_circle: \*    |             |
|                  | 9       | :red_circle: \*    |             |
|                  | 10      | :white_check_mark: | 8.3         |
|                  | 11      | :white_check_mark: | 8.3         |
|                  | 12      | :white_check_mark: | 8.3         |
|                  | 13      | :white_check_mark: | 8.3         |
| CentOS           | 6       | :red_circle:       |             |
|                  | 7       | :red_circle: \*    |             |
|                  | 8       | :red_circle: \*    |             |
| Rocky Linux      | 8       | :white_check_mark: | 8.3         |
|                  | 9       | :white_check_mark: | 8.3         |
| AlmaLinux        | 8       | :white_check_mark: | 8.3         |
|                  | 9       | :white_check_mark: | 8.3         |

_\* Indicates an operating system and release that previously was supported by this script._

## Using the installation scripts

To use the installation scripts, simply run this command as root:

```bash
bash <(curl -s https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/main/install.sh)
```

_Note: On some systems, it's required to be already logged in as root before executing the one-line command (where `sudo` is in front of the command does not work)._

## Firewall setup

The installation scripts can install and configure a firewall for you. The script will ask whether you want this or not. It is highly recommended to opt-in for the automatic firewall setup.

## Development & Ops

### Testing the script locally

To test the script, we use [Vagrant](https://www.vagrantup.com). With Vagrant, you can quickly get a fresh machine up and running to test the script.

```bash
vagrant up <name>
```

Replace `<name>` with one of the supported installations (e.g. `ubuntu_jammy`, `debian_bookworm`, `rockylinux_9`).

## Original Project Contributors ✨

Copyright (C) 2018 - 2026, Vilhelm Prytz, <vilhelm@prytznet.se>, and contributors!

- Created by [Vilhelm Prytz](https://github.com/vilhelmprytz)
- Maintained by [Linux123123](https://github.com/Linux123123)
- Customizations by [Ayanok0ji](https://github.com/Ayanok0ji)
