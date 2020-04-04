$Nodes = Get-ClusterNode -cluster "WTROSCADACLPR01" | Select-Object -Expand Name

Enable-VMMigration –Computername $Nodes -ErrorAction Stop| Out-Null

Set-VMHost –Computername $Nodes –VirtualMachineMigrationAuthenticationType Kerberos
 
Enable-VMMigration –Computername $Nodes -ErrorAction Stop| Out-Null
 
Set-VMHost –Computername $Nodes –VirtualMachineMigrationAuthenticationType Kerberos

Set-VMHost –Computername $Nodes -VirtualMachineMigrationPerformanceOption SMB

Set-VMHost –Computername $Nodes -MaximumVirtualMachineMigrations 8
