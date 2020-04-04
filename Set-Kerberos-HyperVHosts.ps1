$Nodes = "WTROSCADAHVPR01","WTROSCADAHVPR02","WTROSCADAHVPR03","WTROSCADAHVPR04"
 
$DomainName = "ot.edenor"
 
Foreach ($Node in $Nodes){
    Write-Host "-------- $Node ------"
    Foreach ($VMHost in $Nodes){
        If ($Node -notlike $VMHost){
            Write-Host " -> $VMHost"
            Get-ADComputer $Node | 
            Set-ADObject -Add @{"msDS-AllowedToDelegateTo"="Microsoft Virtual System Migration Service/$($VMHost).$($DomainName)", "cifs/$($VMHost).$DomainName","Microsoft Virtual System Migration Service/$($VMHost)","cifs/$($VMHost)"}
        }
 
    }
 
}