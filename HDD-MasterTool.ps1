# ================================================================
#  HDD-MasterTool.ps1
#  Hard Drive Management & Robocopy Tool
#  By JahirCyberDesk | jahircyberdesk@gmail.com
#  YouTube: @jahircyberdesk
# ================================================================

# ── Admin Check ─────────────────────────────────────────────────
if (-NOT ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host ""
    Write-Host "  [!] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "  [!] Right-click the script and select 'Run with PowerShell as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit
}

# ── Helper Functions ─────────────────────────────────────────────
function Write-Header {
    param([string]$Text)
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║  $($Text.PadRight(56))║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "  JahirCyberDesk | Hard Drive Management Tool" -ForegroundColor DarkGray
    Write-Host ""
}

function Pause-Script {
    Write-Host ""
    Write-Host "  ──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Read-Host "  Press Enter to return to Main Menu"
}

function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1TB)     { return "$([math]::Round($Bytes/1TB,2)) TB" }
    elseif ($Bytes -ge 1GB) { return "$([math]::Round($Bytes/1GB,2)) GB" }
    elseif ($Bytes -ge 1MB) { return "$([math]::Round($Bytes/1MB,2)) MB" }
    elseif ($Bytes -ge 1KB) { return "$([math]::Round($Bytes/1KB,2)) KB" }
    else                    { return "$Bytes B" }
}

function Draw-Bar {
    param([int]$Percent, [int]$Width = 35)
    $filled = [math]::Round(($Percent / 100) * $Width)
    $empty  = $Width - $filled
    return "[" + ("█" * $filled) + ("░" * $empty) + "]"
}

# ================================================================
#  OPTION 1 — DRIVE OVERVIEW
# ================================================================
function Show-DriveOverview {
    Write-Header "DRIVE OVERVIEW  -  Disk Space & Info"

    try {
        $volumes = Get-Volume -ErrorAction SilentlyContinue |
                   Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' } |
                   Sort-Object DriveLetter

        if (-not $volumes) {
            Write-Host "  No fixed drives found." -ForegroundColor Red
            Pause-Script; return
        }

        foreach ($vol in $volumes) {
            $totalBytes = $vol.Size
            $freeBytes  = $vol.SizeRemaining
            $usedBytes  = $totalBytes - $freeBytes

            if ($totalBytes -gt 0) {
                $usedPct = [math]::Round(($usedBytes / $totalBytes) * 100, 1)
                $freePct = [math]::Round(($freeBytes  / $totalBytes) * 100, 1)
            } else { $usedPct = 0; $freePct = 0 }

            $label  = if ($vol.FileSystemLabel) { $vol.FileSystemLabel } else { "No Label" }
            $fsType = $vol.FileSystem
            $letter = "$($vol.DriveLetter):"

            $barColor = if ($freePct -lt 10) { "Red" }
                        elseif ($freePct -lt 20) { "Yellow" }
                        else { "Green" }

            Write-Host "  Drive $letter  [$label]  [$fsType]" -ForegroundColor White
            Write-Host "  Total : $(Format-Size $totalBytes)" -ForegroundColor Gray
            Write-Host "  Used  : $(Format-Size $usedBytes) ($usedPct%)" -ForegroundColor $barColor
            Write-Host "  Free  : $(Format-Size $freeBytes) ($freePct%)" -ForegroundColor $barColor
            $bar = Draw-Bar -Percent $usedPct
            Write-Host "  $bar  $usedPct% used" -ForegroundColor $barColor
            Write-Host ""
        }
    } catch {
        Write-Host "  [ERROR] Could not retrieve drive information: $_" -ForegroundColor Red
    }

    Pause-Script
}

# ================================================================
#  OPTION 2 — DRIVE HEALTH CHECK (SMART)
# ================================================================
function Show-HealthCheck {
    Write-Header "DRIVE HEALTH CHECK  -  SMART Status"

    try {
        $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue

        if (-not $disks) {
            Write-Host "  No physical drives found." -ForegroundColor Red
            Pause-Script; return
        }

        foreach ($disk in $disks) {
            Write-Host "  ┌─────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
            Write-Host "  │ $($disk.FriendlyName)" -ForegroundColor White
            Write-Host "  ├─────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
            Write-Host "  │ Model      : $($disk.FriendlyName)" -ForegroundColor Gray
            Write-Host "  │ Serial No  : $($disk.SerialNumber)" -ForegroundColor Gray
            Write-Host "  │ Size       : $(Format-Size $disk.Size)" -ForegroundColor Gray
            Write-Host "  │ Bus Type   : $($disk.BusType)" -ForegroundColor Gray
            Write-Host "  │ Media Type : $($disk.MediaType)" -ForegroundColor Gray

            # SMART / Health Status
            $status = $disk.HealthStatus
            if ($status -eq "Healthy") {
                Write-Host "  │ SMART      : ✔  OK  -  Drive is healthy" -ForegroundColor Green
            } else {
                Write-Host "  │ SMART      : ✘  $status  -  WARNING! Back up immediately!" -ForegroundColor Red
            }

            Write-Host "  └─────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
            Write-Host ""
        }
    } catch {
        Write-Host "  [ERROR] Could not retrieve disk health information: $_" -ForegroundColor Red
    }

    Pause-Script
}

# ================================================================
#  OPTION 3 — DISK CLEANUP
# ================================================================
function Run-DiskCleanup {
    Write-Header "DISK CLEANUP  -  Free Up Space"

    Write-Host "  Will clean the following locations:" -ForegroundColor Yellow
    Write-Host "   • Windows Temp folder     (%SystemRoot%\Temp)" -ForegroundColor Gray
    Write-Host "   • User Temp folder        (%TEMP%)" -ForegroundColor Gray
    Write-Host "   • Prefetch files          (%SystemRoot%\Prefetch)" -ForegroundColor Gray
    Write-Host "   • Windows Update cache    (%SystemRoot%\SoftwareDistribution\Download)" -ForegroundColor Gray
    Write-Host "   • CBS Logs                (%SystemRoot%\Logs\CBS)" -ForegroundColor Gray
    Write-Host "   • Recycle Bin             (all drives)" -ForegroundColor Gray
    Write-Host ""
    $confirm = Read-Host "  Start cleanup? (Y/N)"
    if ($confirm -notin @("Y","y")) { Pause-Script; return }

    Write-Host ""
    $totalFreed = 0

    $cleanPaths = @(
        [pscustomobject]@{ Label = "Windows Temp";       Path = "$env:SystemRoot\Temp" }
        [pscustomobject]@{ Label = "User Temp";          Path = $env:TEMP }
        [pscustomobject]@{ Label = "Prefetch";           Path = "$env:SystemRoot\Prefetch" }
        [pscustomobject]@{ Label = "Windows Update";     Path = "$env:SystemRoot\SoftwareDistribution\Download" }
        [pscustomobject]@{ Label = "CBS Logs";           Path = "$env:SystemRoot\Logs\CBS" }
    )

    foreach ($item in $cleanPaths) {
        if (Test-Path $item.Path) {
            $before = (Get-ChildItem $item.Path -Recurse -Force -ErrorAction SilentlyContinue |
                       Measure-Object -Property Length -Sum).Sum
            Remove-Item "$($item.Path)\*" -Recurse -Force -ErrorAction SilentlyContinue
            $after  = (Get-ChildItem $item.Path -Recurse -Force -ErrorAction SilentlyContinue |
                       Measure-Object -Property Length -Sum).Sum
            $freed  = [math]::Max(0, $before - $after)
            $totalFreed += $freed
            Write-Host "  ✔  $($item.Label.PadRight(22)) Freed: $(Format-Size $freed)" -ForegroundColor Green
        } else {
            Write-Host "  –  $($item.Label.PadRight(22)) Path not found" -ForegroundColor DarkGray
        }
    }

    # Recycle Bin
    Write-Host ""
    Write-Host "  Emptying Recycle Bin..." -ForegroundColor Gray
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "  ✔  Recycle Bin cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠  Could not clear Recycle Bin (may be empty)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Total Space Freed: $(Format-Size $totalFreed)" -ForegroundColor Green
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host ""
    $runCM = Read-Host "  Also open Windows Disk Cleanup utility? (Y/N)"
    if ($runCM -in @("Y","y")) {
        Start-Process cleanmgr.exe
    }

    Pause-Script
}

# ================================================================
#  OPTION 4 — OPTIMIZE / DEFRAG
# ================================================================
function Optimize-Drives {
    Write-Header "OPTIMIZE / DEFRAG  -  SSD TRIM or HDD Defrag"

    $volumes = Get-Volume -ErrorAction SilentlyContinue |
               Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter }

    Write-Host "  Available Fixed Drives:" -ForegroundColor Yellow
    Write-Host ""
    foreach ($v in $volumes) {
        $size = Format-Size $v.Size
        Write-Host ("  {0,-5} {1,-20} {2}" -f "$($v.DriveLetter):", $v.FileSystemLabel, $size) -ForegroundColor White
    }

    Write-Host ""
    Write-Host "  Type 0 and press Enter to return to Main Menu." -ForegroundColor DarkGray
    $driveInput = Read-Host "  Enter drive letter (e.g. C) or type ALL"
    $driveInput = $driveInput.Trim().ToUpper()
    if ($driveInput -eq "0") { return }

    if ($driveInput -eq "ALL") {
        foreach ($v in $volumes) { Invoke-DriveOptimize $v.DriveLetter }
    } else {
        $letter = $driveInput.TrimEnd(':')
        Invoke-DriveOptimize $letter
    }

    Pause-Script
}

