@echo off
setlocal EnableDelayedExpansion
title HDD Master Tool - JahirCyberDesk

:: ================================================================
::  HDD-MasterTool.bat
::  Hard Drive Management & Robocopy Tool
::  By JahirCyberDesk ^| jahircyberdesk@gmail.com
::  YouTube: @jahircyberdesk
:: ================================================================

:: -- Admin Check -------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] This script requires Administrator privileges.
    echo  [!] Right-click the .bat file and choose "Run as Administrator"
    echo.
    pause
    exit /b
)

:: -- Color Setup -------------------------------------------------
color 0B
:MAIN_MENU
cls
echo.
echo  =============================================================
echo   HDD MASTER TOOL  --  JahirCyberDesk
echo   Hard Drive Management ^& Safety Guide
echo  =============================================================
echo.
echo   1.  Drive Overview        (Space ^& Disk Info)
echo   2.  Health Check          (SMART Status)
echo   3.  Disk Cleanup          (Free Up Space)
echo   4.  Drive Optimization    (SSD TRIM / HDD Defrag)
echo   5.  Partition Manager     (View partitions + GUI)
echo   6.  File System Check     (CHKDSK)
echo   7.  Disk Usage Analyzer   (Top 10 files ^& folders)
echo   8.  Volume Shadow Copies  (VSS snapshots)
echo.
echo   9.  Disk Cloning ^& Backup (Robocopy / System Image)
echo  10.  Disk Imaging          (Windows System Backup)
echo  11.  Secure Erase          (Wipe Drive / Free Space)
echo  12.  Safety Checklist      (Rules ^& Pre-work Guide)
echo  13.  Disk Benchmarking     (Read ^& Write Speed Test)
echo  14.  Advanced Recovery     (TestDisk / PhotoRec / SFC)
echo  15.  Reports ^& Logs        (Export Drive Report)
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
if "%CHOICE%"=="5"  goto PARTITION_MANAGER
if "%CHOICE%"=="6"  goto CHKDSK
if "%CHOICE%"=="7"  goto DISK_USAGE
if "%CHOICE%"=="8"  goto VOLUME_SHADOW
if "%CHOICE%"=="9"  goto CLONING_BACKUP
if "%CHOICE%"=="10" goto DISK_IMAGING
if "%CHOICE%"=="11" goto SECURE_ERASE
if "%CHOICE%"=="12" goto SAFETY_CHECK
if "%CHOICE%"=="13" goto DISK_BENCH
if "%CHOICE%"=="14" goto ADV_RECOVERY
if "%CHOICE%"=="15" goto REPORTS_LOGS
if "%CHOICE%"=="16" goto EMERGENCY_TRIAGE
if "%CHOICE%"=="0"  goto EXIT_TOOL
echo  Invalid choice. Try again.
timeout /t 1 /nobreak >nul
goto MAIN_MENU

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
::  5. PARTITION MANAGER
:: ================================================================
:PARTITION_MANAGER
cls
echo.
echo  =============================================================
echo   PARTITION MANAGER -- View ^& Manage Partitions
echo  =============================================================
echo.
echo  [*] Listing all disks and partitions...
echo.
powershell -nologo -noprofile -command "Get-Disk -EA SilentlyContinue | Sort-Object Number | ForEach-Object { $d=$_; $hc=switch($d.HealthStatus){'Healthy'{'Green'}'Warning'{'Yellow'}'Unhealthy'{'Red'}default{'Gray'}}; Write-Host ('  Disk {0}: {1}  [{2}]  Bus: {3}  Health: {4}' -f $d.Number,$d.FriendlyName,([math]::Round($d.Size/1GB,1).ToString()+'GB'),$d.BusType,$d.HealthStatus) -F White; $parts=Get-Partition -DiskNumber $d.Number -EA SilentlyContinue; if($parts){Write-Host ('    {0,-6} {1,-10} {2,-14} {3}' -f 'PART#','LETTER','TYPE','SIZE') -F Yellow; foreach($p in $parts){$l=if($p.DriveLetter){''+$p.DriveLetter+':'}else{'(no letter)'}; Write-Host ('    {0,-6} {1,-10} {2,-14} {3}' -f $p.PartitionNumber,$l,$p.Type,[math]::Round($p.Size/1GB,2).ToString()+'GB') -F Gray}}; Write-Host '' }"
echo.
echo  -- Actions ------------------------------------------------
echo   1.  Open Disk Management GUI  (diskmgmt.msc)
echo   0.  Back to Main Menu
echo.
set /p PMOPT=  Choose (0 or 1):
if "%PMOPT%"=="1" (
    echo  Opening Disk Management...
    start diskmgmt.msc
)
echo.
goto PAUSE_RETURN

