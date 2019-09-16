1102 clear log Arbitrario
4672 logon de admins o usuarios con privilegios
4624 Cuenta inicio logueo
4647 usuario hizo logoff
4634 logoff exitoso


PS> $Event = Get-WinEvent -LogName 'Windows PowerShell'

PS> $Event.Count
195

PS> $Event | Group-Object -Property Id -NoElement | Sort-Object -Property Count -Descending

Count  Name
-----  ----
  147  600
   22  400
   21  601
    3  403
    2  103

PS> $Event | Group-Object -Property LevelDisplayName -NoElement

Count  Name
-----  ----
    2  Warning
  193  Information

  Get-WinEvent -LogName  *PowerShell*, Microsoft-Windows-Kernel-WHEA* | Group-Object -Property LevelDisplayName, LogName -NoElement | Format-Table -AutoSize

Count  Name
-----  ----
    1  Error, PowerShellCore/Operational
   26  Information, Microsoft-Windows-Kernel-WHEA/Operational
  488  Information, Microsoft-Windows-PowerShell/Operational
   77  Information, PowerShellCore/Operational
 9835  Information, Windows PowerShell
   19  Verbose, PowerShellCore/Operational
  444  Warning, Microsoft-Windows-PowerShell/Operational
  512  Warning, PowerShellCore/Operational

  Get-WinEvent -Path 'C:\Test\Windows PowerShell.evtx'

ProviderName: PowerShell

TimeCreated              Id LevelDisplayName  Message
-----------              -- ----------------  -------
3/15/2019 13:54:13      403 Information       Engine state is changed from Available to Stopped...
3/15/2019 13:54:13      400 Information       Engine state is changed from None to Available...
3/15/2019 13:54:13      600 Information       Provider "Variable" is Started...
3/15/2019 13:54:13      600 Information       Provider "Function" is Started...
3/15/2019 13:54:13      600 Information       Provider "FileSystem" is Started...


PS> Get-WinEvent -Path 'C:\Test\PowerShellCore Operational.evtx' -MaxEvents 100

   ProviderName: PowerShellCore

TimeCreated                 Id   LevelDisplayName  Message
-----------                 --   ----------------  -------
3/15/2019 09:54:54        4104   Warning           Creating Scriptblock text (1 of 1):...
3/15/2019 09:37:13       40962   Information       PowerShell console is ready for user input
3/15/2019 07:56:24        4104   Warning           Creating Scriptblock text (1 of 1):...
...
3/7/2019 10:53:22        40961   Information       PowerShell console is starting up
3/7/2019 10:53:22         8197   Verbose           Runspace state changed to Opening
3/7/2019 10:53:22         8195   Verbose           Opening RunspacePool

PS> Get-WinEvent -Path 'C:\Tracing\TraceLog.etl' -Oldest | Sort-Object -Property TimeCreated -Descending | Select-Object -First 100

PS> Get-WinEvent -Path 'C:\Tracing\TraceLog.etl', 'C:\Test\Windows PowerShell.evtx' -Oldest | Where-Object { $_.Id -eq '403' }

# Using the Where-Object cmdlet:
PS> $Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
PS> Get-WinEvent -LogName 'Windows PowerShell' | Where-Object { $_.TimeCreated -ge $Yesterday }

# Using the FilterHashtable parameter:
PS> $Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
PS> Get-WinEvent -FilterHashtable @{ LogName='Windows PowerShell'; Level=3; StartTime=$Yesterday }

# Using the FilterXML parameter:
PS> Get-WinEvent -FilterXML "<QueryList><Query><Select Path='Windows PowerShell'>*[System[Level=3 and TimeCreated[timediff(@SystemTime)<= 86400000]]]</Select></Query></QueryList>"

# Using the FilterXPath parameter:
PS> Get-WinEvent -LogName 'Windows PowerShell' -FilterXPath "*[System[Level=3 and TimeCreated[timediff(@SystemTime) <= 86400000]]]"

$Date = (Get-Date).AddDays(-2)
Get-WinEvent -FilterHashtable @{ LogName='Application'; StartTime=$Date; Id='1003' }

$StartTime = (Get-Date).AddDays(-7)
Get-WinEvent -FilterHashtable @{ Logname='Application'; ProviderName='Application Error'; Data='iexplore.exe'; StartTime=$StartTime }