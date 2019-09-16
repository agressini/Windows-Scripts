Get-Aduser -searchbase "" |  ForEach-Object

$pass = -join ((33..126) | Get-Random -Count 12 | ForEach-Object {[char]$_})
Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pass -Force)
$_.samaccountname 
$pass