:: ================================================================
::  6. FILE SYSTEM CHECK (CHKDSK)
:: ================================================================
:CHKDSK
cls
echo.
echo  =============================================================
echo   FILE SYSTEM CHECK -- CHKDSK
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
::  7. DISK USAGE ANALYZER
:: ================================================================
:DISK_USAGE
cls
echo.
echo  =============================================================
echo   DISK USAGE ANALYZER -- Top 10 Files ^& Folders
echo  =============================================================
echo.
echo  (Enter 0 to return to Main Menu)
echo.
set /p DUDRV=  Enter drive letter to scan (e.g. C):
set DUDRV=%DUDRV::=%
if "%DUDRV%"=="0" goto MAIN_MENU

echo.
echo  Scanning %DUDRV%:\  -- this may take 1-3 minutes...
echo.

echo  -- TOP 10 LARGEST FILES ------------------------------------
echo.
powershell -nologo -noprofile -command "$drv='%DUDRV%'; $f=Get-ChildItem -Path ($drv+':\') -Recurse -File -Force -EA SilentlyContinue|Sort-Object Length -Descending|Select-Object -First 10; Write-Host ('  {0,-12} {1}' -f 'SIZE','FILE PATH') -F Yellow; Write-Host ('  '+'-'*68) -F DarkGray; foreach($x in $f){$sz=if($x.Length -ge 1GB){'{0:N1} GB'-f($x.Length/1GB)}elseif($x.Length -ge 1MB){'{0:N1} MB'-f($x.Length/1MB)}else{'{0:N0} KB'-f($x.Length/1KB)}; $p=$x.FullName; if($p.Length -gt 60){$p='...'+$p.Substring($p.Length-57)}; Write-Host ('  {0,-12} {1}' -f $sz,$p) -F White}"

echo.
echo  -- TOP 10 LARGEST FOLDERS (top-level) ---------------------
echo.
powershell -nologo -noprofile -command "$drv='%DUDRV%'; $folders=Get-ChildItem -Path ($drv+':\') -Directory -Force -EA SilentlyContinue; $r=foreach($d in $folders){$sz=(Get-ChildItem -Path $d.FullName -Recurse -File -Force -EA SilentlyContinue|Measure-Object -Property Length -Sum).Sum; [PSCustomObject]@{Name=$d.Name;Bytes=if($null -eq $sz){0}else{[long]$sz};Str=if($null -eq $sz){'0 B'}elseif($sz -ge 1GB){'{0:N2} GB'-f($sz/1GB)}elseif($sz -ge 1MB){'{0:N2} MB'-f($sz/1MB)}else{'{0:N2} KB'-f($sz/1KB)}}}; $top=$r|Sort-Object Bytes -Descending|Select-Object -First 10; Write-Host ('  {0,-14} {1}' -f 'SIZE','FOLDER') -F Yellow; Write-Host ('  '+'-'*52) -F DarkGray; foreach($x in $top){Write-Host ('  {0,-14} {1}' -f $x.Str,$x.Name) -F White}"

echo.
goto PAUSE_RETURN


:: ================================================================
::  8. VOLUME SHADOW COPIES (VSS)
:: ================================================================
:VOLUME_SHADOW
cls
echo.
echo  =============================================================
echo   VOLUME SHADOW COPIES (VSS) -- Snapshot Manager
echo  =============================================================
echo.
echo   1.  List all shadow copies
echo   2.  Create a new shadow copy (specify drive)
echo   3.  Delete a shadow copy (by ID)
echo   0.  Back to Main Menu
echo.
set /p VSSOPT=  Choose (0-3):
if "%VSSOPT%"=="0" goto MAIN_MENU
if "%VSSOPT%"=="1" goto VSS_LIST
if "%VSSOPT%"=="2" goto VSS_CREATE
if "%VSSOPT%"=="3" goto VSS_DELETE
echo  Invalid option.
goto VOLUME_SHADOW

