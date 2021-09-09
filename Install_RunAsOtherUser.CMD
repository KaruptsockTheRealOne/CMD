
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
REM Run shell as admin (example) - put here code as you like

echo Copy File From Server to PC
set From=\\Servername\install$\Apps\Appfolder
set Destination=C:\Folder
set opts=/E /V /ETA /A-:R
RoboCopy %From% %Destination% %opts%
Pause

@echo off
echo Run a reg file in silent

Regedit /s "C:\Temp\Name_of_Reg_file.reg"
Pause

@echo off
echo Install.vbs
Start "" "C:\Temp\OpenJDK32\Install.vbs" 

@echo off
echo please let timer run to give VBS time to install
TIMEOUT /t 60

Pause

xcopy /s /e C:\Temp\Icon.ico C:\

net use m: /DELETE /Y
net use m: \\fpcolo\install$\Apps\OpenJDK32
copy "m:\GDSR.lnk" C:\users\public\Desktop\
net use m: /DELETE /Y

GOTO END

:END
