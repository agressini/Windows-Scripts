param (
    [switch]$ChangeUPN = $false,
    [switch]$LogDataChange = $false,
    [switch]$DumpData = $false,
    [string]$path = "",
    [string]$sb = "", 
    [string]$NewUPNSufix = ""   
    
)
$helpMSGA = ""
$helpMSGB = ""

if (($DumpData -eq $true) -and ($path -ne "") -and ($sb -ne ""))
{
    
}
else
{
    $helpMSGA
}

if (($ChangeUPN -eq $true) -and ($path -ne "") -and ($sb -ne ""))
{
    $user = "TECAAJ"
    $address = Get-ADUser $user -Properties proxyAddresses | Select -Expand proxyAddresses | Where {$_ -clike "SMTP:*"}
    $address = $address.SubString(5)
    Set-ADUser $user -UserPrincipalName $address
}
else
{
    $helpMSGB
}