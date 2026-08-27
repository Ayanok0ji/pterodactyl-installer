# :bird: pterodactyl-installer — Fork by Ayanok0ji

[![License: GPL v3](https://img.shields.io/github/license/pterodactyl-installer/pterodactyl-installer)](LICENSE)
[![made-with-bash](https://img.shields.io/badge/-Made%20with%20Bash-1f425f.svg?logo=bash)](#)
[![Fork](https://img.shields.io/badge/fork-Ayanok0ji-blue)](https://github.com/Ayanok0ji/pterodactyl-installer)

> **CREDITS / CCTO / DISCLAIMER**
>
> This is a **fork** maintained by **[Ayanok0ji](https://github.com/Ayanok0ji)**.
>
> Original project: **[pterodactyl-installer/pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer)** by **Vilhelm Prytz** ([vilhelm@prytznet.se](mailto:vilhelm@prytznet.se)) and contributors, licensed under **GPL-3.0**.
>
> - Original one-liner `bash <(curl -s https://pterodactyl-installer.se)` and domain `https://pterodactyl-installer.se` are **NOT** owned by Ayanok0ji. CCTO / Credit to the original authors.
> - This fork is **NOT** associated with the official [Pterodactyl Project](https://pterodactyl.io/).
> - GPL-3.0 requires attribution and preservation of original copyright — see [LICENSE](LICENSE) and headers in each script.
>
> **Fork repo (this):** `https://github.com/Ayanok0ji/pterodactyl-installer` — please use the fork one-liner below.

Unofficial scripts for installing Pterodactyl Panel & Wings. **This fork adds version selection** — e.g. install Panel + Wings both at `1.11.3` or `1.11.1`, while keeping `latest` as default.

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

## ✨ What's new in this fork vs upstream

- **Version selection for Panel & Wings (same version)** — when you run the installer, it asks:
  ```
  * Enter Pterodactyl version [latest]: 1.11.3
  ```
  Enter `1.11.3`, `v1.11.3`, `1.11.1` for a pinned release, or press **ENTER** for `latest`. The same version is used for **both** panel and wings, as requested.
  - `latest` → `https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz` and `.../wings/releases/latest/download/wings_linux_<arch>`
  - `1.11.3` → `https://github.com/pterodactyl/panel/releases/download/v1.11.3/panel.tar.gz` and `.../wings/releases/download/v1.11.3/wings_linux_<arch>`
  - Supports env var for automation: `PTERODACTYL_VERSION=1.11.3 bash install.sh` or `PTERODACTYL_VERSION=v1.11.1 bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh)`
- **Fork attribution headers** in every script to avoid copyright confusion (GPL-3.0 compliant).
- Non-interactive / CI friendly — can pre-set version via env var.

## Features (upstream)

- Automatic installation of the Pterodactyl Panel (dependencies, database, cronjob, nginx).
- Automatic installation of the Pterodactyl Wings (Docker, systemd).
- Panel: (optional) automatic configuration of Let's Encrypt.
- Panel: (optional) automatic configuration of firewall.
- Uninstallation support for both panel and wings.

## Help and support

- For upstream help: [Discord Chat](https://pterodactyl-installer.se/discord) (original project).
- For this fork: open an issue at `https://github.com/Ayanok0ji/pterodactyl-installer/issues` or contact Ayanok0ji on GitHub.

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

### This fork (Ayanok0ji) — recommended if you want version selection

```bash
# Interactive — will prompt for version (e.g., 1.11.3, 1.11.1 or latest)
bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh)

# Non-interactive examples
PTERODACTYL_VERSION=1.11.3 bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh)
PTERODACTYL_VERSION=v1.11.1 bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh)
PTERODACTYL_VERSION=latest bash <(curl -sSL https://raw.githubusercontent.com/Ayanok0ji/pterodactyl-installer/master/install.sh)
```

The script will ask:

1. What to install: panel / wings / both
2. **Pterodactyl version** `[latest]` — type `1.11.3` or press ENTER for latest. For "both", the SAME version applies to panel + wings.

If the selected version does not exist (e.g., typo), the download will fail with a clear error and a link to `https://github.com/pterodactyl/panel/releases` and `https://github.com/pterodactyl/wings/releases`.

### Upstream (original, not this fork)

```bash
bash <(curl -s https://pterodactyl-installer.se)
```

> Note: This domain and the repo `https://github.com/pterodactyl-installer/pterodactyl-installer` are **not** owned by Ayanok0ji. CCTO to original authors.

_Note: On some systems, it's required to be already logged in as root before executing the one-line command (where `sudo` is in front of the command does not work)._

Here is a [YouTube video](https://www.youtube.com/watch?v=E8UJhyUFoHM) that illustrates the installation process.

## Firewall setup

The installation scripts can install and configure a firewall for you. The script will ask whether you want this or not. It is highly recommended to opt-in for the automatic firewall setup.

## Development & Ops

### Testing the script locally

To test the script, we use [Vagrant](https://www.vagrantup.com). With Vagrant, you can quickly get a fresh machine up and running to test the script.

If you want to test the script on all supported installations in one go, just run the following.

```bash
vagrant up
```

If you only want to test a specific distribution, you can run the following.

```bash
vagrant up <name>
```

Replace name with one of the following (supported installations).

- `ubuntu_jammy`
- `debian_bullseye`
- `debian_buster`
- `debian_bookworm`
- `debian_trixie`
- `almalinux_8`
- `almalinux_9`
- `rockylinux_8`
- `rockylinux_9`

Then you can use `vagrant ssh <name of machine>` to SSH into the box. The project directory will be mounted in `/vagrant` so you can quickly modify the script locally and then test the changes by running the script from `/vagrant/installers/panel.sh` and `/vagrant/installers/wings.sh` respectively.

### Creating a release

In `install.sh` github source and script release variables should change every release. Firstly, update the `CHANGELOG.md` so that the release date and release tag are both displayed. No changes should be made to the changelog points themselves. Secondly, update `GITHUB_SOURCE` and `SCRIPT_RELEASE` in `install.sh`. Finally, you can now push a commit with the message `Release vX.Y.Z`. Create a release on GitHub. See [this commit](https://github.com/pterodactyl-installer/pterodactyl-installer/commit/90aaae10785f1032fdf90b216a4a8d8ca64e6d44) for reference.

## License & Attribution

- **License:** GPL-3.0 — see [LICENSE](LICENSE)
- **Upstream Copyright (C) 2018 - 2026, Vilhelm Prytz, <vilhelm@prytznet.se>** and contributors
- **Fork modifications Copyright (C) 2026, Ayanok0ji** — `https://github.com/Ayanok0ji`

Per GPL-3.0 Sec. 4 & 5, this fork preserves original copyright notices, adds a prominent notice of modification (date + fork author), and keeps the license.

## Contributors ✨

Upstream:

- Created by [Vilhelm Prytz](https://github.com/vilhelmprytz)
- Maintained by [Linux123123](https://github.com/Linux123123)

Thanks to the Discord moderators [sam1370](https://github.com/sam1370), [Linux123123](https://github.com/Linux123123) and [sinjs](https://github.com/sinjs) for helping on the Discord server!

Fork:

- Modified by [Ayanok0ji](https://github.com/Ayanok0ji) — added version selection (1.11.3 / 1.11.1 / latest for panel & wings) and fork attribution.