:VSS_LIST
cls
echo.
echo  -- Shadow Copies on this system ------------------------------
echo.
vssadmin list shadows
echo.
goto PAUSE_RETURN

:VSS_CREATE
echo.
echo  (Enter 0 to cancel)
set /p VSSDRV=  Enter drive letter to snapshot (e.g. C):
set VSSDRV=%VSSDRV::=%
if "%VSSDRV%"=="0" goto PAUSE_RETURN
echo.
echo  Creating shadow copy of %VSSDRV%: ...
vssadmin create shadow /for=%VSSDRV%:
echo.
goto PAUSE_RETURN

:VSS_DELETE
cls
echo.
echo  Current shadow copies:
echo.
vssadmin list shadows
echo.
echo  WARNING: Deletion is permanent and cannot be undone.
echo.
set /p VSSID=  Enter Shadow Copy ID (e.g. {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}):
if "%VSSID%"=="" goto PAUSE_RETURN
set /p VSSCONF=  Confirm delete ID %VSSID% ? (Y/N):
if /i not "%VSSCONF%"=="Y" (
    echo  Cancelled.
    goto PAUSE_RETURN
)
vssadmin delete shadows /shadow="%VSSID%" /quiet
echo.
echo  Delete command executed.
goto PAUSE_RETURN

:PAUSE_RETURN
echo.
echo  -------------------------------------------------------------
pause
goto MAIN_MENU
:: ================================================================
::  11. SECURE ERASE
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
::  10. DISK IMAGING
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
::  9. DISK CLONING & BACKUP
:: ================================================================
:CLONING_BACKUP
cls
echo.
echo  =============================================================
echo   DISK CLONING ^& BACKUP
echo  =============================================================
echo.
echo   1.  Robocopy Mirror   -- Mirror a folder to another location
echo       (Smart copy with logging, filters, and mode selection)
echo.
echo   2.  System Image      -- Full Windows System Backup (wbadmin)
echo       (Backs up the entire C: drive to an external drive)
echo.
echo   3.  Backup Wizard     -- Open Windows Backup ^& Restore GUI
echo       (Control Panel backup, schedule, and file history)
echo.
echo   0.  Back to Main Menu
echo.
set /p CLOPT=  Choose (0-3):
if "%CLOPT%"=="1" goto ROBOCOPY
if "%CLOPT%"=="2" goto DISK_IMAGING
if "%CLOPT%"=="3" (
    echo  Opening Windows Backup ^& Restore...
    start control /name Microsoft.BackupAndRestore
    goto PAUSE_RETURN
)
if "%CLOPT%"=="0" goto MAIN_MENU
echo  Invalid option.
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

:: -- STEP 1: SOURCE --
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
:: -- STEP 2: DESTINATION --
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

:: -- STEP 3: COPY MODE --
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

:: -- STEP 4: FILE FILTER --
echo  -- STEP 4: FILE FILTER --------------------------------------
echo  Leave blank = copy ALL files
echo  Examples: *.pdf   *.docx   *.xlsx   *.log
echo.
set RFILTER=
set /p RFILTER=  File filter (or press Enter for all):
if "%RFILTER%"=="" set RFILTER=*.*

echo.

:: -- STEP 5: EXCLUDE --
echo  -- STEP 5: EXCLUDE (optional, press Enter to skip) ----------
set XDIRS=
set XFILES=
set /p XDIRS=  Exclude folders (e.g. Temp Logs Cache):
set /p XFILES=  Exclude file types (e.g. *.tmp *.bak):

echo.

