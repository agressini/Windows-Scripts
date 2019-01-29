###------------------------------###  
### Author : Biswajit Biswas-----###    
###MCC, MCSA,MCTS, CCNA, SME,ITIL###  
###Email<bshwjt@gmail.com>-------###  
###------------------------------###  
###/////////..........\\\\\\\\\\\###  
###///////////.....\\\\\\\\\\\\\\###
###Required PS Version 3 or Above###  
ipmo ActiveDirectory
Function Get-DomainControllers {
$ary = [ordered]@{}
$ComputerName = Get-ADDomainController -Filter *
$DOmainControllersOUComputers = $ComputerName.Name
$ErrorActionPreference = "Stop" 
foreach ($computer in $DOmainControllersOUComputers) 
  { 

Try {
$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
#1. Computer Name
$ary.DomainControllerName = Get-ADDomainController $computer | Select-Object -ExpandProperty Name



#2. NTDS.DIT Path
 
$RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\services\\NTDS\\Parameters") 
$ary.DataBasePath = $Regkey.GetValue("DSA Database file") 

#3. NTDS.DIT Size

$RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\services\\NTDS\\Parameters") 
$NTDSPath = $Regkey.GetValue("DSA Database file")
$NTDSREMOTEPath =  "\\$computer\$NTDSPath" -replace ":","$"
$NTDSREMOTEPath = Get-item $NTDSREMOTEPath | Select-Object -ExpandProperty Length
$ary.NTDSSize = ($NTDSREMOTEPath /1GB).ToString("0.000"+" GB")

# Sysvol Path

$RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\services\\Netlogon\\Parameters") 
$ary.SysVolPath = $Regkey.GetValue("SysVol") 




New-Object PSObject -property $ary 
}  

  Catch
  {
  
  Add-Content "$computer is not reachable" -path $env:USERPROFILE\Desktop\UnreachableDCs.txt
  }
 }
}
#HTML Color Code
#http://technet.microsoft.com/en-us/library/ff730936.aspx
$date = Get-Date
$a = "<style>"
$a = $a + "BODY{background-color:#DAA520;font-family:verdana;font-size:10pt;}"
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color:#000000;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: #000000;background-color:#7FFF00;}" 
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: #000000;background-color:#FFD700;}"
$a = $a + "</style>"
$DomainName= Get-ADDomain
$DN= $DomainName.Name
Get-DomainControllers | ConvertTo-HTML -head $a -body "<H2>$DN Domain Controllers NTDS.DIT Size</H2>" | 
Out-File $env:USERPROFILE\Desktop\DomainController.htm #HTML Output
Invoke-Item $env:USERPROFILE\Desktop\DomainController.htm