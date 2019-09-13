$DNSServer = "DC01"
$Zones = @(Get-DnsServerZone -ComputerName $DNSServer)
ForEach ($Zone in $Zones) {
	Write-Host "`n$($Zone.ZoneName)" -ForegroundColor "Green"
	$Results = $Zone | Get-DnsServerResourceRecord -ComputerName $DNSServer
	echo $Results > "$($Zone.ZoneName).txt"
}