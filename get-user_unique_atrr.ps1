$path = "$env:USERPROFILE\Desktop\"+ "users_"+ (Get-ADDomain).Name +"_" +(Get-Date).ToString('yyyyMMddHHmmss')

Get-ADUser -filter * -Properties sAMAccountName,EmailAddress,telephoneNumber,EmployeeID,UserPrincipalName,ObjectGUID,objectSid | Select sAMAccountName,EmailAddress,telephoneNumber,EmployeeID,UserPrincipalName,ObjectGUID,objectSid | Export-Csv -NoTypeInformation -Force -Path $path 
