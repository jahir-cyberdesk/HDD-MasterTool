@echo off
setlocal EnableDelayedExpansion
title HDD Master Tool — JahirCyberDesk

:: ================================================================
::  HDD-MasterTool.bat
::  Hard Drive Management & Robocopy Tool
::  By JahirCyberDesk ^| jahircyberdesk@gmail.com
::  YouTube: @jahircyberdesk
:: ================================================================

:: ── Admin Check ─────────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] This script requires Administrator privileges.
    echo  [!] Right-click the .bat file and choose "Run as Administrator"
    echo.
    pause
    exit /b
)

:: ── Color Setup ─────────────────────────────────────────────────
color 0B

:MAIN_MENU
cls
echo.
echo  =============================================================
echo   HDD MASTER TOOL  --  JahirCyberDesk
echo   Hard Drive Management, Robocopy ^& Safety Guide
echo  =============================================================
echo.
echo   1.  Drive Overview        (Space ^& Disk Info)
echo   2.  Health Check          (SMART Status)
echo   3.  Disk Cleanup          (Free Up Space)
echo   4.  Defrag / Optimize     (Defrag HDD or TRIM SSD)
echo   5.  Disk Scan             (CHKDSK)
echo   6.  Find Largest Files    (Top space consumers)
echo   7.  Folder Size Analyzer  (Which folder uses most)
echo   8.  Drive Speed Test      (Read ^& Write speed)
echo.
echo   9.  ROBOCOPY              (Copy / Mirror / Backup / Move)
echo  10.  Secure Erase          (Wipe Drive or Free Space)
echo  11.  Disk Imaging          (Windows System Backup)
echo  12.  Safety Checklist      (Rules ^& Tool Reference)
echo  13.  Data Recovery         (SFC / DISM / bootrec / Tools)
echo  14.  SMART History Log     (Trend tracking to CSV)
echo  15.  Backup Status Audit   (3-2-1 Check / VSS)
echo  16.  Emergency Triage      (Failing Drive Protocol)
echo.
echo   0.  Exit
echo.
echo  =============================================================
echo   User: %USERNAME%  ^|  PC: %COMPUTERNAME%
echo  =============================================================
echo.
set /p CHOICE=  Enter your choice (0-16):

if "%CHOICE%"=="1"  goto DRIVE_OVERVIEW
if "%CHOICE%"=="2"  goto HEALTH_CHECK
if "%CHOICE%"=="3"  goto DISK_CLEANUP
if "%CHOICE%"=="4"  goto DEFRAG
if "%CHOICE%"=="5"  goto CHKDSK
if "%CHOICE%"=="6"  goto LARGEST_FILES
if "%CHOICE%"=="7"  goto FOLDER_SIZES
if "%CHOICE%"=="8"  goto SPEED_TEST
if "%CHOICE%"=="9"  goto ROBOCOPY
if "%CHOICE%"=="10" goto SECURE_ERASE
if "%CHOICE%"=="11" goto DISK_IMAGING
if "%CHOICE%"=="12" goto SAFETY_CHECK
if "%CHOICE%"=="13" goto DATA_RECOVERY
if "%CHOICE%"=="14" goto SMART_LOGGER
if "%CHOICE%"=="15" goto BACKUP_AUDIT
if "%CHOICE%"=="16" goto EMERGENCY_TRIAGE
if "%CHOICE%"=="0"  goto EXIT_TOOL
echo  Invalid choice. Try again.
timeout /t 1 /nobreak >nul
goto MAIN_MENU


:: ================================================================
::  1. DRIVE OVERVIEW
:: ================================================================
:DRIVE_OVERVIEW
cls
echo.
echo  =============================================================
echo   DRIVE OVERVIEW -- Disk Space ^& Information
echo  =============================================================
echo.
echo  Gathering drive information...
echo.
:: Header
echo  Drive    Label           Total          Free           Used%%     FileSystem
echo  -----------------------------------------------------------------------
echo.

powershell -nologo -noprofile -command "Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed'} | Sort-Object DriveLetter | ForEach-Object { $t=$_.Size; $f=$_.SizeRemaining; $u=$t-$f; $p=if($t -gt 0){[math]::Round($u/$t*100)}else{0}; $l=if($_.FileSystemLabel){$_.FileSystemLabel}else{'No Label'}; Write-Host ('  ' + $_.DriveLetter + ':   [' + $l + ']   [' + $_.FileSystem + ']') -F White; Write-Host ('  Total: ' + [math]::Round($t/1GB,1) + ' GB   Used: ' + [math]::Round($u/1GB,1) + ' GB (' + $p + '%%)   Free: ' + [math]::Round($f/1GB,1) + ' GB') -F Cyan; Write-Host '  -----------------------------------------------' -F DarkGray }"

echo.
goto PAUSE_RETURN


:: ================================================================
::  2. HEALTH CHECK (SMART)
:: ================================================================
:HEALTH_CHECK
cls
echo.
echo  =============================================================
echo   HEALTH CHECK -- SMART Status ^& Disk Information
echo  =============================================================
echo.
echo  Reading SMART status from all physical drives...
echo.

powershell -nologo -noprofile -command "Get-PhysicalDisk -EA SilentlyContinue | Format-List FriendlyName,SerialNumber,HealthStatus,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},BusType,MediaType"

echo.
echo  -----------------------------------------------
echo  NOTE: Status=OK means the drive is healthy.
echo  Any other status = WARNING. Back up immediately!
echo  -----------------------------------------------
echo.

:: Show simplified summary
echo  QUICK SUMMARY:
echo.
powershell -nologo -noprofile -command "Get-PhysicalDisk -EA SilentlyContinue | ForEach-Object { Write-Host ('  Disk: ' + $_.FriendlyName) -F White; $s=$_.HealthStatus; if($s -eq 'Healthy'){Write-Host '  SMART: OK -- Healthy' -F Green}else{Write-Host ('  SMART: WARNING -- ' + $s) -F Red}; Write-Host '  -----------------------------------------------' -F DarkGray }"

echo.
goto PAUSE_RETURN


:: ================================================================
::  3. DISK CLEANUP
:: ================================================================
:DISK_CLEANUP
cls
echo.
echo  =============================================================
echo   DISK CLEANUP -- Free Up Disk Space
echo  =============================================================
echo.
echo  Will clean:
echo   - Windows Temp folder      (%SystemRoot%\Temp)
echo   - User Temp folder         (%TEMP%)
echo   - Prefetch files           (%SystemRoot%\Prefetch)
echo   - Windows Update cache     (%SystemRoot%\SoftwareDistribution\Download)
echo   - CBS Logs                 (%SystemRoot%\Logs\CBS)
echo   - Recycle Bin              (All drives)
echo.
set /p CONF=  Start cleanup? (Y/N):
if /i not "%CONF%"=="Y" goto MAIN_MENU

echo.
echo  Cleaning in progress...
echo.

:: Windows Temp
echo  [1/6] Cleaning Windows Temp...
if exist "%SystemRoot%\Temp" (
    del /q /f /s "%SystemRoot%\Temp\*" >nul 2>&1
    for /d %%x in ("%SystemRoot%\Temp\*") do rd /s /q "%%x" >nul 2>&1
    echo   Done.
)

:: User Temp
echo  [2/6] Cleaning User Temp (%TEMP%)...
if exist "%TEMP%" (
    del /q /f /s "%TEMP%\*" >nul 2>&1
    for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1
    echo   Done.
)

:: Prefetch
echo  [3/6] Cleaning Prefetch...
if exist "%SystemRoot%\Prefetch" (
    del /q /f /s "%SystemRoot%\Prefetch\*" >nul 2>&1
    echo   Done.
)

