# discord_ip_monitor.ps1
# Purpose: Monitor Discord’s active TCP/UDP connections and log remote IPs.
# Optional log file – set $LogFile to $null to disable file logging.

$PollingInterval = 3                # seconds between scans
$LogFile         = "discord_calls.log"

$STUNPorts   = 3478..3479           # STUN/TURN
$MediaPorts  = 50000..60000         # Media streams
$TCPPorts    = @(80,443)            # HTTPS / signalling
$UDPPorts    = $STUNPorts + $MediaPorts

function Write-Log {
    param([string]$Message)
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    if ($LogFile) { Add-Content -Path $LogFile -Value $line -Encoding UTF8 }
}

function Get-DiscordConnections {
    $discordProcesses = Get-Process -Name "Discord*" -ErrorAction SilentlyContinue
    if (-not $discordProcesses) {
        Write-Log "No Discord process found."
        return
    }

    $discordPIDs = $discordProcesses.Id
    Write-Log "Discord PIDs: $($discordPIDs -join ', ')"

    # TCP connections
    $tcpConnections = Get-NetTCPConnection -OwningProcess $discordPIDs `
        -State Established -ErrorAction SilentlyContinue |
        Where-Object { $TCPPorts -contains $_.RemotePort } |
        Select-Object LocalPort, RemoteAddress, RemotePort, OwningProcess

    # UDP endpoints
    $udpEndpoints = Get-NetUDPEndpoint -OwningProcess $discordPIDs `
        -ErrorAction SilentlyContinue |
        Where-Object { $UDPPorts -contains $_.LocalPort } |
        Select-Object LocalPort, RemoteAddress, RemotePort, OwningProcess

    if ($tcpConnections) {
        Write-Log "--- TCP connections (HTTPS / signalling) ---"
        foreach ($c in $tcpConnections) {
            Write-Log "  TCP Remote: $($c.RemoteAddress):$($c.RemotePort) (Local: $($c.LocalPort))"
        }
    }

    if ($udpEndpoints) {
        Write-Log "--- UDP endpoints (Voice / Video) ---"
        foreach ($c in $udpEndpoints) {
            Write-Log "  UDP Local Port: $($c.LocalPort) (PID: $($c.OwningProcess))"
        }
    }

    # UDP via netstat – captures “active” UDP sockets
    Write-Log "--- UDP via netstat ---"
    $netstatOutput = netstat -an |
        Where-Object { $_ -match "UDP" } |
        Where-Object {
            if ($_ -match ":(\d+)\s") {
                $port = [int]$Matches[1]
                ($port -ge 3478 -and $port -le 3479) -or
                ($port -ge 50000 -and $port -le 60000)
            }
        }
    foreach ($line in $netstatOutput) {
        if ($line.Trim()) { Write-Log "  $line" }
    }

    # Optional: show remote IPs for UDP flows (if available)
    $udpFlows = Get-NetUDPEndpoint -ErrorAction SilentlyContinue |
        Where-Object { $UDPPorts -contains $_.LocalPort -and $discordPIDs -contains $_.OwningProcess }
    if ($udpFlows) {
        Write-Log "--- Discord UDP flows (remote IP) ---"
        foreach ($f in $udpFlows) {
            Write-Log "  UDP $($f.LocalAddress):$($f.LocalPort) -> $($f.RemoteAddress):$($f.RemotePort)"
        }
    }

    $totalTCP = if ($tcpConnections) { $tcpConnections.Count } else { 0 }
    $totalUDP = if ($udpEndpoints)   { $udpEndpoints.Count }   else { 0 }
    Write-Log "Total: $totalTCP TCP connections, $totalUDP active UDP endpoints"
    Write-Log "-----------------------------------------------"
}

# ---------- Main Loop ----------
Write-Log "=== Discord connection monitor started ==="
Write-Log "Press Ctrl+C to stop."
Write-Log "Polling interval: $PollingInterval seconds"
Write-Log "Log file: $(if ($LogFile) {$LogFile} else {'disabled'})"
Write-Log "==========================================="

try {
    while ($true) {
        Get-DiscordConnections
        Start-Sleep -Seconds $PollingInterval
    }
} finally {
    Write-Log "=== Discord connection monitor stopped ==="
}
