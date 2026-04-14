# Discord‑IP‑Grabber

> A lightweight PowerShell script that continuously monitors Discord’s TCP/UDP connections and logs the remote IP addresses.

---

## 📌 Table of Contents

| Section | Description |
|---------|-------------|
| [What It Does](#what-it-does) | Overview of the functionality |
| [Features](#features) | What makes this script useful |
| [Prerequisites](#prerequisites) | System requirements |
| [Installation](#installation) | How to get it up & running |
| [Configuration](#configuration) | Adjusting polling interval, log file, etc. |
| [Usage](#usage) | Running the script & interpreting the output |
| [Troubleshooting](#troubleshooting) | Common issues & fixes |
| [Contributions](#contributions) | What you can or cannot do |
| [License](#license) | Legal information |
| [Contact](#contact) | Get in touch |

---

## 📖 What It Does

Discord’s voice, video, and messaging traffic is carried over a handful of well‑known ports (HTTPS, STUN/TURN, and media UDP ports).  
This script:

1. **Finds all running Discord processes**.  
2. **Detects established TCP connections** on ports 80/443 (HTTPS) and logs the remote IPs.  
3. **Identifies active UDP endpoints** on STUN/TURN and media ranges (3478‑3479, 50000‑60000).  
4. **Logs every poll to the console and (optionally) to a file**.  
5. **Runs in a loop** with a configurable interval.

It’s ideal for quick diagnostics, debugging connection issues, or monitoring Discord’s network footprint.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Automated Polling** | Default 3‑second interval – configurable via `$PollingInterval`. |
| **Dual‑Protocol Support** | Handles both TCP and UDP sockets. |
| **Easy Logging** | `Write-Host` for real‑time feedback + optional `Add-Content` to `discord_calls.log`. |
| **Clear Output** | Human‑readable logs, timestamped and categorized. |
| **Minimal Dependencies** | Uses built‑in PowerShell cmdlets (`Get-NetTCPConnection`, `Get-NetUDPEndpoint`, `netstat`). |
| **Cross‑Platform** | Works on any Windows system with PowerShell 5.1+ (or PowerShell 7+). |
| **Stop Anytime** | Press `Ctrl+C` to terminate gracefully. |

---

## 📦 Prerequisites

| Requirement | Minimum | Notes |
|-------------|---------|-------|
| **Windows** | 7 SP1 / 8 / 10 / 11 |  |
| **PowerShell** | 5.1 (Windows) or 7.x (cross‑platform) | The script uses `Get-NetTCPConnection`; PowerShell 5.1 is bundled with Windows 10+. |
| **Admin Rights** | Optional | Required only if you want to capture all UDP sockets (some ports require elevated privileges). |
| **Internet** | — | To reach Discord servers, but not required for the script itself. |

---

## 🛠️ Installation

1. **Download the .ps1**