:: Windows Update Cache
echo  [4/6] Cleaning Windows Update cache...
if exist "%SystemRoot%\SoftwareDistribution\Download" (
    net stop wuauserv >nul 2>&1
    del /q /f /s "%SystemRoot%\SoftwareDistribution\Download\*" >nul 2>&1
    for /d %%x in ("%SystemRoot%\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1
    net start wuauserv >nul 2>&1
    echo   Done.
)

:: CBS Logs
echo  [5/6] Cleaning CBS Logs...
if exist "%SystemRoot%\Logs\CBS" (
    del /q /f /s "%SystemRoot%\Logs\CBS\*" >nul 2>&1
    echo   Done.
)

:: Recycle Bin
echo  [6/6] Emptying Recycle Bin...
rd /s /q "C:\$Recycle.Bin" >nul 2>&1
rd /s /q "D:\$Recycle.Bin" >nul 2>&1
rd /s /q "E:\$Recycle.Bin" >nul 2>&1
echo   Done.

echo.
echo  =============================================================
echo   Cleanup Complete!
echo  =============================================================
echo.

:: Optional Windows Disk Cleanup
set /p DCMU=  Also run Windows built-in Disk Cleanup utility? (Y/N):
if /i "%DCMU%"=="Y" start cleanmgr.exe

echo.
goto PAUSE_RETURN


:: ================================================================
::  4. DEFRAG / OPTIMIZE
:: ================================================================
:DEFRAG
cls
echo.
echo  =============================================================
echo   DEFRAG / OPTIMIZE -- Defrag HDD or TRIM SSD
echo  =============================================================
echo.
echo  NOTE: defrag.exe requires Administrator rights.
echo  If this tool was NOT launched as Administrator, please close
echo  and right-click the .bat file -- Run as Administrator.
echo.
echo  Available fixed drives on this system:
echo.
powershell -nologo -noprofile -command "Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter } | ForEach-Object { '   ' + $_.DriveLetter + ':   ' + $_.FileSystemLabel + '   ' + [math]::Round($_.SizeRemaining/1GB,1) + ' GB free of ' + [math]::Round($_.Size/1GB,1) + ' GB' }" 2>nul
echo.
echo   (Enter 0 to return to Main Menu)
echo.
set DEFDRV=
set /p DEFDRV=  Enter drive letter to optimize (e.g. C) or type ALL:
if "%DEFDRV%"=="0" goto MAIN_MENU
if "%DEFDRV%"=="" goto DEFRAG

if /i "%DEFDRV%"=="ALL" (
    echo.
    echo  Optimizing all drives... This may take several minutes.
    defrag /C /U /H
) else (
    set DEFDRV=%DEFDRV::=%
    echo.
    echo  Optimizing %DEFDRV%: ... This may take several minutes.
    defrag %DEFDRV%: /U /H
)

echo.
echo  Optimization complete.
echo.
goto PAUSE_RETURN


:: ================================================================
::  5. CHKDSK
:: ================================================================
:CHKDSK
cls
echo.
echo  =============================================================
echo   DISK SCAN -- CHKDSK
echo  =============================================================
echo.
echo  Options:
echo   1.  Quick Read-Only Scan  (no repairs, results shown now)
echo   2.  Full Scan + Fix       (C: will schedule on next reboot)
echo   0.  Back to Main Menu
echo.
set /p CHKOPT=  Choose (0, 1 or 2):
if "%CHKOPT%"=="0" goto MAIN_MENU

echo.
echo   (Enter 0 to return to Main Menu)
set /p CHKDRV=  Enter drive letter to scan (e.g. C):
set CHKDRV=%CHKDRV::=%
if "%CHKDRV%"=="0" goto MAIN_MENU

echo.
echo  ---- CHKDSK Output ----------------------------------------
echo.

if "%CHKOPT%"=="1" (
    chkdsk %CHKDRV%:
) else if "%CHKOPT%"=="2" (
    if /i "%CHKDRV%"=="C" (
        echo  C: is the active system drive.
        echo  CHKDSK will run automatically on next restart.
        echo.
        set /p SCHED=  Schedule CHKDSK for next reboot? (Y/N):
        if /i "!SCHED!"=="Y" (
            echo Y | chkdsk C: /f /r
            echo.
            echo  CHKDSK scheduled. Restart your PC to begin the scan.
        )
    ) else (
        chkdsk %CHKDRV%: /f /r /x
    )
) else (
    echo  Invalid choice.
)

echo.
goto PAUSE_RETURN


:: ================================================================
::  6. FIND LARGEST FILES
:: ================================================================
:LARGEST_FILES
cls
echo.
echo  =============================================================
echo   FIND LARGEST FILES -- Top Space Consumers
echo  =============================================================
echo.
echo   (Enter 0 to return to Main Menu)
set /p LDRV=  Enter drive letter to scan (e.g. C):
set LDRV=%LDRV::=%
if "%LDRV%"=="0" goto MAIN_MENU

set /p LTOP=  How many top files to show? (default 20):
if "%LTOP%"=="" set LTOP=20

echo.
echo  Scanning %LDRV%:\ for the %LTOP% largest files...
echo  (This may take 1-3 minutes on large drives. Please wait...)
echo.

powershell -nologo -noprofile -command ^
"$files = Get-ChildItem -Path '%LDRV%:\' -Recurse -File -Force -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First %LTOP%; Write-Host ('  {0,-12} {1}' -f 'SIZE','FILE PATH') -ForegroundColor Yellow; Write-Host ('  ' + '-'*68) -ForegroundColor DarkGray; foreach ($f in $files) { $sz = if ($f.Length -ge 1GB) { '{0:N1} GB ' -f ($f.Length/1GB) } elseif ($f.Length -ge 1MB) { '{0:N1} MB ' -f ($f.Length/1MB) } else { '{0:N0} KB ' -f ($f.Length/1KB) }; $p = $f.FullName; if ($p.Length -gt 60) { $p = '...'+$p.Substring($p.Length-57) }; Write-Host ('  {0,-12} {1}' -f $sz,$p) }"

echo.
goto PAUSE_RETURN


:: ================================================================
::  7. FOLDER SIZE ANALYZER
:: ================================================================
:FOLDER_SIZES
cls
echo.
echo  =============================================================
echo   FOLDER SIZE ANALYZER
echo  =============================================================
echo.
echo  [1] TreeSize Free   (Visual tree -- recommended)
echo  [2] WinDirStat      (Colour disk map -- open source)
echo  [3] PowerShell Quick Scan (text output)
echo  [0] Back to Main Menu
echo.
set /p FSC=  Enter your choice (0-3):
if "%FSC%"=="1" goto FS_TREESIZE
if "%FSC%"=="2" goto FS_WINDIRSTAT
if "%FSC%"=="3" goto FS_BUILTIN
if "%FSC%"=="0" goto MAIN_MENU
goto FOLDER_SIZES


:FS_TREESIZE
cls
echo.
echo  =============================================================
echo   TREESIZE FREE -- Folder Size Visualizer
echo  =============================================================
echo.
if exist "%ProgramFiles%\JAM Software\TreeSize Free\TreeSizeFree.exe" (
    echo  [OK] TreeSize Free found. Launching...
    start "" "%ProgramFiles%\JAM Software\TreeSize Free\TreeSizeFree.exe"
    goto FOLDER_SIZES
)
if exist "%ProgramFiles(x86)%\JAM Software\TreeSize Free\TreeSizeFree.exe" (
    echo  [OK] TreeSize Free found. Launching...
    start "" "%ProgramFiles(x86)%\JAM Software\TreeSize Free\TreeSizeFree.exe"
    goto FOLDER_SIZES
)
if exist "C:\HDD-MasterTool-Tools\TreeSizeFree\TreeSizeFree.exe" (
    echo  [OK] TreeSize Free found. Launching...
    start "" "C:\HDD-MasterTool-Tools\TreeSizeFree\TreeSizeFree.exe"
    goto FOLDER_SIZES
)
echo  [!] TreeSize Free is not installed.
echo.
set /p TS_DL=  Download TreeSize Free portable now? (Y/N):
if /i "%TS_DL%"=="Y" (
    echo  [*] Downloading and extracting TreeSize Free portable...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; $baseDir='C:\HDD-MasterTool-Tools'; $destDir=\"$baseDir\TreeSizeFree\"; $zip=\"$baseDir\TreeSizeFree-Portable.zip\"; try { Invoke-WebRequest -Uri 'https://downloads.jam-software.de/treesize_free/TreeSizeFree-Portable.zip' -OutFile $zip -UseBasicParsing; Write-Host '  [*] Extracting...' -ForegroundColor Cyan; Expand-Archive -Path $zip -DestinationPath $destDir -Force; $exe = Get-ChildItem -Path $destDir -Recurse -Filter 'TreeSizeFree.exe' | Select-Object -First 1; if ($exe) { Write-Host ('  [OK] Ready: ' + $exe.FullName) -ForegroundColor Green; Start-Process $exe.FullName } else { Write-Host '  [!] TreeSizeFree.exe not found in archive.' -ForegroundColor Red }; Remove-Item $zip -Force -ErrorAction SilentlyContinue } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://www.jam-software.com/treesize_free' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://www.jam-software.com/treesize_free
)
echo.
pause
goto FOLDER_SIZES


:FS_WINDIRSTAT
cls
echo.
echo  =============================================================
echo   WINDIRSTAT -- Disk Usage Colour Map
echo  =============================================================
echo.
if exist "%ProgramFiles%\WinDirStat\windirstat.exe" (
    echo  [OK] WinDirStat found. Launching...
    start "" "%ProgramFiles%\WinDirStat\windirstat.exe"
    goto FOLDER_SIZES
)
if exist "%ProgramFiles(x86)%\WinDirStat\windirstat.exe" (
    echo  [OK] WinDirStat found. Launching...
    start "" "%ProgramFiles(x86)%\WinDirStat\windirstat.exe"
    goto FOLDER_SIZES
)
echo  [!] WinDirStat is not installed.
echo.
set /p WDS_DL=  Download WinDirStat installer now? (Y/N):
if /i "%WDS_DL%"=="Y" (
    echo  [*] Downloading WinDirStat...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri 'https://windirstat.net/wds_current_setup.exe' -OutFile 'C:\HDD-MasterTool-Tools\windirstat_setup.exe' -UseBasicParsing; Write-Host '  [OK] Saved to C:\HDD-MasterTool-Tools\windirstat_setup.exe' -ForegroundColor Green; Start-Process 'C:\HDD-MasterTool-Tools\windirstat_setup.exe' } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://windirstat.net' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://windirstat.net
)
echo.
pause
goto FOLDER_SIZES


