#$users = Get-ADUser -Filter * -Properties * | Select CN,DisplayName,DistinguishedName,GivenName,Name,Surname,UserPrincipalName,Info,sAMAccountName  

foreach ($user in $users){

    if ($user.Info -ieq "Staged=True")
    {
        Set-ADUser $user.sAMAccountName -Replace @{info=' '} -WhatIf  
        $out = "Notes value was modified in user: " + $user.sAMAccountName |  Out-File C:\Users\sandrade-admin\Desktop\AXA_CHANGE_LOG.txt -Append
    }

}


