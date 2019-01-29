$path = "$env:USERPROFILE\Desktop\IPconfig_ALL_DC\"
$csv += $_.hostname + "," + $_.IPv4Address + "," + $_.site + ","+$res.ServerAddresses+"`n"

If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}

Get-ADForest | %{Get-ADDomainController -Filter *} | select hostname,IPv4Address, site | 
Foreach { 
            try{$ofile = $path + $_.hostname+ "_" +(Get-Date).ToString('yyyyMMddHHmmss') + ".txt"
                $res= Invoke-Command -ComputerName $_.hostname -ScriptBlock{
                                                                            $nic_configuration = gwmi -computer .  -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null}
                                                                            $nicDNS = Get-DnsClientServerAddress -AddressFamily IPv4 | Select ServerAddresses    
                                                                            $IP ="IP Address :" + $nic_configuration.ipaddress
                                                                            $MAC_Address = "MAC Address :" + $nic_configuration.MACAddress
                                                                            $DG_Address = "Gateway Address: "+ $nic_configuration.DefaultIPGateway
                                                                            $SubnetMask = "Subnet Mask:" + $nic_configuration.ipsubnet
                                                                            $DNS ="DNS Servers:" + $nicDNS.ServerAddresses
                                                                            $IP
                                                                            $MAC_Address
                                                                            $DG_Address
                                                                            $SubnetMask
                                                                            $DNS
                                                                           } -ErrorAction Continue
                $res | Out-File -FilePath $ofile}
            catch{
                $Error | Out-File -FilePath $ofile
                Continue
            }


}