:FS_BUILTIN
cls
echo.
echo  =============================================================
echo   POWERSHELL FOLDER SCANNER -- Quick Text Output
echo  =============================================================
echo.
set /p FPATH=  Enter folder path (e.g. C:\Users or D:\):
echo.
echo  Calculating folder sizes in: %FPATH%
echo  (Please wait...)
echo.
powershell -nologo -noprofile -command ^
"$path = '%FPATH%'; if (-not (Test-Path $path)) { Write-Host '  [!] Path not found!' -ForegroundColor Red; exit }; $folders = Get-ChildItem -Path $path -Directory -Force -ErrorAction SilentlyContinue; $r = foreach ($f in $folders) { $sz = (Get-ChildItem -Path $f.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; [PSCustomObject]@{Name=$f.Name;Bytes=if($null -eq $sz){0}else{$sz};Disp=if($sz -ge 1GB){'{0:N2} GB'-f($sz/1GB)}elseif($sz -ge 1MB){'{0:N2} MB'-f($sz/1MB)}elseif($sz -ge 1KB){'{0:N2} KB'-f($sz/1KB)}else{'0 B'}} }; $r = $r | Sort-Object Bytes -Descending; Write-Host ('  {0,-42} {1,12}' -f 'FOLDER NAME','SIZE') -ForegroundColor Yellow; Write-Host ('  '+'-'*56) -ForegroundColor DarkGray; foreach ($x in $r) { $n = if($x.Name.Length -gt 40){$x.Name.Substring(0,37)+'...'}else{$x.Name}; Write-Host ('  {0,-42} {1,12}' -f $n,$x.Disp) }"
echo.
pause
goto FOLDER_SIZES


:: ================================================================
::  8. DRIVE SPEED TEST
:: ================================================================
:SPEED_TEST
cls
echo.
echo  =============================================================
echo   DRIVE SPEED TEST -- Read ^& Write Speed
echo  =============================================================
echo.
echo   (Enter 0 to return to Main Menu)
set /p SPDRV=  Enter drive letter to test (e.g. C):
set SPDRV=%SPDRV::=%
if "%SPDRV%"=="0" goto MAIN_MENU

echo.
echo  Running speed test on %SPDRV%: (256 MB test file)...
echo.

powershell -nologo -noprofile -command ^
"$drv = '%SPDRV%'; $testFile = $drv+':\__speedtest__.dat'; $sz = 256; $buf = New-Object byte[](1MB); (New-Object Random).NextBytes($buf); Write-Host '  WRITE TEST...' -ForegroundColor Yellow; $sw=[System.Diagnostics.Stopwatch]::StartNew(); try { $fs=[System.IO.File]::OpenWrite($testFile); for($i=0;$i -lt $sz;$i++){$fs.Write($buf,0,$buf.Length)}; $fs.Flush();$fs.Close();$sw.Stop(); $ws=[math]::Round($sz/$sw.Elapsed.TotalSeconds,1); Write-Host ('  Write Speed : {0} MB/s' -f $ws) -ForegroundColor Green } catch { Write-Host '  Write test failed.' -ForegroundColor Red; if(Test-Path $testFile){Remove-Item $testFile -Force}; exit }; Write-Host ''; Write-Host '  READ TEST...' -ForegroundColor Yellow; $rb=New-Object byte[](1MB); $sw=[System.Diagnostics.Stopwatch]::StartNew(); try { $fs=[System.IO.File]::OpenRead($testFile); while($fs.Read($rb,0,$rb.Length) -gt 0){}; $fs.Close();$sw.Stop(); $rs=[math]::Round($sz/$sw.Elapsed.TotalSeconds,1); Write-Host ('  Read Speed  : {0} MB/s' -f $rs) -ForegroundColor Green } catch { Write-Host '  Read test failed.' -ForegroundColor Red }; if(Test-Path $testFile){Remove-Item $testFile -Force}; Write-Host ''; Write-Host '  =============================================' -ForegroundColor Cyan; Write-Host ('   Write: {0} MB/s  |  Read: {1} MB/s' -f $ws,$rs) -ForegroundColor White; $rating = if($rs -gt 1000){'NVMe SSD - Excellent'}elseif($rs -gt 400){'SATA SSD - Very Good'}elseif($rs -gt 100){'HDD 7200rpm - Average'}else{'Slow - HDD 5400rpm or aging'}; Write-Host ('   Rating: {0}' -f $rating) -ForegroundColor Cyan; Write-Host '  =============================================' -ForegroundColor Cyan"

echo.
goto PAUSE_RETURN


:: ================================================================
::  9. ROBOCOPY
:: ================================================================
:ROBOCOPY
cls
echo.
echo  =============================================================
echo   ROBOCOPY -- Smart File ^& Folder Copy
echo  =============================================================
echo.

:: ── STEP 1: SOURCE ──
echo  -- STEP 1: SOURCE -------------------------------------------
echo  Paste or type the SOURCE path:
echo  (Example: C:\Users\jahir\Documents  or  \\server\share\folder)
echo  (Type 0 and Enter to return to Main Menu)
echo.
set SOURCE=
set /p SOURCE=  SOURCE:
:: Remove surrounding quotes if any
set SOURCE=%SOURCE:"=%
if "%SOURCE%"=="0" goto MAIN_MENU

echo.
:: ── STEP 2: DESTINATION ──
echo  -- STEP 2: DESTINATION --------------------------------------
echo  Paste or type the DESTINATION path:
echo  (Example: D:\Backup\Documents  or  \\nas\backup\docs)
echo.
set DEST=
set /p DEST=  DESTINATION:
set DEST=%DEST:"=%

echo.

:: Validate source
if not exist "%SOURCE%" (
    echo  [ERROR] Source path not found:
    echo          %SOURCE%
    echo.
    goto PAUSE_RETURN
)

