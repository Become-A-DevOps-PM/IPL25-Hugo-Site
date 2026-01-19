+++
title = "Linux Command Line Cheat Sheet"
program = "IPL"
cohort = "25"
courses = ["SNS"]
weight = 10
date = 2024-11-25
draft = false
+++

Quick reference for essential Linux commands.

## Navigation

| Command | Description |
|---------|-------------|
| `pwd` | Print current directory |
| `ls` | List files |
| `ls -la` | List all files with details |
| `cd /path` | Change to directory |
| `cd ..` | Go up one level |
| `cd ~` | Go to home directory |

## File Operations

| Command | Description |
|---------|-------------|
| `cat file` | Display file contents |
| `head file` | Show first 10 lines |
| `tail file` | Show last 10 lines |
| `tail -f file` | Follow file updates |
| `nano file` | Edit file |
| `touch file` | Create empty file |
| `cp src dest` | Copy file |
| `mv src dest` | Move/rename file |
| `rm file` | Delete file |
| `mkdir dir` | Create directory |
| `rm -r dir` | Delete directory |

## Nano Editor

| Key | Action |
|-----|--------|
| `Ctrl+O` | Save |
| `Ctrl+X` | Exit |
| `Ctrl+K` | Cut line |
| `Ctrl+U` | Paste |

## Permissions

| Command | Description |
|---------|-------------|
| `chmod 755 file` | rwxr-xr-x (executable) |
| `chmod 644 file` | rw-r--r-- (readable) |
| `chmod 400 file` | r-------- (SSH keys) |
| `chmod +x file` | Add execute permission |
| `chown user:group file` | Change ownership |

### Permission Numbers
- 4 = read (r)
- 2 = write (w)
- 1 = execute (x)

## Package Management (APT)

| Command | Description |
|---------|-------------|
| `sudo apt update` | Update package lists |
| `sudo apt install pkg` | Install package |
| `sudo apt install -y pkg` | Install without prompt |
| `sudo apt remove pkg` | Remove package |
| `sudo apt upgrade` | Upgrade all packages |
| `apt search keyword` | Search for package |

## Service Management (systemctl)

| Command | Description |
|---------|-------------|
| `sudo systemctl status svc` | Check status |
| `sudo systemctl start svc` | Start service |
| `sudo systemctl stop svc` | Stop service |
| `sudo systemctl restart svc` | Restart service |
| `sudo systemctl enable svc` | Start on boot |
| `sudo systemctl disable svc` | Don't start on boot |

## System Information

| Command | Description |
|---------|-------------|
| `df -h` | Disk usage |
| `free -h` | Memory usage |
| `top` | Process monitor |
| `ps aux` | List processes |
| `ip addr` | Show IP addresses |

## Useful Shortcuts

| Key | Action |
|-----|--------|
| `Tab` | Autocomplete |
| `↑` / `↓` | Command history |
| `Ctrl+C` | Cancel command |
| `Ctrl+L` | Clear screen |
| `Ctrl+R` | Search history |

## Common Paths

| Path | Contents |
|------|----------|
| `/home/user` | User home directory |
| `/etc` | Configuration files |
| `/var/log` | Log files |
| `/var/www/html` | Web server root |
| `/tmp` | Temporary files |
