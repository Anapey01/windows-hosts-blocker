<#
.SYNOPSIS
Hardened hosts file + Cloudflare Family DNS content blocking script.

.DESCRIPTION
This PowerShell script:
- Backs up the hosts file
- Blocks adult content sites (IPv4 + IPv6)
- Applies Cloudflare Family DNS (1.1.1.3 / 1.0.0.3)
- Flushes DNS cache
- Locks the hosts file to prevent tampering

USE CASE: Educational and awareness purposes only.

REQUIREMENTS:
- Run PowerShell as Administrator
- Works on Windows 10/11
#>

# -----------------
# ELEVATION CHECK
# -----------------
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "ERROR: You must run this script as Administrator!" -ForegroundColor Red
    exit
}

# -----------------
# VARIABLES
# -----------------
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$backupDir = "$env:USERPROFILE\hosts-backup"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# -----------------
# STEP 1: BACKUP HOSTS FILE
# -----------------
if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
Copy-Item $hostsPath "$backupDir\hosts-backup-$timestamp" -Force
Write-Host "Hosts file backed up at $backupDir"

# -----------------
# STEP 2: TAKE OWNERSHIP & GIVE ADMIN WRITE ACCESS
# -----------------
takeown /f "$hostsPath" | Out-Null
icacls "$hostsPath" /grant:r Administrators:F | Out-Null

# -----------------
# STEP 3: BLOCKLIST (IPv4 + IPv6)
# -----------------
$blockedHosts = @"
127.0.0.1 pornhub.com
127.0.0.1 www.pornhub.com
127.0.0.1 xvideos.com
127.0.0.1 www.xvideos.com
127.0.0.1 xhamster.com
127.0.0.1 www.xhamster.com
127.0.0.1 xnxx.com
127.0.0.1 www.xnxx.com
127.0.0.1 redtube.com
127.0.0.1 www.redtube.com
127.0.0.1 nhentai.net
127.0.0.1 www.nhentai.net
127.0.0.1 youporn.com
127.0.0.1 www.youporn.com
127.0.0.1 brazzers.com
127.0.0.1 www.brazzers.com
127.0.0.1 spankbang.com
127.0.0.1 www.spankbang.com
127.0.0.1 tube8.com
127.0.0.1 www.tube8.com
::1 pornhub.com
::1 www.pornhub.com
::1 xvideos.com
::1 www.xvideos.com
::1 xhamster.com
::1 www.xhamster.com
::1 xnxx.com
::1 www.xnxx.com
::1 redtube.com
::1 www.redtube.com
::1 nhentai.net
::1 www.nhentai.net
::1 youporn.com
::1 www.youporn.com
::1 brazzers.com
::1 www.brazzers.com
::1 spankbang.com
::1 www.spankbang.com
::1 tube8.com
::1 www.tube8.com
"@

# Apply the blocklist
$blockedHosts | Set-Content -Path $hostsPath -Encoding ASCII
Write-Host "Hosts file updated with blocklist."

# -----------------
# STEP 4: APPLY CLOUDFLARE FAMILY DNS
# -----------------
$activeAdapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

if ($activeAdapter) {
    Set-DnsClientServerAddress -InterfaceAlias $activeAdapter.InterfaceAlias -ServerAddresses ("1.1.1.3","1.0.0.3")
    Set-DnsClient -InterfaceAlias $activeAdapter.InterfaceAlias -RegisterThisConnectionsAddress $false
    Write-Host "Cloudflare Family DNS applied to $($activeAdapter.InterfaceAlias)."
} else { Write-Host "No active network adapter found." }

# -----------------
# STEP 5: FLUSH DNS
# -----------------
ipconfig /flushdns | Out-Null
Write-Host "DNS cache flushed."

# -----------------
# STEP 6: LOCK HOSTS FILE
# -----------------
icacls "$hostsPath" /inheritance:r | Out-Null
icacls "$hostsPath" /grant:r SYSTEM:F | Out-Null
Write-Host "Hosts file locked."

# -----------------
# DONE
# -----------------
Write-Host "`nContent blocking is now ACTIVE and STRICT."
Write-Host "Backup location: $backupDir"