:: ── STEP 3: COPY MODE ──
echo  -- STEP 3: COPY MODE ----------------------------------------
echo.
echo   1.  COPY      -- Copy new and updated files only (SAFE)
echo   2.  MIRROR    -- Exact copy - DELETES files not in source
echo   3.  BACKUP    -- Copy all with timestamps preserved
echo   4.  MOVE      -- Copy then DELETE from source
echo   5.  SYNC ONLY -- Copy only newer files, skip unchanged
echo   6.  CUSTOM    -- Enter your own robocopy flags
echo.
set /p RMODE=  Choose mode (1-6):

echo.

:: ── STEP 4: FILE FILTER ──
echo  -- STEP 4: FILE FILTER --------------------------------------
echo  Leave blank = copy ALL files
echo  Examples: *.pdf   *.docx   *.xlsx   *.log
echo.
set RFILTER=
set /p RFILTER=  File filter (or press Enter for all):
if "%RFILTER%"=="" set RFILTER=*.*

echo.

:: ── STEP 5: EXCLUDE ──
echo  -- STEP 5: EXCLUDE (optional, press Enter to skip) ----------
set XDIRS=
set XFILES=
set /p XDIRS=  Exclude folders (e.g. Temp Logs Cache):
set /p XFILES=  Exclude file types (e.g. *.tmp *.bak):

echo.

:: ── STEP 6: LOG ──
echo  -- STEP 6: SAVE LOG -----------------------------------------
set /p SAVELOG=  Save copy log to Desktop? (Y/N):
set LOGARG=
if /i "%SAVELOG%"=="Y" (
    set TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
    set TIMESTAMP=!TIMESTAMP: =0!
    set LOGFILE=%USERPROFILE%\Desktop\Robocopy_Log_!TIMESTAMP!.txt
    set LOGARG=/LOG:"!LOGFILE!" /TEE
)

echo.

:: Build flags based on mode
if "%RMODE%"=="1" set RFLAGS=/E /COPYALL /R:3 /W:5 /NP
if "%RMODE%"=="2" set RFLAGS=/MIR /COPYALL /R:3 /W:5 /NP
if "%RMODE%"=="3" set RFLAGS=/E /COPYALL /DCOPY:T /ZB /R:3 /W:5 /NP
if "%RMODE%"=="4" set RFLAGS=/E /MOVE /COPYALL /R:3 /W:5 /NP
if "%RMODE%"=="5" set RFLAGS=/E /COPYALL /XO /R:3 /W:5 /NP
if "%RMODE%"=="6" (
    echo  Common flags:
    echo  /E=subfolders /MIR=mirror /COPYALL=all attrs /XO=skip older files
    echo  /XF=excl files /XD=excl dirs /R:n=retries /W:n=wait secs
    echo.
    set /p RFLAGS=  Enter flags:
)
if "%RFLAGS%"=="" set RFLAGS=/E /COPYALL /R:3 /W:5 /NP

:: Build exclude args
set XARG=
if not "%XDIRS%"=="" set XARG=%XARG% /XD %XDIRS%
if not "%XFILES%"=="" set XARG=%XARG% /XF %XFILES%

:: WARNING for destructive modes
if "%RMODE%"=="2" (
    echo  ============================================================
    echo  WARNING: MIRROR will DELETE files in destination
    echo  that do NOT exist in source. This CANNOT be undone!
    echo  ============================================================
    echo.
    set /p MCONF=  Type YES to confirm Mirror:
    if /i not "!MCONF!"=="YES" (
        echo  Cancelled.
        goto PAUSE_RETURN
    )
)
if "%RMODE%"=="4" (
    echo  ============================================================
    echo  WARNING: MOVE deletes files from SOURCE after copying!
    echo  ============================================================
    echo.
    set /p MVCONF=  Type YES to confirm Move:
    if /i not "!MVCONF!"=="YES" (
        echo  Cancelled.
        goto PAUSE_RETURN
    )
)

:: Preview command
echo.
echo  -- COMMAND PREVIEW ------------------------------------------
echo.
echo  robocopy "%SOURCE%" "%DEST%" %RFILTER% %RFLAGS%%XARG% %LOGARG%
echo.
echo  -------------------------------------------------------------
echo.
set /p RUNRC=  Run this command? (Y/N):
if /i not "%RUNRC%"=="Y" (
    echo  Cancelled.
    goto PAUSE_RETURN
)

echo.
echo  =============================================================
echo   ROBOCOPY RUNNING -- Do not close this window...
echo  =============================================================
echo.

robocopy "%SOURCE%" "%DEST%" %RFILTER% %RFLAGS%%XARG% %LOGARG%
set RCEXIT=%ERRORLEVEL%

echo.
echo  =============================================================

if %RCEXIT% LEQ 1 (
    echo   RESULT: Copy completed successfully. [Exit: %RCEXIT%]
) else if %RCEXIT% LEQ 3 (
    echo   RESULT: Copy done. Some extras removed. [Exit: %RCEXIT%]
) else if %RCEXIT% LEQ 7 (
    echo   RESULT: Copy done with some mismatches. [Exit: %RCEXIT%]
) else (
    echo   RESULT: ERRORS occurred - some files failed. [Exit: %RCEXIT%]
    echo   Check the log for details.
)

if /i "%SAVELOG%"=="Y" (
    if exist "%LOGFILE%" (
        echo.
        echo   Log saved: %LOGFILE%
    )
)

echo  =============================================================
echo.
goto PAUSE_RETURN


:: ================================================================
::  HELPERS
:: ================================================================
:PAUSE_RETURN
echo.
echo  -------------------------------------------------------------
pause
goto MAIN_MENU


:: ================================================================
::  10. SECURE ERASE / SANITIZE
:: ================================================================
:SECURE_ERASE
cls
echo.
echo  =============================================================
echo   SECURE ERASE -- Wipe Drive or Free Space
echo  =============================================================
echo.
echo  WARNING: Read carefully before proceeding!
echo  -------------------------------------------------------------
echo   - Secure erase is IRREVERSIBLE. All data will be gone.
echo   - Always verify you selected the CORRECT drive letter.
echo   - Never wipe C: (system drive) while Windows is running.
echo   - Verify backups exist BEFORE proceeding.
echo  -------------------------------------------------------------
echo.
echo   Options:
echo   1.  Wipe FREE SPACE only  (cipher /w -- SAFE, no data loss)
echo       Overwrites deleted file remnants. Existing files safe.
echo.
echo   2.  Full 3-Pass Drive Wipe (format /p:3 -- DESTROYS ALL DATA)
echo.
echo   3.  Single-Pass Zero Fill  (format /p:1 -- DESTROYS ALL DATA)
echo.
echo   0.  Back to Main Menu
echo.
set /p SEOPT=  Choose option (0/1/2/3):

if "%SEOPT%"=="0" goto MAIN_MENU
if "%SEOPT%"=="1" goto SE_FREESPACE
if "%SEOPT%"=="2" goto SE_FULLWIPE
if "%SEOPT%"=="3" goto SE_FULLWIPE
echo  Invalid choice.
goto PAUSE_RETURN

:SE_FREESPACE
echo.
set /p SEDRV=  Enter drive letter to wipe free space (e.g. D):
set SEDRV=%SEDRV::=%
echo.
echo  Wiping free space on %SEDRV%: using cipher /w ...
echo  (This may take several minutes)
echo.
cipher /w:%SEDRV%:\
echo.
echo  Free space wipe complete on %SEDRV%:
goto PAUSE_RETURN

:SE_FULLWIPE
echo.
echo  Available drives:
powershell -nologo -noprofile -command "Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed'} | Format-Table @{N='DeviceID';E={$_.DriveLetter+':'}},@{N='VolumeName';E={$_.FileSystemLabel}},@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}} -AutoSize"
echo.
set /p SEDRV2=  Enter drive letter to WIPE (e.g. D):
set SEDRV2=%SEDRV2::=%
if /i "%SEDRV2%"=="C" (
    echo  ERROR: Cannot wipe C: system drive while Windows is running.
    goto PAUSE_RETURN
)
echo.
echo  ============================================================
echo  FINAL WARNING: Drive %SEDRV2%: will be COMPLETELY WIPED!
echo  ALL DATA WILL BE PERMANENTLY DESTROYED!
echo  ============================================================
echo.
set /p SECONF=  Type WIPE to confirm, or anything else to cancel:
if /i not "%SECONF%"=="WIPE" (
    echo  Cancelled. No changes made.
    goto PAUSE_RETURN
)
echo.
if "%SEOPT%"=="2" (
    echo  Running 3-pass wipe on %SEDRV2%: ...
    echo Y | format %SEDRV2%: /fs:NTFS /p:3 /q
) else (
    echo  Running 1-pass wipe on %SEDRV2%: ...
    echo Y | format %SEDRV2%: /fs:NTFS /p:1 /q
)
echo.
echo  Wipe operation complete on %SEDRV2%:
goto PAUSE_RETURN


