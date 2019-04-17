param (
    [switch]$ChangeUPN = $false,
    [switch]$DumpData = $false,
    [string]$Path = "",
    [string]$Searchbase = "", 
    [string]$NewUPNSufix = ""   
    
)
$MSGpath = "Las salidas se redirecionaran a: "
$helpMSGA = 'La sintaxis del  script requiere los parametros -DumpData -Path y -searchabase. 
por ejemplo: .\change-upn.ps1 -DumpData -path .\change-upn.ps1 -DumpData -path C:\Scripts -searchbase "OU=Usuarios,DC=labvmw,DC=local"'
$helpMSGB = ""
$Path2 = $Path
$csv = "Name,SamAccountname,OLD_UPN,NEW_UPN`r`n"

if ((Test-Path -Path $Path))
{
    Write-Host $MSGpath $Path
}
else
{
    New-Item -ItemType Directory -Force -Path $Path -Verbose | Out-Null
    Write-Host "Se creo la carpeta "  $Path "las salidas se redirecionaran en esta ruta."
}


if (($DumpData -eq $true) -and ($Path -ne "") -and ($Searchbase -ne ""))
{
    $Path+="\Reporte.csv"
    Get-ADUser -SearchBase $Searchbase -Filter * -properties *| Select-Object Name,SamAccountName,UserPrincipalName | 
    Export-Csv -Path $Path -NoTypeInformation
}
else
{
    Write-Host $helpMSGA
}

if (($ChangeUPN -eq $true) -and ($path -ne "") -and ($sb -ne "") -and ($NewUPNSufix -ne ""))
{
    $Path+="\Reporte.csv"
    $Path2+="\Reporte_cambio.csv"
    Get-ADUser -SearchBase $Searchbase -Filter * -properties *| Select-Object Name,SamAccountName,UserPrincipalName | 
    Export-Csv -Path $Path -NoTypeInformation
    $users = Import-Csv -Path $Path

    foreach ($user in $users)
    {
        $upn = $user.SamAccountName+$NewUPNSufix
        Set-ADUser $user.SamAccountName   -UserPrincipalName $upn
        Write-Host "Cambiando el valor de " $user.Name " Nuevo UPN: " $upn
        $csv = $user.Name + "," + $user.SamAccountName + "," + $user.UserPrincipalName + "," + $upn + "`r`n" 
        $csv | Out-file -Append -FilePath $Path2
    }
}
else
{
    $helpMSGB
}