:: -- STEP 6: LOG --
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
echo   Step 3.  If DEGRADED        -- Image immediately (Option 10)
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
::  13. DISK BENCHMARKING
:: ================================================================
:DISK_BENCH
cls
echo.
echo  =============================================================
echo   DISK BENCHMARKING -- Read ^& Write Speed Test
echo  =============================================================
echo.
echo  Measures sequential read ^& write speed using a 512 MB file.
echo  Temp file is deleted automatically after the test.
echo.
echo  Expected ranges:
echo   NVMe SSD   :  1500 - 7000+ MB/s
echo   SATA SSD   :   300 -  550 MB/s
echo   HDD 7200rpm:    80 -  150 MB/s
echo   HDD 5400rpm:    50 -  100 MB/s
echo.
echo  (Enter 0 to return to Main Menu)
echo.
set /p BDRV=  Enter drive letter to benchmark (e.g. C):
set BDRV=%BDRV::=%
if "%BDRV%"=="0" goto MAIN_MENU

echo.
echo  Benchmarking %BDRV%: with 512 MB file...
echo.

powershell -nologo -noprofile -command ^
"$drv='%BDRV%'; $testFile=$drv+':\__hdd_bench_temp__.dat'; $testSizeMB=512; $buffer=New-Object byte[](1MB); (New-Object Random).NextBytes($buffer); Write-Host '  WRITE TEST (sequential)...' -F Yellow; $writeSpeed=0; $sw=[System.Diagnostics.Stopwatch]::StartNew(); try{$fs=[System.IO.File]::OpenWrite($testFile); for($i=0;$i -lt $testSizeMB;$i++){$fs.Write($buffer,0,$buffer.Length)}; $fs.Flush();$fs.Close();$sw.Stop(); $writeSpeed=[math]::Round($testSizeMB/$sw.Elapsed.TotalSeconds,1); Write-Host ('    Write Speed : {0} MB/s' -f $writeSpeed) -F Green}catch{Write-Host ('    Write failed: '+$_) -F Red; if(Test-Path $testFile){Remove-Item $testFile -Force}; exit}; Write-Host ''; Write-Host '  READ TEST (sequential)...' -F Yellow; $readSpeed=0; $rb=New-Object byte[](1MB); $sw=[System.Diagnostics.Stopwatch]::StartNew(); try{$fs=[System.IO.File]::OpenRead($testFile); while($fs.Read($rb,0,$rb.Length) -gt 0){}; $fs.Close();$sw.Stop(); $readSpeed=[math]::Round($testSizeMB/$sw.Elapsed.TotalSeconds,1); Write-Host ('    Read Speed  : {0} MB/s' -f $readSpeed) -F Green}catch{Write-Host ('    Read failed : '+$_) -F Red}; if(Test-Path $testFile){Remove-Item $testFile -Force -EA SilentlyContinue}; Write-Host ''; Write-Host '  =============================================' -F Cyan; Write-Host ('   Write : {0} MB/s    Read : {1} MB/s' -f $writeSpeed,$readSpeed) -F White; $rating=if($readSpeed -gt 1500){'***** NVMe SSD (Excellent)'}elseif($readSpeed -gt 300){'****  SATA SSD (Very Good)'}elseif($readSpeed -gt 100){'***   HDD 7200rpm (Average)'}else{'**    Slow - HDD 5400rpm or aging drive'}; $rc=if($readSpeed -gt 300){'Green'}elseif($readSpeed -gt 100){'Yellow'}else{'Red'}; Write-Host ('   Rating: {0}' -f $rating) -F $rc; Write-Host '  =============================================' -F Cyan"

echo.
goto PAUSE_RETURN


:: ================================================================
::  14. ADVANCED RECOVERY TOOLS
:: ================================================================
:ADV_RECOVERY
cls
echo.
echo  =============================================================
echo   ADVANCED RECOVERY TOOLS
echo  =============================================================
echo.
echo  -- THIRD-PARTY FREE RECOVERY TOOLS --
echo.
echo   1.  TestDisk  -- Partition ^& boot record repair
echo   2.  PhotoRec  -- Recover deleted photos ^& files
echo   3.  Recuva    -- File recovery (Piriform, free)
echo.
echo  -- WINDOWS BUILT-IN REPAIR --
echo.
echo   4.  SFC     -- System File Checker
echo   5.  DISM    -- Repair Windows Image
echo   6.  Fix Boot Record  (bootrec)
echo.
echo   0.  Back to Main Menu
echo.
set /p AROPT=  Enter option (0-6):
if "%AROPT%"=="1" goto AR_TESTDISK
if "%AROPT%"=="2" goto AR_PHOTOREC
if "%AROPT%"=="3" goto AR_RECUVA
if "%AROPT%"=="4" goto AR_SFC
if "%AROPT%"=="5" goto AR_DISM
if "%AROPT%"=="6" goto AR_BOOTREC
if "%AROPT%"=="0" goto MAIN_MENU
echo  Invalid option.
goto ADV_RECOVERY