:: ================================================================
::  11. DISK IMAGING / CLONE
:: ================================================================
:DISK_IMAGING
cls
echo.
echo  =============================================================
echo   DISK IMAGING -- Windows System Backup
echo  =============================================================
echo.
echo   Options:
echo   1.  Create System Image (wbadmin -- full C: backup)
echo   2.  Open Windows Backup GUI
echo   3.  Open Recovery Drive Creator (bootable USB)
echo   4.  View Backup Status
echo   5.  List all disk volumes
echo   0.  Back to Main Menu
echo.
echo   NOTE: For failing/damaged drives, use Macrium Reflect
echo   or Clonezilla for reliable sector-level imaging.
echo.
set /p DIOPT=  Choose option (0-5):

if "%DIOPT%"=="0" goto MAIN_MENU
if "%DIOPT%"=="1" goto DI_SYSIMAGE
if "%DIOPT%"=="2" goto DI_WINGUI
if "%DIOPT%"=="3" goto DI_RECOVERY
if "%DIOPT%"=="4" goto DI_STATUS
if "%DIOPT%"=="5" goto DI_VOLUMES
echo  Invalid choice.
goto PAUSE_RETURN

:DI_SYSIMAGE
echo.
echo  Available drives for backup target (not C:):
powershell -nologo -noprofile -command "Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.DriveLetter -ne 'C'} | Format-Table @{N='DeviceID';E={$_.DriveLetter+':'}},@{N='VolumeName';E={$_.FileSystemLabel}},@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}} -AutoSize"
echo.
set /p DITGT=  Enter DESTINATION drive letter (e.g. D):
set DITGT=%DITGT::=%
echo.
echo  Source  : C: (System Drive)
echo  Target  : %DITGT%:
echo.
set /p DIGO=  Start system image backup? (Y/N):
if /i not "%DIGO%"=="Y" goto PAUSE_RETURN
echo.
echo  Running wbadmin backup -- this may take 15-60 minutes...
wbadmin start backup -backupTarget:%DITGT%: -include:C: -allCritical -quiet
echo.
echo  Backup job completed. Check output above for result.
goto PAUSE_RETURN

:DI_WINGUI
echo  Opening Windows Backup...
start control /name Microsoft.BackupAndRestore
goto PAUSE_RETURN

:DI_RECOVERY
echo  Opening Recovery Drive Creator...
start recoverydrive.exe
goto PAUSE_RETURN

:DI_STATUS
echo.
echo  -- Backup Status ----------------------------------------
wbadmin get status 2>nul
goto PAUSE_RETURN

:DI_VOLUMES
echo.
echo  -- All Disk Volumes -------------------------------------
powershell -nologo -noprofile -command "Get-PhysicalDisk -EA SilentlyContinue | Format-Table FriendlyName,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},BusType,HealthStatus -AutoSize"
echo.
powershell -nologo -noprofile -command "Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed'} | Format-Table @{N='DeviceID';E={$_.DriveLetter+':'}},@{N='VolumeName';E={$_.FileSystemLabel}},FileSystem,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}} -AutoSize"
goto PAUSE_RETURN


:: ================================================================
::  12. SAFETY CHECKLIST
:: ================================================================
:SAFETY_CHECK
cls
echo.
echo  =============================================================
echo   SAFETY CHECKLIST -- Rules Before Working on Any Drive
echo   (From: HDD Master Toolkit Reference Guide)
echo  =============================================================
echo.
echo  CRITICAL SAFETY RULES:
echo.
echo  [1] IMAGE FIRST. Use ddrescue or Macrium Reflect to back up
echo      a failing drive BEFORE any scan, repair, or chkdsk.
echo.
echo  [2] NEVER run chkdsk /r, fsck, or REMAP on a drive whose
echo      data matters -- they WRITE and can destroy bad-sector data.
echo.
echo  [3] Don't scan repeatedly to see how bad it is. Repeated scans
echo      accelerate failure. Use SMART reads (non-invasive).
echo.
echo  [4] Clicking / beeping / undetected in BIOS = MECHANICAL FAILURE.
echo      STOP. Use a professional data recovery lab.
echo.
echo  [5] Work on COPIES -- all analysis on the image, never original.
echo.
echo  [6] Power down before connecting. Ground yourself (ESD).
echo      NEVER open the drive -- dust kills platters instantly.
echo.
echo  [7] Mount failing drives READ-ONLY. Never install recovery
echo      software onto the drive being recovered.
echo.
echo  [8] Secure erase and remap are IRREVERSIBLE. Verify backups
echo      and double-check drive letters before any destructive action.
echo.
echo  =============================================================
echo   RECOMMENDED WORKFLOW
echo  =============================================================
echo.
echo   Step 1.  SMART read         -- Use Option 2 (Health Check)
echo   Step 2.  If HEALTHY         -- Benchmark / scan / repair
echo   Step 3.  If DEGRADED        -- Image immediately (Option 11)
echo   Step 4.  Recover from image -- Use DMDE / TestDisk / Recuva
echo   Step 5.  Only then consider -- Repair / remap / replace drive
echo.
echo  =============================================================
echo   FREE TOOL REFERENCE
echo  =============================================================
echo.
echo   CrystalDiskInfo   -- SMART health monitor (Windows, free)
echo   Macrium Reflect   -- Disk imaging and cloning (free)
echo   Recuva / DMDE     -- Data recovery (free)
echo   TestDisk          -- Partition and filesystem repair (free)
echo   Victoria HDD      -- Deep surface scan and sector remap
echo   GNU ddrescue      -- Best-in-class failing drive imaging
echo   SeaTools          -- Seagate manufacturer diagnostic
echo   WD Data Lifeguard -- Western Digital diagnostic tool
echo   Clonezilla        -- Disk cloning and imaging (free)
echo.
goto PAUSE_RETURN


:: ================================================================
::  13. DATA RECOVERY TOOLS
:: ================================================================
:DATA_RECOVERY
cls
echo.
echo  =============================================================
echo   DATA RECOVERY TOOLS
echo  =============================================================
echo.
echo  -- BUILT-IN WINDOWS RECOVERY --
echo.
echo   1.  SFC           -- System File Checker (Repair system files)
echo   2.  DISM          -- Repair Windows Image (CheckHealth + RestoreHealth)
echo   3.  CHKDSK        -- Scan and Fix Drive Errors (specify drive)
echo   4.  Fix Boot      -- bootrec (MBR / Boot Sector / BCD)
echo   5.  Shadow Copy   -- List Previous Versions (vssadmin)
echo.
echo  -- THIRD-PARTY RECOVERY TOOLS --
echo.
echo   6.  Recuva        -- Free file recovery (Piriform)
echo   7.  TestDisk      -- Partition and boot repair
echo   8.  PhotoRec      -- Photo and file recovery
echo   9.  MiniTool      -- Free data recovery software
echo.
echo   0.  Back to Main Menu
echo.
echo  =============================================================
echo.
set /p RSUB=  Enter option (0-9):

if "%RSUB%"=="1" goto DR_SFC
if "%RSUB%"=="2" goto DR_DISM
if "%RSUB%"=="3" goto DR_CHKDSK
if "%RSUB%"=="4" goto DR_BOOTREC
if "%RSUB%"=="5" goto DR_SHADOW
if "%RSUB%"=="6" goto DR_RECUVA
if "%RSUB%"=="7" goto DR_TESTDISK
if "%RSUB%"=="8" goto DR_PHOTOREC
if "%RSUB%"=="9" goto DR_MINITOOL
if "%RSUB%"=="0" goto MAIN_MENU
echo  Invalid option.
timeout /t 1 /nobreak >nul
goto DATA_RECOVERY


