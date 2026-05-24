# postmarketOS Mobile Linux Setup

Custom mobile Linux environment built around:

- postmarketOS
- Sway
- Waybar
- Foot
- Squeekboard
- Wayland

Focused on:
- stability
- reproducibility
- rollback safety
- lightweight mobile UI
- remote administration
- backup/recovery workflows

---

# Philosophy

This setup prioritizes:

- stable systems over endless tweaking
- reproducibility over memorization
- backups over panic recovery
- understanding the Linux stack
- minimal but practical tooling

Main realization:

> Minimal systems are not automatically simpler.
> Stable boring systems are better than endlessly broken "perfect" setups.

---

# Device

- MSM8998-based phone
- postmarketOS (Alpine-based)
- Wayland/Sway setup
- Remote SSH administration enabled
- Tailscale enabled

---

# Core Components

| Component | Purpose |
|---|---|
| Sway | Wayland compositor |
| Waybar | Status bar |
| Foot | Terminal emulator |
| Wofi | Launcher |
| Squeekboard | Virtual keyboard |
| brightnessctl | Brightness control |
| YAD | Popup UI dialogs |
| swayidle | Idle handling |
| acpid | Power button handling |
| rsync | Incremental backups |
| git | Dotfile/version control |
| fastfetch | System info display |

---

# System Features

Working:

- Touchscreen
- Wayland graphics
- Mobile scaling
- Waybar
- Squeekboard
- Brightness popup
- Power button handling
- Auto-start Sway
- SSH access
- Tailscale remote access
- Git-managed configs
- Symlinked dotfiles
- Incremental backup workflow

---

# Dotfiles Architecture

This repository uses symlink-based dotfiles.

Meaning:

```text
~/.config/sway
```

is actually a symlink to:

```text
~/dotfiles/sway
```

Applications use:

```text
~/.config
```

Git tracks:

```text
~/dotfiles
```

Both point to the same files.

Result:
- no manual syncing
- instant git tracking
- clean rollback/history

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

# Checking Symlinks

Verify:

```sh
ls -l ~/.config
```

Correct output:

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

# Git Workflow

## Check Changes

```sh
git status
```

---

## See Exact Differences

```sh
git diff
```

---

## Save Changes

```sh
git add .
git commit -m "Describe changes"
git push origin main
```

Example:

```sh
git commit -m "Improve waybar battery script"
```

---

# Recommended Workflow

```text
edit
→ test
→ reload
→ git diff
→ commit
→ push
```

Never blindly commit broken configs.

---

# Sway Reload

Reload Sway config:

```sh
swaymsg reload
```

---

# Restart Waybar

```sh
pkill waybar && waybar &
```

---

# Foot + Fastfetch Setup

Foot automatically launches Fastfetch.

Example configuration:

```ini
[main]
shell=/bin/ash -lc "fastfetch; exec ash"
```

Location:

```text
~/.config/foot/foot.ini
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

Behavior:
- tty1 automatically launches Sway
- if Sway crashes → fallback console still works

---

# ACPID Power Button Setup

Install service:

```sh
sudo cp system/acpid.service /etc/systemd/system/
```

Install handler:

```sh
sudo cp system/handler.sh /etc/acpi/
```

Enable:

```sh
sudo systemctl daemon-reload
sudo systemctl enable acpid
sudo systemctl restart acpid
```

---

# Power Button Design

This setup avoids real suspend.

Reason:
- suspend unstable on MSM8998
- GPU resume issues
- touchscreen resume issues
- compositor instability

Instead:
- screen DPMS off
- compositor remains alive
- instant wake
- apps stay running

---

# Wayland Environment Variables

Recommended Sway environment setup:

```text
setenv XDG_SESSION_TYPE wayland
setenv XDG_CURRENT_DESKTOP sway
setenv MOZ_ENABLE_WAYLAND 1
setenv QT_QPA_PLATFORM wayland
setenv GDK_BACKEND wayland
```

Improves native Wayland support and suppresses many X11 warnings.

---

# Tailscale Notes

Tailscale may overwrite:

```text
/etc/resolv.conf
```

This can break DNS resolution.

Disable Tailscale DNS management:

```sh
sudo tailscale set --accept-dns=false
```

---

# Package Backup

Save installed packages:

```sh
apk info -vv | sort > ~/dotfiles/packages.txt
```

Restore packages:

```sh
sudo apk add $(cat packages.txt)
```

---

# Backup Strategy

This setup uses layered backups.

| Backup Type | Purpose |
|---|---|
| Git dotfiles | Config rollback |
| packages.txt | Reinstall packages |
| rsync home backup | Weekly recovery |
| Raw image | Disaster recovery |

---

# Weekly Backup Workflow

Uses:

- SSH
- rsync
- PC as backup target

---

# Install rsync

```sh
sudo apk add rsync
```

---

# Backup Dotfiles

From PC:

```sh
rsync -avz \
kuntal@PHONE_IP:/home/kuntal/dotfiles/ \
~/pmos-backups/dotfiles/
```

---

# Backup Entire Home

Recommended:

```sh
rsync -avz \
--exclude='.cache' \
--exclude='Downloads' \
--exclude='.local/share/Trash' \
kuntal@PHONE_IP:/home/kuntal/ \
~/pmos-backups/home/
```

---

# Automatic Backup Script

Example:

```sh
#!/bin/sh

DATE=$(date +%F)

mkdir -p ~/pmos-backups/$DATE

rsync -avz \
--exclude='.cache' \
--exclude='Downloads' \
kuntal@PHONE_IP:/home/kuntal/ \
~/pmos-backups/$DATE/home/

echo "Backup complete: $DATE"
```

---

# SSH Key Setup

Generate key on PC:

```sh
ssh-keygen
```

Copy to phone:

```sh
ssh-copy-id kuntal@PHONE_IP
```

Allows passwordless backups.

---

# Automated Weekly Backups

Example cron job:

```cron
0 3 * * 0 /home/YOURUSER/backup-pmos.sh
```

Meaning:
- every Sunday
- 3 AM
- automatic backup

---

# Restore Workflow

## Reinstall Base PMOS

Flash/reinstall postmarketOS normally.

---

## Restore Home Directory

```sh
rsync -av \
~/pmos-backups/latest/home/ \
kuntal@PHONE_IP:/home/kuntal/
```

---

## Restore Packages

```sh
sudo apk add $(cat packages.txt)
```

---

## Recreate Symlinks

Example:

```sh
ln -s ~/dotfiles/sway ~/.config/sway
ln -s ~/dotfiles/waybar ~/.config/waybar
```

---

# Raw Image Backups

Used only before dangerous experiments.

Main storage device:

```text
/dev/sda
```

Create image:

```sh
ssh kuntal@PHONE_IP \
"sudo dd if=/dev/sda bs=4M status=progress" \
| gzip > pmos-full.img.gz
```

WARNING:
- full-device backup
- device-specific
- dangerous to restore blindly

---

# Important Lessons Learned

- GPU/display stack affects everything above it
- Logs are not always fatal
- Minimal systems require more integration work
- Desktop environments solve many hidden problems
- Reproducibility matters more than customization
- Backups matter more than tweaking

---

# Future Ideas

- Jellyfin direct-play server
- Self-hosted services
- Immutable Linux setups
- btrfs snapshots
- Nix-style reproducibility
- Containerized services
- Waybar VPN indicators
- Automated snapshot rotation

---

# Notes

This repository acts as:

- system backup
- recovery documentation
- learning journal
- reproducible environment
- rollback mechanism

Goal:
- understand systems deeply
- maintain stability
- recover quickly
- experiment safely
