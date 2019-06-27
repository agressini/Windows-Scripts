param (
    [string]$Filename = ""    
)
$csv = "User,NEW_UPN`n" | Out-file -Append -FilePath .\reporte.csv | Out-Null
$Users = Import-Csv -Path $Filename


foreach ($user in $users)
    {
        $upn = $user.EmailAddress
        Set-ADUser $user.SamAccountName   -UserPrincipalName $upn
        Write-Host "Cambiando el valor del usuario " $user.SamAccountName " Nuevo UPN: " $upn
        $csv = $user.SamAccountName + "," + $upn 
        $csv | Out-file -Append -FilePath .\reporte.csv

    }