:AR_TESTDISK
cls
echo.
echo  =============================================================
echo   TESTDISK -- Partition ^& Boot Repair
echo  =============================================================
echo.
if exist "%ProgramFiles%\TestDisk	estdisk_win.exe" ( start "" "%ProgramFiles%\TestDisk	estdisk_win.exe" & goto PAUSE_RETURN )
if exist "%ProgramFiles(x86)%\TestDisk	estdisk_win.exe" ( start "" "%ProgramFiles(x86)%\TestDisk	estdisk_win.exe" & goto PAUSE_RETURN )
if exist "C:\HDD-MasterTool-Tools\TestDisk	estdisk_win.exe" ( start "" "C:\HDD-MasterTool-Tools\TestDisk	estdisk_win.exe" & goto PAUSE_RETURN )
echo  [!] TestDisk not installed.
set /p AR_TD=  Download TestDisk portable now? (Y/N):
if /i "%AR_TD%"=="Y" (
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; $base='C:\HDD-MasterTool-Tools'; $zip=$base+'\testdisk.zip'; try{Invoke-WebRequest -Uri 'https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip' -OutFile $zip -UseBasicParsing; Expand-Archive -Path $zip -DestinationPath $base -Force; $e=Get-ChildItem -Path $base -Recurse -Filter 'testdisk_win.exe'|Select-Object -First 1; if($e){Write-Host ('[OK] '+$e.FullName) -F Green; Start-Process $e.FullName}else{Write-Host '[!] Not found in archive.' -F Red}; Remove-Item $zip -Force -EA SilentlyContinue}catch{Write-Host ('[!] Download failed: '+$_) -F Red; Write-Host '[i] Manual: https://www.cgsecurity.org/wiki/TestDisk_Download' -F DarkGray}"
) else (
    echo  [i] Manual: https://www.cgsecurity.org/wiki/TestDisk_Download
)
goto PAUSE_RETURN

:AR_PHOTOREC
cls
echo.
echo  =============================================================
echo   PHOTOREC -- Photo ^& File Recovery
echo  =============================================================
echo.
if exist "%ProgramFiles%\TestDisk\photorec_win.exe" ( start "" "%ProgramFiles%\TestDisk\photorec_win.exe" & goto PAUSE_RETURN )
if exist "%ProgramFiles(x86)%\TestDisk\photorec_win.exe" ( start "" "%ProgramFiles(x86)%\TestDisk\photorec_win.exe" & goto PAUSE_RETURN )
if exist "C:\HDD-MasterTool-Tools\TestDisk\photorec_win.exe" ( start "" "C:\HDD-MasterTool-Tools\TestDisk\photorec_win.exe" & goto PAUSE_RETURN )
echo  [!] PhotoRec not found (bundled with TestDisk).
set /p AR_PR=  Download TestDisk+PhotoRec now? (Y/N):
if /i "%AR_PR%"=="Y" (
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; $base='C:\HDD-MasterTool-Tools'; $zip=$base+'\testdisk.zip'; try{Invoke-WebRequest -Uri 'https://www.cgsecurity.org/testdisk-7.2-WIP.win.zip' -OutFile $zip -UseBasicParsing; Expand-Archive -Path $zip -DestinationPath $base -Force; $e=Get-ChildItem -Path $base -Recurse -Filter 'photorec_win.exe'|Select-Object -First 1; if($e){Write-Host ('[OK] '+$e.FullName) -F Green; Start-Process $e.FullName}else{Write-Host '[!] Not found in archive.' -F Red}; Remove-Item $zip -Force -EA SilentlyContinue}catch{Write-Host ('[!] Download failed: '+$_) -F Red}"
) else (
    echo  [i] Manual: https://www.cgsecurity.org/wiki/PhotoRec
)
goto PAUSE_RETURN