:DR_SFC
cls
echo.
echo  =============================================================
echo   SFC -- System File Checker
echo  =============================================================
echo.
echo  [*] Scanning and repairing protected system files...
echo  [*] This may take 5-10 minutes. Please wait.
echo.
echo  Command: sfc /scannow
echo.
sfc /scannow
goto PAUSE_RETURN


:DR_DISM
cls
echo.
echo  =============================================================
echo   DISM -- Repair Windows Image
echo  =============================================================
echo.
echo  [*] Step 1: Checking Windows image health...
echo  Command: DISM /Online /Cleanup-Image /CheckHealth
echo.
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo  [*] Step 2: Scanning Windows image...
echo  Command: DISM /Online /Cleanup-Image /ScanHealth
echo.
DISM /Online /Cleanup-Image /ScanHealth
echo.
echo  [*] Step 3: Restoring Windows image health...
echo  Command: DISM /Online /Cleanup-Image /RestoreHealth
echo.
DISM /Online /Cleanup-Image /RestoreHealth
goto PAUSE_RETURN


:DR_CHKDSK
cls
echo.
echo  =============================================================
echo   CHKDSK -- Scan and Fix Drive Errors
echo  =============================================================
echo.
set /p CHKDRV=  Enter drive letter to scan (e.g. C or D):
if "%CHKDRV%"=="" (
    echo  [!] No drive letter entered.
    goto PAUSE_RETURN
)
echo.
echo  [*] Running CHKDSK on drive %CHKDRV%: ...
echo  [*] If drive is in use, it will schedule for next reboot.
echo  Command: chkdsk %CHKDRV%: /f /r /x
echo.
chkdsk %CHKDRV%: /f /r /x
goto PAUSE_RETURN


:DR_BOOTREC
cls
echo.
echo  =============================================================
echo   FIX BOOT RECORD (bootrec)
echo  =============================================================
echo.
echo  [!] WARNING: This modifies the Master Boot Record.
echo  [!] Only use if Windows fails to boot normally.
echo.
echo   A.  Fix MBR only          (bootrec /fixmbr)
echo   B.  Fix Boot Sector only   (bootrec /fixboot)
echo   C.  Rebuild BCD            (bootrec /rebuildbcd)
echo   D.  Run ALL three          (Recommended for boot failure)
echo.
set /p BOPT=  Choose A / B / C / D:

if /i "%BOPT%"=="A" (
    echo  [*] Fixing MBR...
    bootrec /fixmbr
    goto PAUSE_RETURN
)
if /i "%BOPT%"=="B" (
    echo  [*] Fixing Boot Sector...
    bootrec /fixboot
    goto PAUSE_RETURN
)
if /i "%BOPT%"=="C" (
    echo  [*] Rebuilding BCD...
    bootrec /rebuildbcd
    goto PAUSE_RETURN
)
if /i "%BOPT%"=="D" (
    echo.
    echo  [*] Fixing MBR...
    bootrec /fixmbr
    echo.
    echo  [*] Fixing Boot Sector...
    bootrec /fixboot
    echo.
    echo  [*] Rebuilding BCD...
    bootrec /rebuildbcd
    goto PAUSE_RETURN
)
echo  Invalid option.
goto PAUSE_RETURN


:DR_SHADOW
cls
echo.
echo  =============================================================
echo   SHADOW COPY -- Previous Versions
echo  =============================================================
echo.
echo  [*] Listing all Shadow Copies on this system...
echo  Command: vssadmin list shadows
echo.
vssadmin list shadows
echo.
echo  [i] To restore files from Previous Versions:
echo  [i]  1. Right-click any folder in Explorer
echo  [i]  2. Select Properties -^> Previous Versions tab
echo  [i]  3. Choose a restore point and click Restore
goto PAUSE_RETURN


:DR_RECUVA
cls
echo.
echo  =============================================================
echo   RECUVA -- File Recovery Tool
echo  =============================================================
echo.
if exist "%ProgramFiles%\Recuva\Recuva.exe" (
    echo  [OK] Recuva found. Launching...
    start "" "%ProgramFiles%\Recuva\Recuva.exe"
    goto PAUSE_RETURN
)
if exist "%ProgramFiles(x86)%\Recuva\Recuva.exe" (
    echo  [OK] Recuva found. Launching...
    start "" "%ProgramFiles(x86)%\Recuva\Recuva.exe"
    goto PAUSE_RETURN
)
echo  [!] Recuva is not installed.
echo.
set /p DR6_DL=  Download Recuva installer now? (Y/N):
if /i "%DR6_DL%"=="Y" (
    echo  [*] Downloading Recuva...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri 'https://download.ccleaner.com/rcsetup156.exe' -OutFile 'C:\HDD-MasterTool-Tools\rcsetup.exe' -UseBasicParsing; Write-Host '  [OK] Saved to C:\HDD-MasterTool-Tools\rcsetup.exe' -ForegroundColor Green; Start-Process 'C:\HDD-MasterTool-Tools\rcsetup.exe' } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://www.ccleaner.com/recuva/download' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://www.ccleaner.com/recuva/download
)
goto PAUSE_RETURN


:DR_TESTDISK
cls
echo.
echo  =============================================================
echo   TESTDISK -- Partition and Boot Repair
echo  =============================================================
echo.
if exist "%ProgramFiles%\TestDisk\testdisk_win.exe" (
    echo  [OK] TestDisk found. Launching...
    start "" "%ProgramFiles%\TestDisk\testdisk_win.exe"
    goto PAUSE_RETURN
)
if exist "%ProgramFiles(x86)%\TestDisk\testdisk_win.exe" (
    echo  [OK] TestDisk found. Launching...
    start "" "%ProgramFiles(x86)%\TestDisk\testdisk_win.exe"
    goto PAUSE_RETURN
)
if exist "C:\Tools\TestDisk\testdisk_win.exe" (
    echo  [OK] TestDisk found. Launching...
    start "" "C:\Tools\TestDisk\testdisk_win.exe"
    goto PAUSE_RETURN
)
if exist "C:\HDD-MasterTool-Tools\testdisk_win.exe" (
    echo  [OK] TestDisk found. Launching...
    start "" "C:\HDD-MasterTool-Tools\testdisk_win.exe"
    goto PAUSE_RETURN
)
echo  [!] TestDisk is not installed.
echo.
set /p DR7_DL=  Download TestDisk portable ZIP now? (Y/N):
if /i "%DR7_DL%"=="Y" (
    echo  [*] Downloading and extracting TestDisk portable...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; $baseDir='C:\HDD-MasterTool-Tools'; $zip=$baseDir+'\testdisk.zip'; try { Invoke-WebRequest -Uri 'https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip' -OutFile $zip -UseBasicParsing; Write-Host '  [*] Extracting...' -ForegroundColor Cyan; Expand-Archive -Path $zip -DestinationPath $baseDir -Force; $exe = Get-ChildItem -Path $baseDir -Recurse -Filter 'testdisk_win.exe' | Select-Object -First 1; if ($exe) { Write-Host ('  [OK] Ready: ' + $exe.FullName) -ForegroundColor Green; Start-Process $exe.FullName } else { Write-Host '  [!] exe not found in archive.' -ForegroundColor Red }; Remove-Item $zip -Force -ErrorAction SilentlyContinue } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://www.cgsecurity.org/wiki/TestDisk_Download' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://www.cgsecurity.org/wiki/TestDisk_Download
)
goto PAUSE_RETURN


