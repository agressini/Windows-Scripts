Get-ADForest | %{Get-ADDomainController -Filter *} | select hostname,IPv4Address, site| Foreach {
 $res = Invoke-Command -ComputerName $_.hostname -ScriptBlock {Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceIndex 12 |select ServerAddresses}
 $csv += $_.hostname + "," + $_.IPv4Address + "," + $_.site + ","+$res.ServerAddresses+"`n"
}
$csv.Replace(" ",",") | Out-File -FilePath C:\Users\gfuhr\Desktop\ips.csv