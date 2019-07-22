
$newname = "NAR"
#$newname = "NPE"

$nic = Get-NetAdapter -Physical | Where-Object -EQ PhysicalMediaType "802.3"

if ($nic.PhysicalMediaType -eq "802.3")
{
    $mac=$nic.MacAddress.Replace("-","")
    $newname += $mac.Substring(6)
    Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $newname
}
else {
    $nic = Get-NetAdapter -Physical | Where-Object -Like PhysicalMediaType "*802.11*"
    $mac=$nic.MacAddress.Replace("-","")
    $newname += $mac.Substring(6)
    Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $newname
}





  