:AR_RECUVA
cls
echo.
echo  =============================================================
echo   RECUVA -- File Recovery Tool
echo  =============================================================
echo.
if exist "%ProgramFiles%\Recuva\Recuva.exe" ( start "" "%ProgramFiles%\Recuva\Recuva.exe" & goto PAUSE_RETURN )
if exist "%ProgramFiles(x86)%\Recuva\Recuva.exe" ( start "" "%ProgramFiles(x86)%\Recuva\Recuva.exe" & goto PAUSE_RETURN )
echo  [!] Recuva not installed.
set /p AR_RV=  Download Recuva installer now? (Y/N):
if /i "%AR_RV%"=="Y" (
    if not exist "C:\HDD-MasterTool-Tools" mkdir "C:\HDD-MasterTool-Tools"
    powershell -nologo -noprofile -command "$ProgressPreference='SilentlyContinue'; try{Invoke-WebRequest -Uri 'https://download.ccleaner.com/rcsetup156.exe' -OutFile 'C:\HDD-MasterTool-Tools\rcsetup.exe' -UseBasicParsing; Write-Host '[OK] Saved to C:\HDD-MasterTool-Tools\rcsetup.exe' -F Green; Start-Process 'C:\HDD-MasterTool-Tools\rcsetup.exe'}catch{Write-Host ('[!] Download failed: '+$_) -F Red}"
) else (
    echo  [i] Manual: https://www.ccleaner.com/recuva/download
)
goto PAUSE_RETURN

:AR_SFC
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

:AR_DISM
cls
echo.
echo  =============================================================
echo   DISM -- Repair Windows Image
echo  =============================================================
echo.
echo  [*] Step 1: Checking health...
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo  [*] Step 2: Scanning health...
DISM /Online /Cleanup-Image /ScanHealth
echo.
echo  [*] Step 3: Restoring health...
DISM /Online /Cleanup-Image /RestoreHealth
goto PAUSE_RETURN

:AR_BOOTREC
cls
echo.
echo  =============================================================
echo   FIX BOOT RECORD (bootrec)
echo  =============================================================
echo.
echo  [!] WARNING: Modifies the Master Boot Record.
echo  [!] Only use if Windows fails to boot.
echo.
echo   A.  Fix MBR only          (bootrec /fixmbr)
echo   B.  Fix Boot Sector       (bootrec /fixboot)
echo   C.  Rebuild BCD           (bootrec /rebuildbcd)
echo   D.  Run ALL three         (Recommended for boot failure)
echo.
set /p BOPT=  Choose A / B / C / D:
if /i "%BOPT%"=="A" ( bootrec /fixmbr & goto PAUSE_RETURN )
if /i "%BOPT%"=="B" ( bootrec /fixboot & goto PAUSE_RETURN )
if /i "%BOPT%"=="C" ( bootrec /rebuildbcd & goto PAUSE_RETURN )
if /i "%BOPT%"=="D" (
    bootrec /fixmbr
    bootrec /fixboot
    bootrec /rebuildbcd
    goto PAUSE_RETURN
)
echo  Invalid option.
goto PAUSE_RETURN


:: ================================================================
::  15. REPORTS & LOGS
:: ================================================================
:REPORTS_LOGS
cls
echo.
echo  =============================================================
echo   REPORTS ^& LOGS -- Export Drive Report
echo  =============================================================
echo.
echo  [*] Generating full drive report...
echo  [*] This will be saved to your Desktop.
echo.

