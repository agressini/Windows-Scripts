param (
    [string]$OU = "",
    [string]$Exportpath = ""
)
#$Exportpath = "$env:USERPROFILE\desktop\Localadmins.csv"
#$OU="OU=Member Server,DC=labvmw,DC=local"
$Computers = Get-ADComputer -SearchBase $OU -Filter *  | Export-CSV $Exportpath -NoTypeInformation -Append -Delimiter ";"