:DR_PHOTOREC
cls
echo.
echo  =============================================================
echo   PHOTOREC -- Photo and File Recovery
echo  =============================================================
echo.
if exist "%ProgramFiles%\TestDisk\photorec_win.exe" (
    echo  [OK] PhotoRec found. Launching...
    start "" "%ProgramFiles%\TestDisk\photorec_win.exe"
    goto PAUSE_RETURN
)
if exist "%ProgramFiles(x86)%\TestDisk\photorec_win.exe" (
    echo  [OK] PhotoRec found. Launching...
    start "" "%ProgramFiles(x86)%\TestDisk\photorec_win.exe"
    goto PAUSE_RETURN
)
if exist "C:\Tools\TestDisk\photorec_win.exe" (
    echo  [OK] PhotoRec found. Launching...
    start "" "C:\Tools\TestDisk\photorec_win.exe"
    goto PAUSE_RETURN
)
if exist "C:\HDD-MasterTool-Tools\photorec_win.exe" (
    echo  [OK] PhotoRec found. Launching...
    start "" "C:\HDD-MasterTool-Tools\photorec_win.exe"
    goto PAUSE_RETURN
)
echo  [!] PhotoRec not found. (Bundled with TestDisk)
echo.
set /p DR8_DL=  Download TestDisk+PhotoRec portable ZIP now? (Y/N):
if /i "%DR8_DL%"=="Y" (
    echo  [*] Downloading and extracting TestDisk+PhotoRec portable...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; $baseDir='C:\HDD-MasterTool-Tools'; $zip=$baseDir+'\testdisk.zip'; try { Invoke-WebRequest -Uri 'https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip' -OutFile $zip -UseBasicParsing; Write-Host '  [*] Extracting...' -ForegroundColor Cyan; Expand-Archive -Path $zip -DestinationPath $baseDir -Force; $exe = Get-ChildItem -Path $baseDir -Recurse -Filter 'photorec_win.exe' | Select-Object -First 1; if ($exe) { Write-Host ('  [OK] Ready: ' + $exe.FullName) -ForegroundColor Green; Start-Process $exe.FullName } else { Write-Host '  [!] photorec_win.exe not found in archive.' -ForegroundColor Red }; Remove-Item $zip -Force -ErrorAction SilentlyContinue } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://www.cgsecurity.org/wiki/PhotoRec' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://www.cgsecurity.org/wiki/PhotoRec
)
goto PAUSE_RETURN


:DR_MINITOOL
cls
echo.
echo  =============================================================
echo   MINITOOL POWER DATA RECOVERY
echo  =============================================================
echo.
if exist "%ProgramFiles%\MiniTool Power Data Recovery\PowerDataRecovery.exe" (
    echo  [OK] MiniTool found. Launching...
    start "" "%ProgramFiles%\MiniTool Power Data Recovery\PowerDataRecovery.exe"
    goto PAUSE_RETURN
)
if exist "%ProgramFiles(x86)%\MiniTool Power Data Recovery\PowerDataRecovery.exe" (
    echo  [OK] MiniTool found. Launching...
    start "" "%ProgramFiles(x86)%\MiniTool Power Data Recovery\PowerDataRecovery.exe"
    goto PAUSE_RETURN
)
echo  [!] MiniTool Power Data Recovery is not installed.
echo.
set /p DR9_DL=  Download MiniTool Free installer now? (Y/N):
if /i "%DR9_DL%"=="Y" (
    echo  [*] Downloading MiniTool Power Data Recovery Free...
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri 'https://download.minitool.com/pdr_free/minitool-power-data-recovery-free.exe' -OutFile 'C:\HDD-MasterTool-Tools\minitool-pdr-free.exe' -UseBasicParsing; Write-Host '  [OK] Saved to C:\HDD-MasterTool-Tools\minitool-pdr-free.exe' -ForegroundColor Green; Start-Process 'C:\HDD-MasterTool-Tools\minitool-pdr-free.exe' } catch { Write-Host ('  [!] Download failed: ' + $_) -ForegroundColor Red; Write-Host '  [i] Manual: https://www.minitool.com/data-recovery-software/free-for-windows.html' -ForegroundColor DarkGray }"
) else (
    echo  [i] Skipped. Manual: https://www.minitool.com/data-recovery-software/free-for-windows.html
)
goto PAUSE_RETURN


:: ================================================================
::  14. SMART HISTORY LOGGER
:: ================================================================
:SMART_LOGGER
cls
echo.
echo  =============================================================
echo   SMART HISTORY LOGGER -- Drive Health Trend
echo  =============================================================
echo.
echo  [*] Logging SMART data for all physical drives...
echo  [*] Results saved to C:\HDD-MasterTool-Logs\SMART-History.csv
echo.
powershell -nologo -noprofile -command "$logDir='C:\HDD-MasterTool-Logs'; $logFile=$logDir+'\SMART-History.csv'; $stamp=Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; if(-not(Test-Path $logDir)){New-Item -ItemType Directory -Path $logDir -Force|Out-Null; Write-Host '  [*] Log folder created.' -F Cyan}; if(-not(Test-Path $logFile)){'Timestamp,DiskNum,Model,MediaType,HealthStatus,Temp_C,ReadErrors,WriteErrors,PowerOnHours,Wear_Pct'|Out-File $logFile -Encoding UTF8}; $prev=@{}; try{foreach($e in (Import-Csv $logFile -EA SilentlyContinue)){$prev[$e.DiskNum]=$e}}catch{}; $warn=$false; $disks=Get-PhysicalDisk -EA SilentlyContinue; if(-not $disks){Write-Host '  [!] No physical disks detected.' -F Red; exit}; foreach($d in $disks){$n=$d.DeviceId; $m=$d.FriendlyName; $mt=$d.MediaType; $h=$d.HealthStatus; $r=Get-StorageReliabilityCounter -PhysicalDisk $d -EA SilentlyContinue; $t=if($r -and $null -ne $r.Temperature){$r.Temperature}else{'N/A'}; $re=if($r -and $null -ne $r.ReadErrorsTotal){$r.ReadErrorsTotal}else{0}; $we=if($r -and $null -ne $r.WriteErrorsTotal){$r.WriteErrorsTotal}else{0}; $hr=if($r -and $null -ne $r.PowerOnHours){$r.PowerOnHours}else{'N/A'}; $wr=if($r -and $null -ne $r.Wear){$r.Wear}else{'N/A'}; `"$stamp,$n,\`"$m\`",$mt,$h,$t,$re,$we,$hr,$wr`"|Out-File $logFile -Encoding UTF8 -Append; Write-Host '  -----------------------------------------------' -F DarkGray; Write-Host `"  Disk $n -- $m [$mt]`" -F White; $hc=switch($h){'Healthy'{'Green'}'Warning'{'Yellow'}'Unhealthy'{'Red'}default{'Gray'}}; Write-Host `"  Health   : $h`" -F $hc; if($t -ne 'N/A'){$tc=if([int]$t -ge 55){'Red'}elseif([int]$t -ge 45){'Yellow'}else{'Green'}; Write-Host `"  Temp     : ${t}C`" -F $tc; if([int]$t -ge 55){Write-Host '  [!!] CRITICAL TEMP!' -F Red; $warn=$true}}; $ec=if(($re -gt 0)-or($we -gt 0)){'Yellow'}else{'Green'}; Write-Host `"  Errors   : Read=$re  Write=$we`" -F $ec; if($hr -ne 'N/A'){Write-Host `"  PowerOn  : $hr hours`" -F DarkGray}; if($wr -ne 'N/A'){$wc=if([int]$wr -ge 80){'Red'}elseif([int]$wr -ge 60){'Yellow'}else{'Green'}; Write-Host `"  SSD Wear : ${wr}%%`" -F $wc; if([int]$wr -ge 80){Write-Host '  [!!] SSD WEAR CRITICAL!' -F Red; $warn=$true}}; if($prev.ContainsKey($n)){$pv=$prev[$n]; Write-Host `"  Trend vs: $($pv.Timestamp)`" -F DarkGray; $ch=$false; if($pv.HealthStatus -ne $h){Write-Host `"  [!!] HEALTH: $($pv.HealthStatus) -> $h`" -F Red; $warn=$true; $ch=$true}; if($pv.ReadErrors -match '^\d+' -and [long]$re -gt [long]$pv.ReadErrors){Write-Host `"  [!!] READ ERRORS UP: $($pv.ReadErrors) -> $re`" -F Red; $warn=$true; $ch=$true}; if(-not $ch){Write-Host '  [OK] No degradation.' -F Green}}else{Write-Host '  [i] First scan -- baseline recorded.' -F DarkGray}; Write-Host ''}; if($warn){Write-Host '  [!!] DEGRADATION DETECTED -- Use Option 16 immediately!' -F Red}else{Write-Host '  [OK] All drives healthy -- no changes.' -F Green}; Write-Host `"  Log: $logFile`" -F Cyan"
goto PAUSE_RETURN


:: ================================================================
::  15. BACKUP STATUS AUDIT
:: ================================================================
:BACKUP_AUDIT
cls
echo.
echo  =============================================================
echo   BACKUP STATUS AUDIT -- 3-2-1 Check
echo  =============================================================
echo.
echo  [*] Checking Windows Backup status...
echo.
echo  -- Windows Backup (wbadmin) --
echo.
wbadmin get versions 2>&1 | findstr /i "backup time"
if %errorlevel% neq 0 (
    echo  [!] No Windows Backup versions found.
    echo      Go to Control Panel -^> Backup and Restore to configure.
) else (
    echo  [i] See above for last backup timestamp.
)
echo.
echo  -- Volume Shadow Copies (VSS) --
echo.
vssadmin list shadows 2>&1 | findstr /i "creation time"
if %errorlevel% neq 0 (
    echo  [!] No shadow copies found.
    echo  [!] Consider enabling VSS on your critical volumes.
) else (
    echo  [OK] Shadow copies exist -- see latest timestamp above.
)
echo.
echo  -- Recent Disk Errors (last 7 days) --
echo.
powershell -nologo -noprofile -command "$since=(Get-Date).AddDays(-7); $ev=Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$since;Level=1,2} -EA SilentlyContinue|Where-Object{$_.ProviderName -match 'disk|atapi|nvme|storhport'}|Select-Object -First 5; if($ev){Write-Host '  [!] Disk errors found in last 7 days:' -F Yellow; $ev|ForEach-Object{Write-Host `"  $($_.TimeCreated.ToString('yyyy-MM-dd HH:mm'))  [$($_.ProviderName)]  ID:$($_.Id)`" -F Yellow}}else{Write-Host '  [OK] No disk errors in the last 7 days.' -F Green}"
echo.
echo  =============================================================
echo   3-2-1 BACKUP RULE -- SELF-AUDIT
echo  =============================================================
echo.
echo   [ ] 3 copies  -- original + local backup + offsite
echo   [ ] 2 media   -- e.g. HDD + USB/NAS + cloud
echo   [ ] 1 offsite -- OneDrive / Azure / remote site
echo   [ ] Restore tested in the last 30 days?
echo.
echo  =============================================================
echo.
echo   A.  Open Backup and Restore (Control Panel)
echo   B.  Open System Protection (Shadow Copy settings)
echo   C.  Create backup now (go to Option 11 -- Disk Imaging)
echo   0.  Back to Main Menu
echo.
set /p BAUD=  Choose A / B / C / 0:

