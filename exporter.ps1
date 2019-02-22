Get-ADUser -Filter * -Properties * | Select CN,DisplayName,DistinguishedName,GivenName,Name,Surname,UserPrincipalName,Info,sAMAccountName  | 
Export-Csv -NoTypeInformation -Path C:\Users\sandrade-admin\Desktop\AXA_USERS_CHANGED_RUN2.csv
Get-ADUser -Identity sandrade-admin -Properties * | Select UserPrincipalName,Info, sAMAccountName

Set-ADUser sandrade-admin -Replace @{info=' '} | Out-File C:\Users\sandrade-admin\Desktop\AXA_CHANGE_LOG.txt
$out = "Notes value was modified in user: " + $user.sAMAccountName |  Out-File C:\Users\sandrade-admin\Desktop\AXA_CHANGE_LOG.txt -Append