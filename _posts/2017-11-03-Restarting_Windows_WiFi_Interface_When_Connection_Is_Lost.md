---
layout: post
title:  "Restarting Windows WiFi interface when connection is lost"
date:   2017-11-03 00:00:00 -0300
categories: networking scripting windows wifi
---

Something odd happens on a few embedded equipments with Windows 10. Wifi interface just stop working. AP was working fine, but interface just stop sending or receiveng data.

After a few manual tests I could confirm a few facts:

- Host didn't hang.
- Host operating system didn't log anything about this event.
- AP didn't log anything in particular at that moment.
- Windows command from console can't renew IP (ipconfig /release, ipconfig /renew)

I did make it working again when I used command to disable/enable wifi controller. 

I wrote a batch script that can be run periodically using task manager. This script test if there is network connectivity. If not, then just restart interface.

Windows "ping.exe" command was not very useful. When host is down, it returns exit code different from 0, but when host is unreachable, it returns 0.  I had to use "fping" tool to detect network connectivity status in a useful manner for what I intended.

Batch script:

```console
@echo off
set RUNDIR=C:\Users\stick new\Desktop\resetConnection

set LOG="%RUNDIR%\resetConnection.log"
set DELAY=10
set TESTINGHOST=10.0.0.1

echo %DATE% %TIME% >> %LOG%

REM Connectivity test
"%RUNDIR%\fping.exe" %TESTINGHOST% >nul

REM echo %ERRORLEVEL%

IF ERRORLEVEL 1 (
goto :RECONNECT
) ELSE (
goto :SUCCESS
)


:RECONNECT
REM Reconnect interface
echo No connectivity with %TESTINGHOST%  >> %LOG%

echo Disabling interface  >> %LOG%
netsh interface set interface "Wi-Fi" disabled

timeout -T %DELAY% /NOBREAK >nul

echo Enabling interface  >> %LOG%
netsh interface set interface "Wi-Fi" enabled
goto :END

:SUCCESS
echo OK >> %LOG%

:END
echo. >> %LOG%
```

There are some manually defined variables in the batch file:

- RUNDIR: folder where script and complementary files are located.
- DELAY: time in seconds that waits to enable interface, after disable it.
- TESTINGHOST: host used to test connectivity.

This script assumes wifi interface name is "Wi-Fi". This is used internally with command "netsh". Wifi interface name can be determined running the following command:

```console
netsh interface show interface
```

I also built an xml file ("resetConnection.xml") to easily add batch script to task manager.

It is defined to run every 5 minutes. There is an internal reference
for batch script path inside that file, so if you change destination folder
you must modify <Command> entry in xml file.

To add batch file to task manager, start command prompt with
administator permissions and run:

```console
schtasks /create /XML resetConnection.xml /TN "resetConnection"
```

This script creates a log file you could check after every run ("resetConnection.log")
on the same folder.

**Project files available on github:**
[https://github.com/rjrpaz/resetConnection](https://github.com/rjrpaz/resetConnection)



References:

- [https://superuser.com/questions/403905/ping-from-windows-7-get-no-reply-but-sets-errorlevel-to-0](https://superuser.com/questions/403905/ping-from-windows-7-get-no-reply-but-sets-errorlevel-to-0)
- [http://forums.whirlpool.net.au/archive/1663110#r28580508](http://forums.whirlpool.net.au/archive/1663110#r28580508)
- [http://www.softpedia.com/get/Network-Tools/IP-Tools/Fping.shtml](http://www.softpedia.com/get/Network-Tools/IP-Tools/Fping.shtml)
- [https://superuser.com/questions/696270/how-to-turn-on-wifi-via-cmd](https://superuser.com/questions/696270/how-to-turn-on-wifi-via-cmd)
- [https://stackoverflow.com/questions/28855087/how-to-schedule-a-task-for-every-5-minutes-in-windows-command-prompt](https://stackoverflow.com/questions/28855087/how-to-schedule-a-task-for-every-5-minutes-in-windows-command-prompt)

