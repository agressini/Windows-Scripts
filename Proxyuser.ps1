Get-ADUser -Filter * -SearchBase 'OU=Usuarios,DC=labvmw,DC=local' -Properties proxyaddresses | 
select name, @{L='ProxyAddress_1'; E={$_.proxyaddresses[0]}}, @{L='ProxyAddress_2';E={$_.ProxyAddresses[1]}} | 
Export-Csv -Path .\proxyaddresses.csv –NoTypeInformation