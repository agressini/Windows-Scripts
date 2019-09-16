$ou = "Distigushename aqui"
Get-Aduser -searchbase $ou | Set-ADUser -ChangePasswordAtLogon $true