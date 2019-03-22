$users = Get-ADUser -filter * -Properties SamAccountName,UserPrincipalName,proxyAddresses 
$CSV = "SamAccountName,UserPrincipalName,proxyAddresses `r`n"

foreach ($user in $users){

    $CSV += $user.SamAccountName + ","
    $CSV += $user.UserPrincipalName + ","
    $CSV += $user.proxyAddresses + "`r`n"

}


$CSV| Out-File $ENV:USERPROFILE\Desktop\Users.csv
