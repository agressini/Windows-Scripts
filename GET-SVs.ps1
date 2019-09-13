$SV = Get-ADUser -filter * -Properties DisplayName,SamAccountName,Enabled,LockedOut,LogonWorkstations,PasswordExpired,PasswordLastSet,PasswordNeverExpires,ProtectedFromAccidentalDeletion | 
select DisplayName,SamAccountName,Enabled,LockedOut,LogonWorkstations,PasswordExpired,PasswordLastSet,PasswordNeverExpires,ProtectedFromAccidentalDeletion |
Where SamAccountName -Like "SV*" 
$SV | Export-Csv -NoTypeInformation -Delimiter ";" -Path $env:USERPROFILE\Desktop\usuarios_SV.csv
$SV | Out-GridView