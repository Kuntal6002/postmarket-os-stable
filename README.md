# Mobile Linux Dotfiles

Custom mobile Linux environment built on:

- postmarketOS
- Sway
- Waybar
- Foot
- Squeekboard

Focused on:
- lightweight mobile UI
- reproducibility
- rollback safety
- clean Wayland workflow
- git-managed configs

---

# Philosophy

This setup prioritizes:

- stability over endless tweaking
- reproducibility over memorization
- rollback capability
- simple recovery
- understanding the Linux stack

Main realization:

> Stable boring systems are better than endlessly broken "perfect" setups.

---

# System Overview

## Core Components

| Component | Purpose |
|---|---|
| Sway | Wayland compositor |
| Waybar | Top status bar |
| Foot | Terminal emulator |
| Wofi | App launcher |
| Squeekboard | Virtual keyboard |
| brightnessctl | Brightness control |
| YAD | Popup UI dialogs |
| swayidle | Idle management |
| acpid | Power button handling |

---

# Repository Structure

```text
dotfiles/
├── sway/
├── waybar/
├── foot/
├── scripts/
├── system/
├── README.md
├── packages.txt
└── .gitignore
```

---

# Dotfiles Workflow

This repository uses symlinked configs.

Meaning:

```text
~/.config/sway
```

is a symbolic link to:

```text
~/dotfiles/sway
```

So:
- applications read from ~/.config
- git tracks files in ~/dotfiles
- both are actually the same files

This eliminates manual syncing.

---

# Checking Symlinks

Verify:

```sh
ls -l ~/.config
```

Correct output looks like:

```text
sway -> /home/USER/dotfiles/sway
waybar -> /home/USER/dotfiles/waybar
```

If the line starts with:

```text
l
```

then it is a symbolic link.

---

# Initial Installation

## Install Packages

```sh
sudo apk add \
sway \
waybar \
foot \
wofi \
brightnessctl \
yad \
swayidle \
squeekboard \
acpid \
git
```

---

# Clone Repository

```sh
git clone YOUR_REPO_URL ~/dotfiles
```

---

# Create Config Symlinks

## Sway

```sh
ln -s ~/dotfiles/sway ~/.config/sway
```

## Waybar

```sh
ln -s ~/dotfiles/waybar ~/.config/waybar
```

---

# Auto-start Sway

Add to:

```text
~/.profile
```

```sh
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec seatd-launch sway
fi
```

Result:
- tty1 launches Sway automatically
- if Sway crashes → console still usable

---

# ACPID Setup

## Install service file

```sh
sudo cp system/acpid.service /etc/systemd/system/
```

## Install handler

```sh
sudo cp system/handler.sh /etc/acpi/
```

## Enable service

```sh
sudo systemctl daemon-reload
sudo systemctl enable acpid
sudo systemctl restart acpid
```

---

# Power Button Design

This setup does NOT use real suspend.

Reason:
- suspend unstable on MSM8998
- GPU resume issues
- touch resume issues
- compositor instability

Instead:
- screen DPMS off
- compositor remains alive
- instant wake
- applications remain running

---

# Package Backup

Save installed packages:

```sh
apk info -vv | sort > packages.txt
```

Restore packages:

```sh
sudo apk add $(cat packages.txt)
```

---

# Git Workflow

## See Changed Files

```sh
git status
```

---

## See Exact Changes

```sh
git diff
```

---

## Save Changes

```sh
git add .
git commit -m "Describe changes"
git push
```

Example:

```sh
git commit -m "Improve brightness popup"
```

---

# Safe Workflow

Recommended workflow:

```text
edit
→ test
→ reload
→ git diff
→ commit
→ push
```

NEVER:
- blindly commit untested configs
- tweak endlessly without rollback

---

# Reloading Sway

Reload config:

```sh
swaymsg reload
```

---

# Restarting Waybar

```sh
pkill waybar && waybar &
```

---

# Rollback

## View History

```sh
git log --oneline
```

---

## Restore Older File

Example:

```sh
git checkout HEAD~1 -- waybar/config.jsonc
```

---

# Full System Backup

## Create Raw Image

Example:

```sh
sudo dd if=/dev/mmcblk0 of=pmos.img bs=4M status=progress
```

Compress:

```sh
xz -T0 pmos.img
```

---

# Restore Raw Image

```sh
sudo dd if=pmos.img of=/dev/mmcblk0 bs=4M status=progress
```

WARNING:
- restores ENTIRE device
- destroys current filesystem

---

# Important Lessons Learned

- GPU/display stack affects everything above it
- logs are not always fatal
- minimal systems require MORE integration work
- desktop environments solve many hidden problems
- reproducibility matters more than customization

---

# Future Ideas

- btrfs snapshots
- immutable systems
- Nix-style reproducibility
- self-hosted sync
- mobile Wayland optimization
- containerized services
- automated backups

---

# Notes

This repository is both:
- a backup system
- a learning journal

The goal is not endless tweaking.

The goal is:
- understanding
- reproducibility
- stability
- recoverability