if /i "%BAUD%"=="A" (
    control /name Microsoft.BackupAndRestore
    goto PAUSE_RETURN
)
if /i "%BAUD%"=="B" (
    start SystemPropertiesProtection.exe
    goto PAUSE_RETURN
)
if /i "%BAUD%"=="C" goto DISK_IMAGING
if     "%BAUD%"=="0" goto MAIN_MENU
echo  Invalid option.
goto PAUSE_RETURN


:: ================================================================
::  16. EMERGENCY DRIVE TRIAGE
:: ================================================================
:EMERGENCY_TRIAGE
cls
echo.
echo  =============================================================
echo   EMERGENCY DRIVE TRIAGE -- Failing Drive Protocol
echo  =============================================================
echo.
echo  [!!!] STOP -- READ BEFORE TOUCHING THE DRIVE
echo.
echo  If a drive is clicking, showing SMART errors, or acting
echo  erratically -- follow these steps IN ORDER. Do NOT skip.
echo.
echo  +----------------------------------------------------------+
echo  ^|  STEP 1 -- STOP all writes to the failing drive          ^|
echo  +----------------------------------------------------------+
echo  ^|  STEP 2 -- IDENTIFY the drive serial number              ^|
echo  +----------------------------------------------------------+
echo  ^|  STEP 3 -- IMAGE the drive NOW (before any repair)       ^|
echo  +----------------------------------------------------------+
echo  ^|  STEP 4 -- RECOVER data from the image, not the drive    ^|
echo  +----------------------------------------------------------+
echo  ^|  STEP 5 -- REPLACE the drive. Never repair a failing one ^|
echo  +----------------------------------------------------------+
echo.
echo  !! NEVER run chkdsk /f, format, or defrag on a failing drive !!
echo  !! Every write attempt reduces recoverable data !!
echo.
echo  =============================================================
echo.
echo   1.  Check SMART status of all drives (Option 2)
echo   2.  Start Emergency Image Backup (Option 11)
echo   3.  Show drive serial numbers and details
echo   4.  View disk error events -- last 24 hours
echo   5.  Download GNU ddrescue (best for failing drives)
echo   0.  Back to Main Menu
echo.
set /p ETRI=  Enter option (0-5):

if "%ETRI%"=="1" goto HEALTH_CHECK
if "%ETRI%"=="2" goto DISK_IMAGING
if "%ETRI%"=="3" goto ET_DRIVEINFO
if "%ETRI%"=="4" goto ET_EVENTS
if "%ETRI%"=="5" goto ET_DDRESCUE
if "%ETRI%"=="0" goto MAIN_MENU
echo  Invalid option.
timeout /t 1 /nobreak >nul
goto EMERGENCY_TRIAGE


:ET_DRIVEINFO
cls
echo.
echo  =============================================================
echo   DRIVE IDENTIFICATION
echo  =============================================================
echo.
echo  -- Physical Drives --
echo.
powershell -nologo -noprofile -command "Get-PhysicalDisk -EA SilentlyContinue | Format-List FriendlyName,SerialNumber,HealthStatus,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},BusType,MediaType"
echo.
echo  -- Logical Drives --
echo.
powershell -nologo -noprofile -command "Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed'} | Format-List @{N='DeviceID';E={$_.DriveLetter+':'}},FileSystem,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},@{N='Free_GB';E={[math]::Round($_.SizeRemaining/1GB,1)}},@{N='VolumeName';E={$_.FileSystemLabel}}"
goto PAUSE_RETURN


:ET_EVENTS
cls
echo.
echo  =============================================================
echo   DISK ERRORS -- Last 24 Hours
echo  =============================================================
echo.
echo  [*] Querying Windows Event Log for disk errors...
echo.
powershell -nologo -noprofile -command "$since=(Get-Date).AddHours(-24); $ev=Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$since;Level=1,2,3} -EA SilentlyContinue|Where-Object{$_.ProviderName -match 'disk|atapi|nvme|storhport|volmgr'}; if($ev){Write-Host `"  [!] $($ev.Count) disk event(s) found:`" -F Yellow; $ev|Select-Object TimeCreated,Id,ProviderName|Format-Table -A}else{Write-Host '  [OK] No disk errors in the last 24 hours.' -F Green}"
goto PAUSE_RETURN


:ET_DDRESCUE
cls
echo.
echo  =============================================================
echo   GNU DDRESCUE -- Best Tool for Failing Drives
echo  =============================================================
echo.
echo  ddrescue reads a failing drive in multiple passes:
echo  - First pass  : skips bad sectors, copies all good data
echo  - More passes : retries bad sectors to maximize recovery
echo  - Map file    : allows resuming interrupted sessions
echo.
echo  Official:     https://www.gnu.org/software/ddrescue/
echo  Windows port: https://sourceforge.net/projects/ddrescue-for-windows/
echo  Also try:     HDDSuperClone, GetDataBack, R-Studio
echo.
echo  [*] Opening ddrescue download in default browser...
start "" "https://sourceforge.net/projects/ddrescue-for-windows/"
goto PAUSE_RETURN


:EXIT_TOOL
cls
echo.
echo  Goodbye! -- JahirCyberDesk
echo  YouTube: @jahircyberdesk
echo.
timeout /t 2 /nobreak >nul
exit /b