function Invoke-DriveOptimize {
    param([string]$Letter)
    Write-Host ""
    Write-Host "  Optimizing drive ${Letter}: ..." -ForegroundColor Cyan
    Write-Host "  NOTE: This may take a few minutes. Please wait and do NOT close the window." -ForegroundColor Yellow
    Write-Host ""

    try {
        # Detect drive type using defrag /A (works without extra modules)
        $analyseOut = (& defrag "${Letter}:" /A 2>&1) -join " "
        if ($analyseOut -match "solid.state|SSD|not fragment|0% fragmented") {
            # SSD or already optimised - run TRIM via defrag /L
            Write-Host "  Detected: SSD - Running TRIM (defrag /L) ..." -ForegroundColor Yellow
            & defrag "${Letter}:" /L
        } else {
            # HDD - run defrag /U (progress) without verbose flood
            Write-Host "  Detected: HDD - Running Defragmentation (defrag /U /H) ..." -ForegroundColor Yellow
            & defrag "${Letter}:" /U /H
        }
        Write-Host ""
        Write-Host "  [DONE] Operation complete for ${Letter}:" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Could not optimize ${Letter}: $_" -ForegroundColor Red
    }
}

# ================================================================
#  OPTION 5 — DISK SCAN (CHKDSK)
# ================================================================
function Run-ChkDsk {
    Write-Header "DISK SCAN  -  CHKDSK"

    Write-Host "  Options:" -ForegroundColor Yellow
    Write-Host "  1.  Quick Read-Only Scan (no repairs)" -ForegroundColor White
    Write-Host "  2.  Full Scan + Fix Errors (system drive runs on next reboot)" -ForegroundColor White
    Write-Host "  0.  Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
    $opt = Read-Host "  Choose (0, 1 or 2)"
    if ($opt -eq "0") { return }

    Write-Host ""
    Write-Host "  (Enter 0 to return to Main Menu)" -ForegroundColor DarkGray
    $drv = Read-Host "  Enter drive letter (e.g. C)"
    $drv = $drv.Trim().ToUpper().TrimEnd(':')
    if ($drv -eq "0") { return }

    Write-Host ""
    Write-Host "  ── CHKDSK Output ──────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Host ""

    if ($opt -eq "1") {
        Write-Host "  Running read-only scan on ${drv}:..." -ForegroundColor Cyan
        $result = & chkdsk "${drv}:" 2>&1
        $result | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } elseif ($opt -eq "2") {
        if ($drv -eq "C") {
            Write-Host "  C: is the active system drive." -ForegroundColor Yellow
            Write-Host "  CHKDSK will be scheduled to run on the next restart." -ForegroundColor Yellow
            $c = Read-Host "  Schedule now? (Y/N)"
            if ($c -in @("Y","y")) {
                & chkdsk "C:" /f | Out-Null
                Write-Host ""
                Write-Host "  ✔  CHKDSK scheduled. Restart your PC to begin the scan." -ForegroundColor Green
            }
        } else {
            Write-Host "  Running full CHKDSK with repairs on ${drv}:..." -ForegroundColor Cyan
            & chkdsk "${drv}:" /f /r /x 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        }
    } else {
        Write-Host "  Invalid choice." -ForegroundColor Red
    }

    Pause-Script
}

# ================================================================
#  OPTION 6 — FIND LARGEST FILES
# ================================================================
function Find-LargestFiles {
    Write-Header "FIND LARGEST FILES"

    Write-Host ""
    Write-Host "  (Enter 0 to return to Main Menu)" -ForegroundColor DarkGray
    $drv = Read-Host "  Enter drive letter to scan (e.g. C)"
    $drv = $drv.Trim().ToUpper().TrimEnd(':')
    if ($drv -eq "0") { return }

    $top = Read-Host "  How many top files to show? (default: 20)"
    if ([string]::IsNullOrWhiteSpace($top)) { $top = 20 }
    $top = [int]$top

    Write-Host ""
    Write-Host "  Scanning ${drv}:\ for the $top largest files..." -ForegroundColor Cyan
    Write-Host "  (This may take 1-3 minutes on large drives)" -ForegroundColor DarkGray
    Write-Host ""

    try {
        $files = Get-ChildItem -Path "${drv}:\" -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Sort-Object Length -Descending |
                 Select-Object -First $top

        Write-Host ("  {0,-8} {1}" -f "SIZE", "FILE PATH") -ForegroundColor Yellow
        Write-Host ("  " + "─" * 70) -ForegroundColor DarkGray

        $rank = 1
        foreach ($f in $files) {
            $size = Format-Size $f.Length
            $path = $f.FullName
            if ($path.Length -gt 62) { $path = "..." + $path.Substring($path.Length - 59) }
            Write-Host ("  {0,-8} {1}" -f $size, $path) -ForegroundColor White
            $rank++
        }
    } catch {
        Write-Host "  Error during scan: $_" -ForegroundColor Red
    }

    Pause-Script
}

