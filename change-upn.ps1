param (
    [switch]$ChangeUPN = $false,
    [switch]$DumpData = $false,
    [string]$Path = "",
    [string]$Searchbase = "", 
    [string]$NewUPNSufix = ""   
    
)
$mode=0
$Fname = "\Reporte"+(Get-Date).ToString("ddMMyyyy")+".csv"
$Fname2 = "\Reporte_cambio_"+(Get-Date).ToString("ddMMyyyy")+".csv"

$MSGpath = "Los archivos se guardaran en la ruta: "

$helpMSG = 'Para exportar los usuarios con la configuracion actual se debe proporcionar parametros:
-ChangeUPN 
-Path 
-Searchabase 
-NewUPNSufix
Ej: .\change-upn.ps1 -DumpData -Path C:\Scripts\ -Searchbase "OU=Usuarios,DC=labvmw,DC=local 
Para realizar el cambio de upn en los usuarios de la OU identificada en el parametro Searchbase se debe proporcionar los parametros:
-Path
-DumpData
-Searchbase
Ej: .\change-upn.ps1 -ChangeUPN -Path C:\Scripts\ -Searchbase "OU=Usuarios,DC=labvmw,DC=local" -NewUPNSufix "@tecpetrol.com"'

$Path2 = $Path

if ((Test-Path -Path $Path))
{
    Write-Host $MSGpath $Path
}
else
{
    New-Item -ItemType Directory -Force -Path $Path -Verbose | Out-Null
    Write-Host "Se creo la carpeta "  $Path "las salidas se redirecionaran en esta ruta."
}

if(($DumpData -eq $true) -and ($Path -ne "") -and ($Searchbase -ne ""))
{
    $mode =1
}
if(($ChangeUPN -eq $true) -and ($path -ne "") -and ($sb -ne "") -and ($NewUPNSufix -ne ""))
{
    $mode=2
}
if($mode -eq 0){$helpMSG}


if (($mode -eq 1) -or ($mode -eq 2))
{
    $Path+= $Fname
    Get-ADUser -SearchBase $Searchbase -Filter * -properties *| Select-Object Name,SamAccountName,UserPrincipalName | 
    Export-Csv -Path $Path -NoTypeInformation
}

if ($mode -eq 2)
{
    $Path2+= $fname2
    $users = Import-Csv -Path $Path
    $csv = "Name,SamAccountname,OLD_UPN,NEW_UPN`n" | Out-file -Append -FilePath $Path2 | Out-Null
    
    foreach ($user in $users)
    {
        $upn = $user.SamAccountName+$NewUPNSufix
        Set-ADUser $user.SamAccountName   -UserPrincipalName $upn
        Write-Host "Cambiando el valor de " $user.Name " Nuevo UPN: " $upn
        $csv = $user.Name + "," + $user.SamAccountName + "," + $user.UserPrincipalName + "," + $upn 
        $csv | Out-file -Append -FilePath $Path2
    }
}