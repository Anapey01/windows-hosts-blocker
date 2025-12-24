# Windows Hosts + DNS Content Blocking Script

This repository contains a **hardened PowerShell script** to block adult content sites on Windows by modifying the hosts file and applying Cloudflare Family DNS.

## Features

- IPv4 and IPv6 blocking of major adult content sites
- Cloudflare Family DNS enforcement (1.1.1.3 / 1.0.0.3)
- Automatic backup of the existing hosts file
- Locks the hosts file to prevent tampering
- Flushes system DNS cache
- Safe and portable, works on Windows 10/11

## Requirements

- Run PowerShell **as Administrator**
- DNS-over-HTTPS must be **disabled in browsers** (Chrome, Edge, Firefox)
- Windows 10 or 11

## Usage

1. Download or clone this repository
2. Open PowerShell **as Administrator**
3. Navigate to the script folder
4. Run:

```powershell
.\block-hosts.ps1

Disclaimer

Educational / awareness purposes only

Use responsibly

Modifying system hosts file can interfere with some applications