# ================================================================
#  OPTION 7 — FOLDER SIZE ANALYZER
# ================================================================
function Show-FolderSizes {
    do {
        Write-Header "FOLDER SIZE ANALYZER"
        Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
        Write-Host "  │  GRAPHICAL TOOLS (Launch with full visual interface)     │" -ForegroundColor Cyan
        Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
        Write-Host "  │   1.  TreeSize Free   (Tree view  -  recommended)         │" -ForegroundColor Green
        Write-Host "  │   2.  WinDirStat      (Colour disk map  -  open source)   │" -ForegroundColor Green
        Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
        Write-Host "  │  BUILT-IN QUICK SCAN (Console text output)              │" -ForegroundColor Cyan
        Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
        Write-Host "  │   3.  PowerShell Folder Scanner                         │" -ForegroundColor White
        Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
        Write-Host "  │   0.  Back to Main Menu                                 │" -ForegroundColor DarkGray
        Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
        Write-Host ""

        $fsc = Read-Host "  Enter your choice (0-3)"

        switch ($fsc) {
            "1" {
                Write-Header "TREESIZE FREE  -  Folder Size Visualizer"
                $tsPaths = @(
                    "$env:ProgramFiles\JAM Software\TreeSize Free\TreeSizeFree.exe",
                    "${env:ProgramFiles(x86)}\JAM Software\TreeSize Free\TreeSizeFree.exe",
                    "C:\HDD-MasterTool-Tools\TreeSizeFree\TreeSizeFree.exe"
                )
                $found = $tsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($found) {
                    Write-Host "  [OK] TreeSize Free found: $found" -ForegroundColor Green
                    Write-Host "  [*]  Launching TreeSize Free..." -ForegroundColor Cyan
                    Start-Process $found
                } else {
                    Write-Host "  [!] TreeSize Free is not installed." -ForegroundColor Yellow
                    Write-Host ""
                    $dlChoice = Read-Host "  Download TreeSize Free portable now? (Y/N)"
                    if ($dlChoice -match "^[Yy]") {
                        $baseDir = "C:\HDD-MasterTool-Tools"
                        $destDir = "$baseDir\TreeSizeFree"
                        if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
                        $zipFile = "$baseDir\TreeSizeFree-Portable.zip"
                        Write-Host "  [*] Downloading TreeSize Free portable..." -ForegroundColor Cyan
                        try {
                            $ProgressPreference = 'SilentlyContinue'
                            Invoke-WebRequest -Uri "https://downloads.jam-software.de/treesize_free/TreeSizeFree-Portable.zip" `
                                -OutFile $zipFile -UseBasicParsing
                            Write-Host "  [*] Extracting to $destDir..." -ForegroundColor Cyan
                            Expand-Archive -Path $zipFile -DestinationPath $destDir -Force
                            $exeFound = Get-ChildItem -Path $destDir -Recurse -Filter "TreeSizeFree.exe" |
                                Select-Object -First 1
                            if ($exeFound) {
                                Write-Host "  [OK] TreeSize Free ready: $($exeFound.FullName)" -ForegroundColor Green
                                Write-Host "  [*]  Launching TreeSize Free..." -ForegroundColor Cyan
                                Start-Process $exeFound.FullName
                            } else {
                                Write-Host "  [!] TreeSizeFree.exe not found in archive." -ForegroundColor Red
                            }
                            Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
                        } catch {
                            Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                            Write-Host "  [i] Manual: https://www.jam-software.com/treesize_free" -ForegroundColor DarkGray
                        }
                    } else {
                        Write-Host "  [i] Skipped. Manual: https://www.jam-software.com/treesize_free" -ForegroundColor DarkGray
                    }
                }
                Pause-Script
            }
            "2" {
                Write-Header "WINDIRSTAT  -  Disk Usage Colour Map"
                $wdsPaths = @(
                    "$env:ProgramFiles\WinDirStat\windirstat.exe",
                    "${env:ProgramFiles(x86)}\WinDirStat\windirstat.exe"
                )
                $found = $wdsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($found) {
                    Write-Host "  [OK] WinDirStat found: $found" -ForegroundColor Green
                    Write-Host "  [*]  Launching WinDirStat..." -ForegroundColor Cyan
                    Start-Process $found
                } else {
                    Write-Host "  [!] WinDirStat is not installed." -ForegroundColor Yellow
                    Write-Host ""
                    $dlChoice = Read-Host "  Download WinDirStat installer now? (Y/N)"
                    if ($dlChoice -match "^[Yy]") {
                        $toolDir = "C:\HDD-MasterTool-Tools"
                        if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir -Force | Out-Null }
                        $dest = "$toolDir\windirstat_setup.exe"
                        Write-Host "  [*] Downloading WinDirStat..." -ForegroundColor Cyan
                        try {
                            $ProgressPreference = 'SilentlyContinue'
                            Invoke-WebRequest -Uri "https://windirstat.net/wds_current_setup.exe" `
                                -OutFile $dest -UseBasicParsing
                            Write-Host "  [OK] Saved to: $dest" -ForegroundColor Green
                            Write-Host "  [*] Launching WinDirStat installer..." -ForegroundColor Cyan
                            Start-Process $dest
                        } catch {
                            Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                            Write-Host "  [i] Manual: https://windirstat.net" -ForegroundColor DarkGray
                        }
                    } else {
                        Write-Host "  [i] Skipped. Manual: https://windirstat.net" -ForegroundColor DarkGray
                    }
                }
                Pause-Script
            }
            "3" {
                Write-Header "POWERSHELL FOLDER SCANNER"
                Write-Host ""
                $path = Read-Host "  Enter folder path to analyze (e.g. C:\Users or D:\)"
                $path = $path.Trim().Trim('"')

                if (-not (Test-Path $path)) {
                    Write-Host "  [!] Path not found: $path" -ForegroundColor Red
                    Pause-Script; continue
                }

                Write-Host ""
                Write-Host "  Calculating sizes inside: $path" -ForegroundColor Cyan
                Write-Host "  (Please wait...)" -ForegroundColor DarkGray
                Write-Host ""

                $subFolders = Get-ChildItem -Path $path -Directory -Force -ErrorAction SilentlyContinue

                $results = foreach ($folder in $subFolders) {
                    $sz = (Get-ChildItem -Path $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                             Measure-Object -Property Length -Sum).Sum
                    [PSCustomObject]@{
                        Name      = $folder.Name
                        SizeBytes = if ($null -eq $sz) { 0 } else { $sz }
                        SizeStr   = Format-Size (if ($null -eq $sz) { 0 } else { $sz })
                    }
                }

                $results = $results | Sort-Object SizeBytes -Descending

                Write-Host ("  {0,-45} {1,12}" -f "FOLDER NAME", "SIZE") -ForegroundColor Yellow
                Write-Host ("  " + "─" * 59) -ForegroundColor DarkGray

                foreach ($r in $results) {
                    $n = if ($r.Name.Length -gt 43) { $r.Name.Substring(0,40) + "..." } else { $r.Name }
                    Write-Host ("  {0,-45} {1,12}" -f $n, $r.SizeStr) -ForegroundColor White
                }
                Pause-Script
            }
            "0" { return }
            default {
                Write-Host "  Invalid option." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

# ================================================================
#  OPTION 8  -  DRIVE SPEED TEST
# ================================================================
function Run-SpeedTest {
    Write-Header "DRIVE SPEED TEST"

    Write-Host ""
    Write-Host "  (Enter 0 to return to Main Menu)" -ForegroundColor DarkGray
    $drv = Read-Host "  Enter drive letter to test (e.g. C)"
    $drv = $drv.Trim().ToUpper().TrimEnd(':')
    if ($drv -eq "0") { return }

    $testFile   = "${drv}:\__hdd_speedtest_temp__.dat"
    $testSizeMB = 256
    $buffer     = New-Object byte[] (1MB)
    (New-Object Random).NextBytes($buffer)

    Write-Host ""
    Write-Host "  Testing with $testSizeMB MB file on ${drv}:..." -ForegroundColor Cyan
    Write-Host ""

    # ── WRITE TEST ──
    Write-Host "  ► WRITE TEST..." -ForegroundColor Yellow
    $writeSpeed = 0
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $fs = [System.IO.File]::OpenWrite($testFile)
        for ($i = 0; $i -lt $testSizeMB; $i++) { $fs.Write($buffer, 0, $buffer.Length) }
        $fs.Flush(); $fs.Close()
        $sw.Stop()
        $writeSpeed = [math]::Round($testSizeMB / $sw.Elapsed.TotalSeconds, 1)
        Write-Host "    Write Speed : $writeSpeed MB/s" -ForegroundColor Green
    } catch {
        Write-Host "    Write failed : $_" -ForegroundColor Red
        if (Test-Path $testFile) { Remove-Item $testFile -Force }
        Pause-Script; return
    }

    # ── READ TEST ──
    Write-Host ""
    Write-Host "  ► READ TEST..." -ForegroundColor Yellow
    $readSpeed  = 0
    $readBuffer = New-Object byte[] (1MB)
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $fs = [System.IO.File]::OpenRead($testFile)
        while ($fs.Read($readBuffer, 0, $readBuffer.Length) -gt 0) {}
        $fs.Close()
        $sw.Stop()
        $readSpeed = [math]::Round($testSizeMB / $sw.Elapsed.TotalSeconds, 1)
        Write-Host "    Read Speed  : $readSpeed MB/s" -ForegroundColor Green
    } catch {
        Write-Host "    Read failed : $_" -ForegroundColor Red
    }

    if (Test-Path $testFile) { Remove-Item $testFile -Force }

    # ── RESULT ──
    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Write : $writeSpeed MB/s    Read : $readSpeed MB/s" -ForegroundColor White

    $rating = if     ($readSpeed -gt 1000) { "★★★★★ NVMe SSD (Excellent)" }
              elseif ($readSpeed -gt 400)  { "★★★★☆ SATA SSD (Very Good)" }
              elseif ($readSpeed -gt 100)  { "★★★☆☆ HDD 7200rpm (Average)" }
              else                         { "★★☆☆☆ Slow — HDD 5400rpm or aging drive" }

    $rColor = if ($readSpeed -gt 400) { "Green" } elseif ($readSpeed -gt 100) { "Yellow" } else { "Red" }
    Write-Host "   Rating: $rating" -ForegroundColor $rColor
    Write-Host "  ══════════════════════════════════════════════" -ForegroundColor Cyan

    Pause-Script
}

# ================================================================
#  OPTION 9  -  ROBOCOPY
# ================================================================
function Run-RoboCopy {
    Write-Header "ROBOCOPY — Smart File & Folder Copy"

    Write-Host "  ── STEP 1: SOURCE ──────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "  Paste or type the source path below:" -ForegroundColor Gray
    Write-Host "  (Type 0 and press Enter to return to Main Menu)" -ForegroundColor DarkGray
    Write-Host ""
    $source = Read-Host "  SOURCE"
    $source = $source.Trim().Trim('"')
    if ($source -eq "0") { return }

    Write-Host ""
    Write-Host "  ── STEP 2: DESTINATION ─────────────────────────────────" -ForegroundColor Yellow
    Write-Host "  Paste or type the destination path below:" -ForegroundColor Gray
    Write-Host ""
    $dest = Read-Host "  DESTINATION"
    $dest = $dest.Trim().Trim('"')

    # Validate source
    if (-not (Test-Path $source)) {
        Write-Host ""
        Write-Host "  ✘  Source path not found:" -ForegroundColor Red
        Write-Host "     $source" -ForegroundColor Red
        Pause-Script; return
    }

    # Create destination if missing
    if (-not (Test-Path $dest)) {
        Write-Host ""
        Write-Host "  Destination does not exist. Creating it..." -ForegroundColor Yellow
        try {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            Write-Host "  ✔  Created: $dest" -ForegroundColor Green
        } catch {
            Write-Host "  ✘  Cannot create destination: $_" -ForegroundColor Red
            Pause-Script; return
        }
    }

    # ── COPY MODE ──
    Write-Host ""
    Write-Host "  ── STEP 3: COPY MODE ───────────────────────────────────" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1.  COPY       — Copy new & updated files only (safe)" -ForegroundColor White
    Write-Host "  2.  MIRROR     — Exact copy; DELETES files not in source" -ForegroundColor Red
    Write-Host "  3.  BACKUP     — Copy all with timestamps & attributes" -ForegroundColor White
    Write-Host "  4.  MOVE       — Copy then DELETE from source" -ForegroundColor Red
    Write-Host "  5.  SYNC ONLY  — Copy only newer files (skip unchanged)" -ForegroundColor White
    Write-Host "  6.  CUSTOM     — Enter your own robocopy flags" -ForegroundColor DarkGray
    Write-Host ""
    $mode = Read-Host "  Choose mode (1-6)"

    # ── FILE FILTER ──
    Write-Host ""
    Write-Host "  ── STEP 4: FILE FILTER ─────────────────────────────────" -ForegroundColor Yellow
    Write-Host "  Leave blank = copy ALL files" -ForegroundColor Gray
    Write-Host "  Examples: *.pdf   *.docx   *.xlsx   *.log   *.*" -ForegroundColor DarkGray
    Write-Host ""
    $filter = Read-Host "  File filter"
    if ([string]::IsNullOrWhiteSpace($filter)) { $filter = "*.*" }

    # ── EXCLUDE OPTIONS ──
    Write-Host ""
    Write-Host "  ── STEP 5: EXCLUDE (optional) ──────────────────────────" -ForegroundColor Yellow
    Write-Host "  Exclude folders? (e.g. Temp Logs Cache) — press Enter to skip" -ForegroundColor Gray
    $excludeDirs = Read-Host "  Exclude folders"

    Write-Host "  Exclude files? (e.g. *.tmp *.bak) — press Enter to skip" -ForegroundColor Gray
    $excludeFiles = Read-Host "  Exclude files"

    # ── LOG ──
    Write-Host ""
    Write-Host "  ── STEP 6: SAVE LOG ────────────────────────────────────" -ForegroundColor Yellow
    $saveLog = Read-Host "  Save copy log to Desktop? (Y/N)"
    $logPath = ""
    if ($saveLog -in @("Y","y")) {
        $ts      = Get-Date -Format "yyyyMMdd_HHmmss"
        $logPath = "$env:USERPROFILE\Desktop\Robocopy_Log_$ts.txt"
    }

    # Build flags
    $flags = switch ($mode) {
        "1" { "/E /COPYALL /R:3 /W:5 /NP" }            # Copy
        "2" { "/MIR /COPYALL /R:3 /W:5 /NP" }          # Mirror
        "3" { "/E /COPYALL /DCOPY:T /ZB /R:3 /W:5 /NP" }  # Backup
        "4" { "/E /MOVE /COPYALL /R:3 /W:5 /NP" }      # Move
        "5" { "/E /COPYALL /XO /R:3 /W:5 /NP" }        # Sync newer
        "6" {
            Write-Host ""
            Write-Host "  Common flags:" -ForegroundColor DarkGray
            Write-Host "  /E=subfolders /MIR=mirror /COPYALL=all attrs /XO=skip older" -ForegroundColor DarkGray
            Write-Host "  /XF=excl files /XD=excl dirs /R:n=retries /W:n=wait secs" -ForegroundColor DarkGray
            Read-Host "  Enter flags"
        }
        default { "/E /COPYALL /R:3 /W:5 /NP" }
    }

    # Warnings for destructive modes
    if ($mode -in @("2","4")) {
        Write-Host ""
        if ($mode -eq "2") {
            Write-Host "  ⚠  WARNING: MIRROR will DELETE files in destination" -ForegroundColor Red
            Write-Host "     that do NOT exist in source. This cannot be undone!" -ForegroundColor Red
        } else {
            Write-Host "  ⚠  WARNING: MOVE will DELETE files from SOURCE after copy!" -ForegroundColor Red
        }
        $ok = Read-Host "  Are you absolutely sure? Type YES to confirm"
        if ($ok -ne "YES") {
            Write-Host "  Cancelled." -ForegroundColor Yellow
            Pause-Script; return
        }
    }

    # Build exclude args
    $excludeArgs = ""
    if (-not [string]::IsNullOrWhiteSpace($excludeDirs)) {
        $excludeArgs += " /XD $excludeDirs"
    }
    if (-not [string]::IsNullOrWhiteSpace($excludeFiles)) {
        $excludeArgs += " /XF $excludeFiles"
    }

    # Build log arg
    $logArg = ""
    if ($logPath) { $logArg = " /LOG:`"$logPath`" /TEE" }

    # Full command
    $fullCmd = "robocopy `"$source`" `"$dest`" $filter $flags$excludeArgs$logArg"

    Write-Host ""
    Write-Host "  ── COMMAND PREVIEW ─────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  $fullCmd" -ForegroundColor White
    Write-Host ""
    Write-Host "  ────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    $run = Read-Host "  Run this command now? (Y/N)"
    if ($run -notin @("Y","y")) {
        Write-Host "  Cancelled." -ForegroundColor Yellow
        Pause-Script; return
    }

    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   ROBOCOPY RUNNING — Do not close this window..." -ForegroundColor Green
    Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    # Build argument list for Start-Process
    $roboArgs = "`"$source`" `"$dest`" $filter $flags$excludeArgs$logArg"
    $proc = Start-Process -FilePath "robocopy" -ArgumentList $roboArgs `
            -Wait -PassThru -NoNewWindow

    $exit = $proc.ExitCode
    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan

    # Robocopy exit code interpretation
    $exitMsg = switch -Wildcard ($exit) {
        0       { "✔  No files needed copying (source & destination already in sync)" }
        1       { "✔  Copy successful — new files copied" }
        2       { "✔  Extra files deleted from destination (mirror mode)" }
        3       { "✔  Copy successful — files copied and extras removed" }
        { $_ -le 7 } { "⚠  Copy done with some mismatches or skipped files (Exit: $exit)" }
        { $_ -ge 8 } { "✘  ERRORS occurred — some files failed to copy (Exit: $exit)" }
    }

    $exitColor = if ($exit -le 3) { "Green" } elseif ($exit -le 7) { "Yellow" } else { "Red" }
    Write-Host "   $exitMsg" -ForegroundColor $exitColor

    if ($logPath -and (Test-Path $logPath)) {
        Write-Host ""
        Write-Host "  Log saved to Desktop:" -ForegroundColor Cyan
        Write-Host "  $logPath" -ForegroundColor White
    }

    Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan

    Pause-Script
}

# ================================================================
#  OPTION 10  -  SECURE ERASE / SANITIZE
# ================================================================
function Run-SecureErase {
    Write-Header "SECURE ERASE / SANITIZE — Wipe Drive Data"

    Write-Host "  ⚠  READ BEFORE PROCEEDING:" -ForegroundColor Red
    Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  • Secure erase is IRREVERSIBLE. All data will be gone." -ForegroundColor Yellow
    Write-Host "  • Always verify you have selected the correct drive." -ForegroundColor Yellow
    Write-Host "  • Never erase your C: (system) drive while Windows is running." -ForegroundColor Yellow
    Write-Host "  • Verify backups exist before proceeding." -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Cyan
    Write-Host "  1.  Wipe FREE SPACE only (cipher /w — safe, no data loss)" -ForegroundColor White
    Write-Host "      Overwrites deleted file remnants on a drive." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  2.  Full Drive Wipe — 3-Pass Format (DESTROYS ALL DATA)" -ForegroundColor Red
    Write-Host "      Uses Windows format /p:3 — 3 random overwrite passes." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  3.  Single-Pass Zero Fill (DESTROYS ALL DATA)" -ForegroundColor Red
    Write-Host "      Uses format /p:1 — fast single pass for quick disposal." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  0.  Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
    $opt = Read-Host "  Choose option (0/1/2/3)"
    if ($opt -eq "0") { return }

    if ($opt -eq "1") {
        # ── Free Space Wipe (SAFE) ──────────────────────────────
        Write-Host ""
        $drv = Read-Host "  Enter drive letter to wipe free space (e.g. D)"
        $drv = $drv.ToUpper().TrimEnd(':')

        if (-not (Test-Path "${drv}:\")) {
            Write-Host "  ✘  Drive not found." -ForegroundColor Red
            Pause-Script; return
        }

        Write-Host ""
        Write-Host "  Wiping free space on ${drv}: using cipher /w ..." -ForegroundColor Cyan
        Write-Host "  (This can take several minutes depending on free space)" -ForegroundColor DarkGray
        Write-Host ""
        & cipher /w:"${drv}:\"
        Write-Host ""
        Write-Host "  ✔  Free space wipe complete on ${drv}:" -ForegroundColor Green

    } elseif ($opt -in @("2","3")) {
        # ── Full Drive Wipe ─────────────────────────────────────
        $passes = if ($opt -eq "2") { 3 } else { 1 }
        Write-Host ""

        $volumes = Get-Volume -ErrorAction SilentlyContinue |
                   Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter }
        Write-Host "  Fixed drives available:" -ForegroundColor Yellow
        foreach ($v in $volumes) {
            Write-Host ("  {0,-5} {1,-20} {2}" -f "$($v.DriveLetter):", $v.FileSystemLabel, (Format-Size $v.Size)) -ForegroundColor White
        }

        Write-Host ""
        $drv = Read-Host "  Enter drive letter to WIPE (e.g. D)"
        $drv = $drv.ToUpper().TrimEnd(':')

        if ($drv -eq "C") {
            Write-Host "  ✘  Cannot wipe C: (system drive) while Windows is running." -ForegroundColor Red
            Pause-Script; return
        }

        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║  FINAL WARNING — THIS IS IRREVERSIBLE!              ║" -ForegroundColor Red
        Write-Host "  ║  Drive ${drv}: will be completely wiped ($passes-pass).     ║" -ForegroundColor Red
        Write-Host "  ║  ALL DATA WILL BE PERMANENTLY DESTROYED.            ║" -ForegroundColor Red
        Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        $confirm = Read-Host "  Type WIPE to confirm, or anything else to cancel"

        if ($confirm -ne "WIPE") {
            Write-Host "  Cancelled. No changes made." -ForegroundColor Green
            Pause-Script; return
        }

        Write-Host ""
        Write-Host "  Starting $passes-pass wipe on ${drv}: ..." -ForegroundColor Cyan
        Write-Host "  (Do not close this window)" -ForegroundColor DarkGray
        Write-Host ""

        # Detect filesystem for format command
        $fsType = (Get-Volume -DriveLetter $drv -ErrorAction SilentlyContinue).FileSystem
        if (-not $fsType) { $fsType = "NTFS" }

        $formatArgs = "${drv}: /FS:$fsType /P:$passes /Q /Y"
        $proc = Start-Process -FilePath "format" -ArgumentList $formatArgs -Wait -PassThru -NoNewWindow

        if ($proc.ExitCode -eq 0) {
            Write-Host ""
            Write-Host "  ✔  $passes-pass wipe complete on ${drv}:" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "  ⚠  Format may have encountered issues (Exit: $($proc.ExitCode))" -ForegroundColor Yellow
        }

    } else {
        Write-Host "  Invalid choice." -ForegroundColor Red
    }

    Pause-Script
}

# ================================================================
#  OPTION 11  -  DISK IMAGING / CLONE
# ================================================================
function Run-DiskImaging {
    Write-Header "DISK IMAGING / CLONE — Windows System Backup"

    Write-Host "  Windows Built-in Imaging Tools:" -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  1.  Create System Image (wbadmin — full C: backup to external)" -ForegroundColor White
    Write-Host "  2.  Launch Windows Backup GUI (Control Panel backup)" -ForegroundColor White
    Write-Host "  3.  Launch Recovery Drive Creator (bootable USB)" -ForegroundColor White
    Write-Host "  4.  View Backup Status (wbadmin get status)" -ForegroundColor White
    Write-Host "  5.  List available disk volumes for imaging" -ForegroundColor White
    Write-Host "  0.  Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  NOTE: For failing drives, use ddrescue (Linux) or" -ForegroundColor DarkGray
    Write-Host "  Macrium Reflect / Clonezilla (free) for sector-level imaging." -ForegroundColor DarkGray
    Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    $opt = Read-Host "  Choose option (0-5)"
    if ($opt -eq "0") { return }

    switch ($opt) {
        "1" {
            Write-Host ""
            Write-Host "  Available drives for backup target:" -ForegroundColor Yellow
            $volumes = Get-Volume -ErrorAction SilentlyContinue |
                       Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter -and $_.DriveLetter -ne "C" }
            foreach ($v in $volumes) {
                Write-Host ("  {0,-5} {1,-20} {2}" -f "$($v.DriveLetter):", $v.FileSystemLabel, (Format-Size $v.Size)) -ForegroundColor White
            }
            Write-Host ""
            $target = Read-Host "  Enter DESTINATION drive letter (e.g. D)"
            $target = $target.ToUpper().TrimEnd(':')

            Write-Host ""
            Write-Host "  ── System Image Backup ──────────────────────────────" -ForegroundColor Cyan
            Write-Host "  Source  : C: (System Drive)" -ForegroundColor White
            Write-Host "  Target  : ${target}:" -ForegroundColor White
            Write-Host ""
            $go = Read-Host "  Start system image backup? (Y/N)"
            if ($go -in @("Y","y")) {
                Write-Host ""
                Write-Host "  Running wbadmin backup — this may take 15-60 minutes..." -ForegroundColor Cyan
                Write-Host "  (Do not close this window)" -ForegroundColor DarkGray
                Write-Host ""
                & wbadmin start backup -backupTarget:"${target}:" -include:C: -allCritical -quiet
                Write-Host ""
                Write-Host "  ✔  Backup job submitted. Check above output for result." -ForegroundColor Green
            }
        }
        "2" {
            Write-Host "  Launching Windows Backup..." -ForegroundColor Cyan
            Start-Process "control" -ArgumentList "/name Microsoft.BackupAndRestore"
        }
        "3" {
            Write-Host "  Launching Recovery Drive Creator..." -ForegroundColor Cyan
            Start-Process "recoverydrive.exe"
        }
        "4" {
            Write-Host ""
            Write-Host "  ── Backup Status ────────────────────────────────────" -ForegroundColor Cyan
            Write-Host ""
            & wbadmin get status 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        }
        "5" {
            Write-Host ""
            Write-Host "  ── All Disk Volumes ─────────────────────────────────" -ForegroundColor Cyan
            Write-Host ""
            Get-Disk -ErrorAction SilentlyContinue | ForEach-Object {
                $d = $_
                Write-Host "  Disk $($d.Number): $($d.FriendlyName)  |  $(Format-Size $d.Size)  |  $($d.BusType)" -ForegroundColor White
                Get-Partition -DiskNumber $d.Number -ErrorAction SilentlyContinue | ForEach-Object {
                    $letter = if ($_.DriveLetter) { "$($_.DriveLetter):" } else { "(no letter)" }
                    Write-Host "    Partition $($_.PartitionNumber): $letter  $(Format-Size $_.Size)" -ForegroundColor Gray
                }
                Write-Host ""
            }
        }
        "0" { return }
        default { Write-Host "  Invalid choice." -ForegroundColor Red }
    }

    Pause-Script
}

# ================================================================
#  OPTION 12  -  SAFETY CHECKLIST (from PDF reference)
# ================================================================
function Show-SafetyChecklist {
    Write-Header "SAFETY CHECKLIST — Rules Before Working on Any Drive"

    Write-Host "  Based on HDD Master Toolkit reference guide." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "  ║  CRITICAL SAFETY RULES — READ BEFORE ANY DISK WORK     ║" -ForegroundColor Yellow
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""

    $rules = @(
        @{ Num="1"; Color="Red";    Text="IMAGE FIRST. Use ddrescue/Macrium Reflect to back up a" },
        @{ Num=" "; Color="Red";    Text="   failing drive BEFORE any scan, repair, or chkdsk." },
        @{ Num="2"; Color="Red";    Text="NEVER run chkdsk /r, fsck, or REMAP on a drive whose data" },
        @{ Num=" "; Color="Red";    Text="   matters — they WRITE and can destroy data in bad sectors." },
        @{ Num="3"; Color="Yellow"; Text="Don't scan repeatedly to see how bad it is — repeated scans" },
        @{ Num=" "; Color="Yellow"; Text="   accelerate failure. SMART reads are safe; use those." },
        @{ Num="4"; Color="Red";    Text="Clicking / beeping / undetected in BIOS = MECHANICAL FAILURE." },
        @{ Num=" "; Color="Red";    Text="   STOP immediately. Use a professional recovery lab." },
        @{ Num="5"; Color="Yellow"; Text="Work on copies — all analysis on the IMAGE, never the original." },
        @{ Num="6"; Color="White";  Text="Power down before connecting. Ground yourself (ESD)." },
        @{ Num=" "; Color="White";  Text="   NEVER open the drive — dust kills platters instantly." },
        @{ Num="7"; Color="Yellow"; Text="Mount failing drives READ-ONLY. Never install recovery" },
        @{ Num=" "; Color="Yellow"; Text="   software onto the drive being recovered." },
        @{ Num="8"; Color="Red";    Text="Secure erase and remap are IRREVERSIBLE — verify backups" },
        @{ Num=" "; Color="Red";    Text="   and double-check device/drive letters first." }
    )

    foreach ($r in $rules) {
        if ($r.Num -ne " ") {
            Write-Host ("  [{0}] {1}" -f $r.Num, $r.Text) -ForegroundColor $r.Color
        } else {
            Write-Host ("     {0}" -f $r.Text) -ForegroundColor $r.Color
        }
    }

    Write-Host ""
    Write-Host "  ── RECOMMENDED WORKFLOW (from PDF) ──────────────────────" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Step 1.  SMART read — CrystalDiskInfo or Option 2 (Health Check)" -ForegroundColor White
    Write-Host "  Step 2.  If HEALTHY  → benchmark / scan / repair as needed" -ForegroundColor Green
    Write-Host "  Step 3.  If DEGRADED → ddrescue image IMMEDIATELY (Option 11)" -ForegroundColor Red
    Write-Host "  Step 4.  Recover data from the IMAGE (DMDE / TestDisk / Recuva)" -ForegroundColor Yellow
    Write-Host "  Step 5.  Only then consider repair/remap, or replace the drive" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  ── TOOL REFERENCE ───────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  CrystalDiskInfo    — SMART health (Windows, free)" -ForegroundColor White
    Write-Host "  Macrium Reflect    — Disk imaging & cloning (free)" -ForegroundColor White
    Write-Host "  Recuva / DMDE      — Data recovery (free)" -ForegroundColor White
    Write-Host "  TestDisk           — Partition/filesystem repair (free)" -ForegroundColor White
    Write-Host "  Victoria HDD       — Deep surface scan & sector remap" -ForegroundColor White
    Write-Host "  GNU ddrescue       — Best-in-class imaging of failing drives" -ForegroundColor White
    Write-Host "  SeaTools           — Seagate manufacturer diagnostic" -ForegroundColor White
    Write-Host "  WD Data Lifeguard  — Western Digital diagnostic tool" -ForegroundColor White

    Pause-Script
}

# ================================================================
#  OPTION 13  -  DATA RECOVERY TOOLS
# ================================================================
function Run-DataRecovery {
    Write-Header "DATA RECOVERY TOOLS"

    Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │  BUILT-IN WINDOWS RECOVERY                              │" -ForegroundColor Cyan
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host "  │   1.  SFC — System File Checker  (Repair system files)  │" -ForegroundColor White
    Write-Host "  │   2.  DISM — Repair Windows Image                       │" -ForegroundColor White
    Write-Host "  │   3.  CHKDSK — Scan & Fix Drive Errors (specify drive)  │" -ForegroundColor White
    Write-Host "  │   4.  Fix Boot Record  (bootrec — MBR / Boot Sector)    │" -ForegroundColor White
    Write-Host "  │   5.  Shadow Copy Restore  (vssadmin list shadows)      │" -ForegroundColor White
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host "  │  THIRD-PARTY RECOVERY TOOLS                             │" -ForegroundColor Cyan
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host "  │   6.  Recuva          (Free file recovery - Piriform)   │" -ForegroundColor Green
    Write-Host "  │   7.  TestDisk        (Partition & boot repair)         │" -ForegroundColor Green
    Write-Host "  │   8.  PhotoRec        (Photo & file recovery)           │" -ForegroundColor Green
    Write-Host "  │   9.  MiniTool Free   (Free data recovery software)     │" -ForegroundColor Green
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host "  │   0.  Back to Main Menu                                 │" -ForegroundColor DarkGray
    Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""

    $sub = Read-Host "  Enter option (0-9)"

    switch ($sub) {
        "1" {
            Write-Header "SFC — System File Checker"
            Write-Host "  [*] Scanning and repairing protected system files..." -ForegroundColor Cyan
            Write-Host "  [*] This may take 5-10 minutes. Please wait." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Command: sfc /scannow" -ForegroundColor DarkGray
            Write-Host ""
            sfc /scannow
        }
        "2" {
            Write-Header "DISM — Repair Windows Image"
            Write-Host "  [*] Step 1: Checking Windows image health..." -ForegroundColor Cyan
            Write-Host "  Command: DISM /Online /Cleanup-Image /CheckHealth" -ForegroundColor DarkGray
            Write-Host ""
            DISM /Online /Cleanup-Image /CheckHealth
            Write-Host ""
            Write-Host "  [*] Step 2: Scanning Windows image..." -ForegroundColor Cyan
            Write-Host "  Command: DISM /Online /Cleanup-Image /ScanHealth" -ForegroundColor DarkGray
            Write-Host ""
            DISM /Online /Cleanup-Image /ScanHealth
            Write-Host ""
            Write-Host "  [*] Step 3: Restoring Windows image health..." -ForegroundColor Cyan
            Write-Host "  Command: DISM /Online /Cleanup-Image /RestoreHealth" -ForegroundColor DarkGray
            Write-Host ""
            DISM /Online /Cleanup-Image /RestoreHealth
        }
        "3" {
            Write-Header "CHKDSK — Scan & Fix Drive Errors"
            Write-Host "  Enter the drive letter to scan (e.g. C or D):" -ForegroundColor Cyan
            $drv = (Read-Host "  Drive letter").Trim().ToUpper() -replace ":", ""
            if ($drv -match "^[A-Z]$") {
                Write-Host ""
                Write-Host "  [*] Running CHKDSK on drive ${drv}:..." -ForegroundColor Yellow
                Write-Host "  [*] If drive is in use, it will schedule for next reboot." -ForegroundColor Yellow
                Write-Host "  Command: chkdsk ${drv}: /f /r /x" -ForegroundColor DarkGray
                Write-Host ""
                chkdsk "${drv}:" /f /r /x
            } else {
                Write-Host "  [!] Invalid drive letter entered." -ForegroundColor Red
            }
        }
        "4" {
            Write-Header "FIX BOOT RECORD (bootrec)"
            Write-Host "  [!] WARNING: This modifies the Master Boot Record." -ForegroundColor Red
            Write-Host "  [!] Only use if Windows fails to boot normally." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Options:" -ForegroundColor Cyan
            Write-Host "   A.  Fix MBR only          (bootrec /fixmbr)" -ForegroundColor White
            Write-Host "   B.  Fix Boot Sector only   (bootrec /fixboot)" -ForegroundColor White
            Write-Host "   C.  Rebuild BCD            (bootrec /rebuildbcd)" -ForegroundColor White
            Write-Host "   D.  Run ALL three          (Recommended for boot failure)" -ForegroundColor Green
            Write-Host ""
            $bootOpt = (Read-Host "  Choose A / B / C / D").Trim().ToUpper()
            switch ($bootOpt) {
                "A" { bootrec /fixmbr }
                "B" { bootrec /fixboot }
                "C" { bootrec /rebuildbcd }
                "D" {
                    Write-Host ""
                    Write-Host "  [*] Fixing MBR..." -ForegroundColor Cyan
                    bootrec /fixmbr
                    Write-Host ""
                    Write-Host "  [*] Fixing Boot Sector..." -ForegroundColor Cyan
                    bootrec /fixboot
                    Write-Host ""
                    Write-Host "  [*] Rebuilding BCD..." -ForegroundColor Cyan
                    bootrec /rebuildbcd
                }
                default { Write-Host "  Invalid option." -ForegroundColor Red }
            }
            Write-Host ""
            Write-Host "  [i] Note: bootrec commands run from Windows Recovery Environment (WinRE)." -ForegroundColor DarkGray
        }
        "5" {
            Write-Header "SHADOW COPY — Previous Versions"
            Write-Host "  [*] Listing all Shadow Copies on this system..." -ForegroundColor Cyan
            Write-Host "  Command: vssadmin list shadows" -ForegroundColor DarkGray
            Write-Host ""
            vssadmin list shadows
            Write-Host ""
            Write-Host "  [i] To restore files from Previous Versions:" -ForegroundColor Yellow
            Write-Host "  [i]  1. Right-click any folder in Explorer" -ForegroundColor DarkGray
            Write-Host "  [i]  2. Select Properties -> Previous Versions tab" -ForegroundColor DarkGray
            Write-Host "  [i]  3. Choose a restore point and click Restore" -ForegroundColor DarkGray
        }
        "6" {
            Write-Header "RECUVA — File Recovery Tool"
            $recuvaPaths = @(
                "$env:ProgramFiles\Recuva\Recuva.exe",
                "${env:ProgramFiles(x86)}\Recuva\Recuva.exe",
                "$env:LOCALAPPDATA\Recuva\Recuva.exe"
            )
            $found = $recuvaPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($found) {
                Write-Host "  [OK] Recuva found: $found" -ForegroundColor Green
                Write-Host "  [*]  Launching Recuva..." -ForegroundColor Cyan
                Start-Process $found
            } else {
                Write-Host "  [!] Recuva is not installed." -ForegroundColor Yellow
                Write-Host ""
                $dlChoice = Read-Host "  Download Recuva installer now? (Y/N)"
                if ($dlChoice -match "^[Yy]") {
                    $toolDir = "C:\HDD-MasterTool-Tools"
                    if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir -Force | Out-Null }
                    $dest = "$toolDir\rcsetup.exe"
                    Write-Host "  [*] Downloading Recuva from Piriform..." -ForegroundColor Cyan
                    try {
                        $ProgressPreference = 'SilentlyContinue'
                        Invoke-WebRequest -Uri "https://download.ccleaner.com/rcsetup156.exe" `
                            -OutFile $dest -UseBasicParsing
                        Write-Host "  [OK] Saved to: $dest" -ForegroundColor Green
                        Write-Host "  [*] Launching Recuva installer..." -ForegroundColor Cyan
                        Start-Process $dest
                    } catch {
                        Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                        Write-Host "  [i] Manual: https://www.ccleaner.com/recuva/download" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "  [i] Skipped. Manual: https://www.ccleaner.com/recuva/download" -ForegroundColor DarkGray
                }
            }
        }
        "7" {
            Write-Header "TESTDISK — Partition & Boot Repair"
            $tdPaths = @(
                "$env:ProgramFiles\TestDisk\testdisk_win.exe",
                "${env:ProgramFiles(x86)}\TestDisk\testdisk_win.exe",
                "C:\Tools\TestDisk\testdisk_win.exe"
            )
            $found = $tdPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($found) {
                Write-Host "  [OK] TestDisk found: $found" -ForegroundColor Green
                Write-Host "  [*]  Launching TestDisk..." -ForegroundColor Cyan
                Start-Process $found
            } else {
                Write-Host "  [!] TestDisk is not installed." -ForegroundColor Yellow
                Write-Host ""
                $dlChoice = Read-Host "  Download TestDisk portable ZIP now? (Y/N)"
                if ($dlChoice -match "^[Yy]") {
                    $baseDir = "C:\HDD-MasterTool-Tools"
                    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
                    $zipFile = "$baseDir\testdisk.zip"
                    Write-Host "  [*] Downloading TestDisk portable..." -ForegroundColor Cyan
                    try {
                        $ProgressPreference = 'SilentlyContinue'
                        Invoke-WebRequest -Uri "https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip" `
                            -OutFile $zipFile -UseBasicParsing
                        Write-Host "  [*] Extracting..." -ForegroundColor Cyan
                        Expand-Archive -Path $zipFile -DestinationPath $baseDir -Force
                        $exeFound = Get-ChildItem -Path $baseDir -Recurse -Filter "testdisk_win.exe" |
                            Select-Object -First 1
                        if ($exeFound) {
                            Write-Host "  [OK] TestDisk ready: $($exeFound.FullName)" -ForegroundColor Green
                            Write-Host "  [*] Launching TestDisk..." -ForegroundColor Cyan
                            Start-Process $exeFound.FullName
                        } else {
                            Write-Host "  [!] testdisk_win.exe not found in archive." -ForegroundColor Red
                        }
                        Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
                    } catch {
                        Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                        Write-Host "  [i] Manual: https://www.cgsecurity.org/wiki/TestDisk_Download" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "  [i] Skipped. Manual: https://www.cgsecurity.org/wiki/TestDisk_Download" -ForegroundColor DarkGray
                }
            }
        }
        "8" {
            Write-Header "PHOTOREC — Photo & File Recovery"
            $prPaths = @(
                "$env:ProgramFiles\TestDisk\photorec_win.exe",
                "${env:ProgramFiles(x86)}\TestDisk\photorec_win.exe",
                "C:\Tools\TestDisk\photorec_win.exe"
            )
            $found = $prPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($found) {
                Write-Host "  [OK] PhotoRec found: $found" -ForegroundColor Green
                Write-Host "  [*]  Launching PhotoRec..." -ForegroundColor Cyan
                Start-Process $found
            } else {
                Write-Host "  [!] PhotoRec not found. (Bundled with TestDisk)" -ForegroundColor Yellow
                Write-Host ""
                $dlChoice = Read-Host "  Download TestDisk+PhotoRec portable ZIP now? (Y/N)"
                if ($dlChoice -match "^[Yy]") {
                    $baseDir = "C:\HDD-MasterTool-Tools"
                    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
                    $zipFile = "$baseDir\testdisk.zip"
                    Write-Host "  [*] Downloading TestDisk+PhotoRec portable..." -ForegroundColor Cyan
                    try {
                        $ProgressPreference = 'SilentlyContinue'
                        Invoke-WebRequest -Uri "https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip" `
                            -OutFile $zipFile -UseBasicParsing
                        Write-Host "  [*] Extracting..." -ForegroundColor Cyan
                        Expand-Archive -Path $zipFile -DestinationPath $baseDir -Force
                        $exeFound = Get-ChildItem -Path $baseDir -Recurse -Filter "photorec_win.exe" |
                            Select-Object -First 1
                        if ($exeFound) {
                            Write-Host "  [OK] PhotoRec ready: $($exeFound.FullName)" -ForegroundColor Green
                            Write-Host "  [*] Launching PhotoRec..." -ForegroundColor Cyan
                            Start-Process $exeFound.FullName
                        } else {
                            Write-Host "  [!] photorec_win.exe not found in archive." -ForegroundColor Red
                        }
                        Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
                    } catch {
                        Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                        Write-Host "  [i] Manual: https://www.cgsecurity.org/wiki/PhotoRec" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "  [i] Skipped. Manual: https://www.cgsecurity.org/wiki/PhotoRec" -ForegroundColor DarkGray
                }
            }
        }
        "9" {
            Write-Header "MINITOOL POWER DATA RECOVERY"
            $mtPaths = @(
                "$env:ProgramFiles\MiniTool Power Data Recovery\PowerDataRecovery.exe",
                "${env:ProgramFiles(x86)}\MiniTool Power Data Recovery\PowerDataRecovery.exe"
            )
            $found = $mtPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($found) {
                Write-Host "  [OK] MiniTool found: $found" -ForegroundColor Green
                Write-Host "  [*]  Launching MiniTool..." -ForegroundColor Cyan
                Start-Process $found
            } else {
                Write-Host "  [!] MiniTool Power Data Recovery is not installed." -ForegroundColor Yellow
                Write-Host ""
                $dlChoice = Read-Host "  Download MiniTool Free installer now? (Y/N)"
                if ($dlChoice -match "^[Yy]") {
                    $toolDir = "C:\HDD-MasterTool-Tools"
                    if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir -Force | Out-Null }
                    $dest = "$toolDir\minitool-pdr-free.exe"
                    Write-Host "  [*] Downloading MiniTool Power Data Recovery Free..." -ForegroundColor Cyan
                    try {
                        $ProgressPreference = 'SilentlyContinue'
                        Invoke-WebRequest -Uri "https://download.minitool.com/pdr_free/minitool-power-data-recovery-free.exe" `
                            -OutFile $dest -UseBasicParsing
                        Write-Host "  [OK] Saved to: $dest" -ForegroundColor Green
                        Write-Host "  [*] Launching MiniTool installer..." -ForegroundColor Cyan
                        Start-Process $dest
                    } catch {
                        Write-Host "  [!] Download failed: $_" -ForegroundColor Red
                        Write-Host "  [i] Manual: https://www.minitool.com/data-recovery-software/free-for-windows.html" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "  [i] Skipped. Manual: https://www.minitool.com/data-recovery-software/free-for-windows.html" -ForegroundColor DarkGray
                }
            }
        }
        "0" { return }
        default {
            Write-Host "  Invalid option." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }

    Pause-Script
}

# ================================================================
#  OPTION 14  -  SMART HISTORY LOGGER
# ================================================================
function Run-SMARTLogger {
    Write-Header "SMART HISTORY LOGGER — Drive Health Trend"

    $logDir  = "C:\HDD-MasterTool-Logs"
    $logFile = "$logDir\SMART-History.csv"
    $stamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        Write-Host "  [*] Log folder created: $logDir" -ForegroundColor Cyan
    }

    if (-not (Test-Path $logFile)) {
        "Timestamp,DiskNum,Model,MediaType,HealthStatus,Temp_C,ReadErrors,WriteErrors,PowerOnHours,Wear_Pct" |
            Out-File -FilePath $logFile -Encoding UTF8
        Write-Host "  [*] New log file created: $logFile" -ForegroundColor Cyan
    }

    $prevData = @{}
    try {
        $prevEntries = Import-Csv $logFile -ErrorAction SilentlyContinue
        foreach ($e in $prevEntries) { $prevData[$e.DiskNum] = $e }
    } catch {}

    Write-Host "  [*] Scanning physical drives and logging SMART data..." -ForegroundColor Cyan
    Write-Host ""

    $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue
    if (-not $disks) {
        Write-Host "  [!] No physical disks detected. Try running as Administrator." -ForegroundColor Red
        Pause-Script; return
    }

    $warnFound = $false

    foreach ($disk in $disks) {
        $dNum   = $disk.DeviceId
        $model  = $disk.FriendlyName
        $media  = $disk.MediaType
        $health = $disk.HealthStatus

        $rel   = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue
        $temp  = if ($rel -and $null -ne $rel.Temperature)      { $rel.Temperature }      else { "N/A" }
        $rErr  = if ($rel -and $null -ne $rel.ReadErrorsTotal)  { $rel.ReadErrorsTotal }  else { 0 }
        $wErr  = if ($rel -and $null -ne $rel.WriteErrorsTotal) { $rel.WriteErrorsTotal } else { 0 }
        $hours = if ($rel -and $null -ne $rel.PowerOnHours)     { $rel.PowerOnHours }     else { "N/A" }
        $wear  = if ($rel -and $null -ne $rel.Wear)             { $rel.Wear }             else { "N/A" }

        "$stamp,$dNum,`"$model`",$media,$health,$temp,$rErr,$wErr,$hours,$wear" |
            Out-File -FilePath $logFile -Encoding UTF8 -Append

        Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  Disk $dNum  —  $model  [$media]" -ForegroundColor White

        $hClr = switch ($health) {
            "Healthy"   { "Green"  }
            "Warning"   { "Yellow" }
            "Unhealthy" { "Red"    }
            default     { "Gray"   }
        }
        Write-Host "  Health      : $health" -ForegroundColor $hClr

        if ($temp -ne "N/A") {
            $tClr = if ([int]$temp -ge 55) { "Red" } elseif ([int]$temp -ge 45) { "Yellow" } else { "Green" }
            Write-Host "  Temperature : ${temp}°C" -ForegroundColor $tClr
            if ([int]$temp -ge 55) {
                Write-Host "  [!!] CRITICAL TEMPERATURE — drive may be overheating!" -ForegroundColor Red
                $warnFound = $true
            }
        }

        $errClr = if (($rErr -gt 0) -or ($wErr -gt 0)) { "Yellow" } else { "Green" }
        Write-Host "  Read Errors : $rErr    Write Errors: $wErr" -ForegroundColor $errClr
        if ($hours -ne "N/A") { Write-Host "  Power-On    : $hours hours" -ForegroundColor DarkGray }
        if ($wear  -ne "N/A") {
            $wClr = if ([int]$wear -ge 80) { "Red" } elseif ([int]$wear -ge 60) { "Yellow" } else { "Green" }
            Write-Host "  SSD Wear    : ${wear}%" -ForegroundColor $wClr
            if ([int]$wear -ge 80) {
                Write-Host "  [!!] SSD WEAR CRITICAL — replace soon!" -ForegroundColor Red
                $warnFound = $true
            }
        }

        if ($prevData.ContainsKey($dNum)) {
            $prev = $prevData[$dNum]
            Write-Host ""
            Write-Host "  ── Trend vs last scan ($($prev.Timestamp)) ──" -ForegroundColor DarkGray
            $changed = $false
            if ($prev.HealthStatus -ne $health) {
                Write-Host "  [!!] HEALTH CHANGED : $($prev.HealthStatus) -> $health" -ForegroundColor Red
                $warnFound = $true; $changed = $true
            }
            if ($prev.ReadErrors -match "^\d+$" -and [long]$rErr -gt [long]$prev.ReadErrors) {
                Write-Host "  [!!] READ ERRORS UP : $($prev.ReadErrors) -> $rErr" -ForegroundColor Red
                $warnFound = $true; $changed = $true
            }
            if ($prev.WriteErrors -match "^\d+$" -and [long]$wErr -gt [long]$prev.WriteErrors) {
                Write-Host "  [!!] WRITE ERRORS UP: $($prev.WriteErrors) -> $wErr" -ForegroundColor Red
                $warnFound = $true; $changed = $true
            }
            if (-not $changed) {
                Write-Host "  [OK] No degradation detected since last scan." -ForegroundColor Green
            }
        } else {
            Write-Host "  [i]  First scan for this drive — baseline recorded." -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    if ($warnFound) {
        Write-Host "  [!!] ONE OR MORE DRIVES SHOW DEGRADATION!" -ForegroundColor Red
        Write-Host "  [!!] -> Use Option 16 (Emergency Triage) immediately." -ForegroundColor Red
        Write-Host "  [!!] -> IMAGE the drive NOW before any diagnostics." -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] All drives healthy — no critical changes detected." -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "  [*] Log saved: $logFile" -ForegroundColor Cyan
    Write-Host "  [i] Run regularly (daily/weekly) to catch trends early." -ForegroundColor DarkGray

    Pause-Script
}

# ================================================================
#  OPTION 15  -  BACKUP STATUS AUDIT
# ================================================================
function Show-BackupAudit {
    Write-Header "BACKUP STATUS AUDIT — 3-2-1 Check"

    Write-Host "  [*] Checking Windows Backup and Shadow Copy status..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ── Windows Backup (wbadmin) ─────────────────────────────" -ForegroundColor Cyan
    $wbRaw = & wbadmin get versions 2>&1
    $wbStr = $wbRaw -join "`n"

    if ($wbStr -match "no backup" -or $wbStr -match "No versions" -or $LASTEXITCODE -eq 5) {
        Write-Host "  [!] No Windows Backup versions found." -ForegroundColor Red
        Write-Host "      Go to Control Panel -> Backup and Restore to configure." -ForegroundColor Yellow
    } else {
        $timeLine = ($wbRaw | Select-String "Backup time:") | Select-Object -Last 1
        if ($timeLine) {
            $lastBackupStr = ($timeLine.Line -replace "(?i)backup time:\s*","").Trim()
            Write-Host "  Last backup : $lastBackupStr" -ForegroundColor White
            try {
                $lastDate = [datetime]::Parse($lastBackupStr)
                $age = (Get-Date) - $lastDate
                $days = [math]::Round($age.TotalDays, 1)
                if ($days -gt 7) {
                    Write-Host "  Age         : $days days — [!!] CRITICAL: over 7 days old!" -ForegroundColor Red
                } elseif ($days -gt 1) {
                    Write-Host "  Age         : $days days — [!] WARNING: over 24 hours old." -ForegroundColor Yellow
                } else {
                    Write-Host "  Age         : $days days — [OK] Current." -ForegroundColor Green
                }
            } catch {
                Write-Host "  [i] Could not parse backup date automatically." -ForegroundColor Gray
            }
        } else {
            Write-Host "  [i] Backup data found. Run 'wbadmin get versions' for details." -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "  ── Volume Shadow Copies (VSS) ───────────────────────────" -ForegroundColor Cyan
    $vssRaw = & vssadmin list shadows 2>&1
    $shadowCount = ($vssRaw | Select-String "Shadow Copy Volume:").Count
    if ($shadowCount -eq 0) {
        Write-Host "  [!] No shadow copies. Enable VSS on critical volumes." -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] $shadowCount shadow copy volume(s) found." -ForegroundColor Green
        $latestLine = ($vssRaw | Select-String "Creation time:") | Select-Object -Last 1
        if ($latestLine) { Write-Host "  Latest: $($latestLine.Line.Trim())" -ForegroundColor White }
    }

    Write-Host ""
    Write-Host "  ── Recent Disk Errors (last 7 days) ────────────────────" -ForegroundColor Cyan
    try {
        $since  = (Get-Date).AddDays(-7)
        $events = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$since; Level=1,2} `
                    -ErrorAction SilentlyContinue |
                  Where-Object { $_.ProviderName -match "disk|atapi|nvme|storhport|iaStorA" } |
                  Select-Object -First 5
        if ($events) {
            Write-Host "  [!] Disk-related errors found in event log:" -ForegroundColor Yellow
            $events | ForEach-Object {
                Write-Host "  $($_.TimeCreated.ToString('yyyy-MM-dd HH:mm'))  [$($_.ProviderName)]  ID:$($_.Id)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [OK] No disk-related errors in the last 7 days." -ForegroundColor Green
        }
    } catch {
        Write-Host "  [i] Could not query event log." -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  ── 3-2-1 Backup Rule — Self-Audit ──────────────────────" -ForegroundColor Cyan
    Write-Host "  [ ] 3 copies  — original + local backup + offsite" -ForegroundColor White
    Write-Host "  [ ] 2 media   — e.g. internal HDD + USB/NAS + cloud" -ForegroundColor White
    Write-Host "  [ ] 1 offsite — cloud (OneDrive/Azure) or remote site" -ForegroundColor White
    Write-Host "  [ ] Restore tested in last 30 days?" -ForegroundColor White
    Write-Host ""
    Write-Host "  ── Quick Actions ────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "   A.  Open Backup and Restore (Control Panel)" -ForegroundColor White
    Write-Host "   B.  Open System Protection (Shadow Copy settings)" -ForegroundColor White
    Write-Host "   C.  Create backup now (goes to Option 11 — Disk Imaging)" -ForegroundColor White
    Write-Host "   0.  Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
    $bOpt = (Read-Host "  Choose A / B / C / 0").Trim().ToUpper()
    switch ($bOpt) {
        "A" { Start-Process "control" -ArgumentList "/name Microsoft.BackupAndRestore" }
        "B" { Start-Process "SystemPropertiesProtection.exe" }
        "C" { Run-DiskImaging; return }
        "0" { return }
        default { Write-Host "  Invalid option." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }

    Pause-Script
}

# ================================================================
#  OPTION 16  -  EMERGENCY DRIVE TRIAGE
# ================================================================
function Show-EmergencyTriage {
    Write-Header "EMERGENCY DRIVE TRIAGE — Failing Drive Protocol"

    Write-Host "  [!!!] STOP — READ BEFORE TOUCHING THE DRIVE" -ForegroundColor Red
    Write-Host ""
    Write-Host "  If a drive is clicking, showing SMART errors, or acting" -ForegroundColor Yellow
    Write-Host "  erratically — follow these steps IN ORDER. Do NOT skip." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ╔═════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  STEP 1 — STOP all writes to the failing drive          ║" -ForegroundColor Red
    Write-Host "  ╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║  STEP 2 — IDENTIFY the drive serial number              ║" -ForegroundColor Yellow
    Write-Host "  ╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║  STEP 3 — IMAGE the drive NOW (before any repair)       ║" -ForegroundColor Cyan
    Write-Host "  ╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║  STEP 4 — RECOVER data from the image, not the drive    ║" -ForegroundColor Green
    Write-Host "  ╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "  ║  STEP 5 — REPLACE the drive. Never repair a failing one ║" -ForegroundColor DarkGray
    Write-Host "  ╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  !! NEVER run chkdsk /f, format, or defrag on a failing drive !!" -ForegroundColor Red
    Write-Host "  !! Every write attempt reduces recoverable data !!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  ── Sub-options ──────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "   1.  Check SMART status of all drives NOW" -ForegroundColor White
    Write-Host "   2.  Start Emergency Image Backup (wbadmin)" -ForegroundColor White
    Write-Host "   3.  Show drive serial numbers and details" -ForegroundColor White
    Write-Host "   4.  View disk error events — last 24 hours" -ForegroundColor White
    Write-Host "   5.  Download GNU ddrescue (best tool for failing drives)" -ForegroundColor Yellow
    Write-Host "   0.  Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
    $eSub = Read-Host "  Enter option (0-5)"

    switch ($eSub) {
        "1" { Show-HealthCheck }
        "2" { Run-DiskImaging }
        "3" {
            Write-Header "DRIVE IDENTIFICATION"
            Write-Host "  ── Physical Drives ─────────────────────────────────────" -ForegroundColor Cyan
            Get-PhysicalDisk -ErrorAction SilentlyContinue |
                Format-Table DeviceId, FriendlyName, SerialNumber, MediaType,
                             @{N="Size_GB";E={[math]::Round($_.Size/1GB,1)}},
                             HealthStatus -AutoSize
            Write-Host ""
            Write-Host "  ── Physical Disk Detail ────────────────────────────────" -ForegroundColor Cyan
            Get-PhysicalDisk -ErrorAction SilentlyContinue |
                Format-List FriendlyName, SerialNumber, HealthStatus,
                    @{N="Size_GB";E={[math]::Round($_.Size/1GB,1)}},
                    BusType, MediaType |
                Out-String | Write-Host
        }
        "4" {
            Write-Header "DISK ERRORS — Last 24 Hours"
            Write-Host "  Querying System Event Log for disk errors..." -ForegroundColor Cyan
            Write-Host ""
            try {
                $since = (Get-Date).AddHours(-24)
                $ev = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$since; Level=1,2,3} `
                        -ErrorAction SilentlyContinue |
                      Where-Object { $_.ProviderName -match "disk|atapi|nvme|storhport|iaStorA|volmgr" }
                if ($ev) {
                    Write-Host "  [!] $($ev.Count) disk-related event(s) found:" -ForegroundColor Yellow
                    $ev | Select-Object TimeCreated, Id, ProviderName |
                        Format-Table -AutoSize
                } else {
                    Write-Host "  [OK] No disk errors in the last 24 hours." -ForegroundColor Green
                }
            } catch {
                Write-Host "  [i] Could not query event log. Run as Administrator." -ForegroundColor Gray
            }
        }
        "5" {
            Write-Host ""
            Write-Host "  GNU ddrescue — Gold standard for imaging failing drives" -ForegroundColor Cyan
            Write-Host "  Reads in multiple passes: good sectors first, then retries bad sectors." -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Official site   : https://www.gnu.org/software/ddrescue/" -ForegroundColor White
            Write-Host "  Windows port    : https://sourceforge.net/projects/ddrescue-for-windows/" -ForegroundColor White
            Write-Host "  Also consider   : HDDSuperClone, GetDataBack, R-Studio" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  [*] Opening ddrescue download in browser..." -ForegroundColor Cyan
            Start-Process "https://sourceforge.net/projects/ddrescue-for-windows/"
        }
        "0" { return }
        default { Write-Host "  Invalid option." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }

    Pause-Script
}

# ================================================================
#  MAIN MENU
# ================================================================
do {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         HDD MASTER TOOL  —  JahirCyberDesk             ║" -ForegroundColor Cyan
    Write-Host "  ║    Hard Drive Management, Robocopy & Safety Guide      ║" -ForegroundColor Cyan
    Write-Host "  ╠══════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "  ║                                                         ║" -ForegroundColor Cyan
    Write-Host "  ║   1.  Drive Overview        (Space & Disk Info)        ║" -ForegroundColor White
    Write-Host "  ║   2.  Health Check          (SMART Status)             ║" -ForegroundColor White
    Write-Host "  ║   3.  Disk Cleanup          (Free Up Space)            ║" -ForegroundColor White
    Write-Host "  ║   4.  Optimize / Defrag     (SSD TRIM / HDD Defrag)    ║" -ForegroundColor White
    Write-Host "  ║   5.  Disk Scan             (CHKDSK)                   ║" -ForegroundColor White
    Write-Host "  ║   6.  Find Largest Files    (Top space consumers)      ║" -ForegroundColor White
    Write-Host "  ║   7.  Folder Size Analyzer  (Which folder uses most)   ║" -ForegroundColor White
    Write-Host "  ║   8.  Drive Speed Test      (Read & Write MB/s)        ║" -ForegroundColor White
    Write-Host "  ║                                                         ║" -ForegroundColor Cyan
    Write-Host "  ║   9.  ROBOCOPY              (Copy / Mirror / Backup)   ║" -ForegroundColor Green
    Write-Host "  ║  10.  Secure Erase          (Wipe Drive / Free Space)  ║" -ForegroundColor Red
    Write-Host "  ║  11.  Disk Imaging          (Windows System Backup)    ║" -ForegroundColor Yellow
    Write-Host "  ║  12.  Safety Checklist      (Rules & Tool Reference)   ║" -ForegroundColor Cyan
    Write-Host "  ║  13.  Data Recovery         (SFC / DISM / bootrec / Tools)║" -ForegroundColor Magenta
    Write-Host "  ║  14.  SMART History Log     (Trend tracking to CSV)    ║" -ForegroundColor Yellow
    Write-Host "  ║  15.  Backup Status Audit   (3-2-1 Check / VSS)        ║" -ForegroundColor Yellow
    Write-Host "  ║  16.  Emergency Triage      (Failing Drive Protocol)   ║" -ForegroundColor Red
    Write-Host "  ║                                                         ║" -ForegroundColor Cyan
    Write-Host "  ║   0.  Exit                                             ║" -ForegroundColor DarkGray
    Write-Host "  ║                                                         ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Running as: $env:USERNAME | Computer: $env:COMPUTERNAME" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "  Enter your choice (0-16)"

    switch ($choice) {
        "1"  { Show-DriveOverview }
        "2"  { Show-HealthCheck }
        "3"  { Run-DiskCleanup }
        "4"  { Optimize-Drives }
        "5"  { Run-ChkDsk }
        "6"  { Find-LargestFiles }
        "7"  { Show-FolderSizes }
        "8"  { Run-SpeedTest }
        "9"  { Run-RoboCopy }
        "10" { Run-SecureErase }
        "11" { Run-DiskImaging }
        "12" { Show-SafetyChecklist }
        "13" { Run-DataRecovery }
        "14" { Run-SMARTLogger }
        "15" { Show-BackupAudit }
        "16" { Show-EmergencyTriage }
        "0"  {
            Clear-Host
            Write-Host ""
            Write-Host "  Goodbye! — JahirCyberDesk" -ForegroundColor Cyan
            Write-Host "  YouTube: @jahircyberdesk" -ForegroundColor DarkGray
            Write-Host ""
        }
        default {
            Write-Host "  Invalid choice. Please enter 0-16." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }

} while ($choice -ne "0")
