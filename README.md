# :bird: pterodactyl-installer

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Ayanok0ji/pterodactyl-installer?include_prereleases)](https://github.com/Ayanok0ji/pterodactyl-installer/releases)
[![made-with-bash](https://img.shields.io/badge/-Made%20with%20Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

Unofficial scripts for installing Pterodactyl Panel & Wings with **custom version selection** support (e.g. `1.11.3`, `1.11.1`, `latest`, or any release) and a **full uninstaller**.

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

---

## Credits to Owner (CCTO) & Attribution ✨

> [!NOTE]
> This repository is a customized fork maintained by [Ayanok0ji](https://github.com/Ayanok0ji).
> 
> **Credits to Owner (CCTO)**:
> - Originally created by **[Vilhelm Prytz](https://github.com/vilhelmprytz)** (`<vilhelm@prytznet.se>`) and contributors at **[pterodactyl-installer/pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer)**.
> - Distributed under the **GNU General Public License v3.0 (GPLv3)**.
> - Full credit goes to the original authors and maintainers for the core installer framework.

---

## Features

- **Select Any Version**: Choose specific versions for Pterodactyl Panel and Wings (e.g. `1.11.3`, `1.11.1`, `latest`).
- **Synchronized Dual Install**: Installing Panel & Wings together automatically matches their versions.
- **Automatic Panel Setup**: Installs PHP 8.3, Composer, MariaDB, Nginx, Redis, artisan queue (`pteroq`), and cron jobs.
- **Automatic Wings Setup**: Configures Docker engine, systemd service, and kernel requirements.
- **Let's Encrypt / Certbot**: Automated SSL certificate generation for domain names.
- **Firewall Integration**: Optional UFW / FirewallD configuration for required ports.
- **Full Uninstaller**: Complete uninstallation of Panel, Wings, Docker containers/volumes, database, and Let's Encrypt / Certbot SSL certificates.

---

## Commands & Usage

> [!IMPORTANT]
> Run all commands as **root** on your server.

### 1. Main Installer Menu (Install Panel, Wings, Both, or Uninstall)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/main/install.sh)
```

---

### 2. Standalone Panel Installer

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/main/ui/panel.sh)
```

---

### 3. Standalone Wings Installer

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/main/ui/wings.sh)
```

---

### 4. Standalone Full Uninstaller (Panel, Wings & SSL Cleanup)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/main/ui/uninstall.sh)
```

---

## Supported Operating Systems

| Operating System | Version | Supported | PHP Version |
| :--- | :--- | :---: | :---: |
| **Ubuntu** | 24.04 | :white_check_mark: | 8.3 |
| | 22.04 | :white_check_mark: | 8.3 |
| | 20.04 | :red_circle: \* | |
| | 18.04 | :red_circle: \* | |
| **Debian** | 13 | :white_check_mark: | 8.3 |
| | 12 | :white_check_mark: | 8.3 |
| | 11 | :white_check_mark: | 8.3 |
| | 10 | :white_check_mark: | 8.3 |
| **Rocky Linux** | 9 | :white_check_mark: | 8.3 |
| | 8 | :white_check_mark: | 8.3 |
| **AlmaLinux** | 9 | :white_check_mark: | 8.3 |
| | 8 | :white_check_mark: | 8.3 |

_\* Indicates an operating system and release that previously was supported by this script._

---

## Firewall Setup

The installation scripts can automatically install and configure your firewall (UFW on Debian/Ubuntu or FirewallD on Rocky/AlmaLinux). The script will prompt whether you want automatic configuration:

- **Panel**: Ports `80` (HTTP), `443` (HTTPS), `22` (SSH).
- **Wings**: Ports `8080` (Wings Daemon), `2022` (Wings SFTP), `22` (SSH).

---

## Original Project Contributors ✨

Copyright (C) 2018 - 2026, Vilhelm Prytz, <vilhelm@prytznet.se>, and contributors!

- Created by [Vilhelm Prytz](https://github.com/vilhelmprytz)
- Maintained by [Linux123123](https://github.com/Linux123123)
- Customizations by [Ayanok0ji](https://github.com/Ayanok0ji)