powershell -nologo -noprofile -command ^
"$ts=Get-Date -Format 'yyyyMMdd_HHmmss'; $f="$env:USERPROFILE\Desktop\HDD-Report_$ts.txt"; $r=[System.Collections.Generic.List[string]]::new(); $r.Add('='*65); $r.Add('  HDD MASTER TOOL -- Drive Report'); $r.Add('  Generated : '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')); $r.Add('  Computer  : '+$env:COMPUTERNAME+'   User: '+$env:USERNAME); $r.Add('='*65); $r.Add(''); $r.Add('-- DRIVE OVERVIEW --'); try{Get-Volume -EA SilentlyContinue|Where-Object{$_.DriveLetter -and $_.DriveType -eq 'Fixed'}|Sort-Object DriveLetter|ForEach-Object{$u=$_.Size-$_.SizeRemaining; $p=if($_.Size -gt 0){[math]::Round($u/$_.Size*100,1)}else{0}; $r.Add('  '+$_.DriveLetter+':\  Total: '+[math]::Round($_.Size/1GB,1)+'GB  Used: '+[math]::Round($u/1GB,1)+'GB ('+$p+'%)  Free: '+[math]::Round($_.SizeRemaining/1GB,1)+'GB  FS: '+$_.FileSystem)}}catch{$r.Add('  [ERROR] '+$_.Exception.Message)}; $r.Add(''); $r.Add('-- SMART HEALTH --'); try{Get-PhysicalDisk -EA SilentlyContinue|ForEach-Object{$r.Add('  '+$_.FriendlyName+' | '+[math]::Round($_.Size/1GB,1)+'GB | '+$_.MediaType+' | '+$_.BusType+' | Health: '+$_.HealthStatus)}}catch{$r.Add('  [ERROR]')}; $r.Add(''); $r.Add('-- PARTITIONS --'); try{Get-Disk -EA SilentlyContinue|Sort-Object Number|ForEach-Object{$d=$_; $r.Add('  Disk '+$d.Number+': '+$d.FriendlyName+' '+[math]::Round($d.Size/1GB,1)+'GB ['+$d.BusType+']'); Get-Partition -DiskNumber $d.Number -EA SilentlyContinue|ForEach-Object{$l=if($_.DriveLetter){$_.DriveLetter+':'}else{'(no letter)'}; $r.Add('    Part '+$_.PartitionNumber+': '+$l+' '+[math]::Round($_.Size/1GB,2)+'GB ['+$_.Type+']')}}}catch{$r.Add('  [ERROR]')}; $r.Add(''); $r.Add('-- VOLUME SHADOW COPIES --'); try{$v=vssadmin list shadows 2>&1; $v|ForEach-Object{$r.Add('  '+$_)}}catch{$r.Add('  [ERROR]')}; $r.Add(''); $r.Add('-- TOP 10 LARGEST FILES (C:\) --'); try{Get-ChildItem -Path 'C:\' -Recurse -File -Force -EA SilentlyContinue|Sort-Object Length -Descending|Select-Object -First 10|ForEach-Object{$sz=if($_.Length -ge 1GB){[math]::Round($_.Length/1GB,2)+'GB'}else{[math]::Round($_.Length/1MB,1)+'MB'}; $r.Add('  '+$sz+'  '+$_.FullName)}}catch{$r.Add('  [ERROR]')}; $r.Add(''); $r.Add('-- DISK EVENT ERRORS (last 7 days) --'); try{$since=(Get-Date).AddDays(-7); $ev=Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$since;Level=1,2} -EA SilentlyContinue|Where-Object{$_.ProviderName -match 'disk|atapi|nvme|storhport|iaStorA'}|Select-Object -First 10; if($ev){$ev|ForEach-Object{$r.Add('  '+$_.TimeCreated.ToString('yyyy-MM-dd HH:mm')+' ['+$_.ProviderName+'] ID:'+$_.Id+' '+$_.Message.Split([char]10)[0])}}else{$r.Add('  No disk errors in the last 7 days.')}}catch{$r.Add('  [ERROR]')}; $r.Add(''); $r.Add('='*65); $r.Add('  END -- HDD Master Tool by JahirCyberDesk'); $r.Add('  YouTube: https://youtube.com/@jahircyberdesk'); $r.Add('='*65); $r|Out-File -FilePath $f -Encoding UTF8; Write-Host ('  Report saved to Desktop:') -F Green; Write-Host ('  '+$f) -F White; Write-Host ''; $o=Read-Host '  Open in Notepad? (Y/N)'; if($o -in @('Y','y')){Start-Process notepad.exe $f}"

echo.
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
echo   2.  Start Emergency Image Backup (Option 10)
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
