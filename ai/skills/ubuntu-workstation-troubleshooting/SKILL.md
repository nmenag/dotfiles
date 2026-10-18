---
name: ubuntu-workstation-troubleshooting
description: >-
  Use this skill when diagnosing or resolving APT package locks, GPG keyring errors,
  derivative distro codename mismatches (Pop!_OS/Mint), asdf compilation failures,
  or Docker permissions on Ubuntu/Debian workstations.
---

# Ubuntu & Debian Workstation Troubleshooting Guide

This skill provides diagnostic patterns and solutions for common workstation provisioning failures on Debian/Ubuntu and Ubuntu derivatives (Pop!_OS, Linux Mint).

## Common Scenarios & Resolutions

### 1. APT Lock Errors (`Could not get lock /var/lib/dpkg/lock-frontend`)
**Symptom**: `apt-get` fails reporting another process holds the lock.
**Diagnosis**:
```bash
ps aux | grep -i -E 'apt|dpkg'
```
**Resolution**:
Wait for automatic background updates (`unattended-upgrades`) to finish. If orphaned:
```bash
sudo systemctl stop unattended-upgrades
sudo dpkg --configure -a
```

### 2. GPG Key and APT Repository Warnings (`apt-key is deprecated` or Keyring Not Found)
**Symptom**: `W: https://...: Key is stored in legacy trusted.gpg keyring`.
**Diagnosis**:
Check `/etc/apt/sources.list.d/` for entries missing `signed-by` or using `apt-key`.
**Resolution**:
Download the ASCII-armored key and convert with `gpg --dearmor` into `/etc/apt/keyrings/`:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL <key_url> | sudo gpg --dearmor --yes -o /etc/apt/keyrings/<app>.gpg
sudo chmod a+r /etc/apt/keyrings/<app>.gpg
```
Update the repo list line:
```text
deb [signed-by=/etc/apt/keyrings/<app>.gpg] https://... <codename> main
```

### 3. Ubuntu Derivative Codename Mismatches (Pop!_OS, Mint)
**Symptom**: 404 Not Found when fetching repository releases using `lsb_release -cs` (e.g. `noble` vs `pop` or `vanessa`).
**Diagnosis**:
Check `/etc/os-release`:
```bash
. /etc/os-release
echo "UBUNTU_CODENAME: ${UBUNTU_CODENAME:-$VERSION_CODENAME}"
```
**Resolution**:
Always use `CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"` in all scripts.

### 4. ASDF Build Dependency Missing (Ruby / Python / Erlang)
**Symptom**: Compiling ruby or python fails with missing openssl, readline, or libyaml headers.
**Diagnosis**:
Check required development headers:
```bash
dpkg -l | grep -E 'libssl-dev|libreadline-dev|libyaml-dev|zlib1g-dev'
```
**Resolution**:
Install prerequisites via `./install.sh --core` or directly:
```bash
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libyaml-dev
```

### 5. Docker Permission Denied (`permission denied while trying to connect to the Docker daemon socket`)
**Symptom**: `docker ps` fails without `sudo`.
**Diagnosis**:
Check if the current user belongs to the `docker` group:
```bash
groups | grep docker
```
**Resolution**:
Ensure user is added and activate in current shell or re-login:
```bash
sudo usermod -aG docker "$USER"
newgrp docker
```
