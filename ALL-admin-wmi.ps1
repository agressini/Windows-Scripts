param (
    [string]$coleccion="" 
)
$csv = "Computername,Admin `r`n"
$Exportpath = "$env:USERPROFILE\desktop\Localadmins-WMI.csv"
$Computer = Import-Csv -Path $coleccion

ForEach ($Computers in $Computer) {
    $fqdn = $Computers.Computername
    $fqdn
    Get-WmiObject -Class Win32_GroupUser -ComputerName $fqdn `
    | where{$_.GroupComponent -like "*Administrators*"} `
    |foreach { 
    $data = $_.PartComponent -split "\," 
    $USR = $data[1].Remove(0,5).Replace('"','') 
    $csv+= $fqdn + "," + $USR + "`r`n" 
    
    } 
    $csv | Out-File -Append -LiteralPath $Exportpath
}









