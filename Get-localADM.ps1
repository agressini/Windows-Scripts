param (
    [string]$OU = "",
    [string]$Exportpath = "",
    [string]$Group="" 
)
#$Exportpath = "$env:USERPROFILE\desktop\Localadmins.csv"
#$OU="OU=Member Server,DC=labvmw,DC=local"
$Exportpathold = "No_PoSH_"+$Exportpath.Replace(".\","")
$Exportpathdis = "Servers_sin conexion_"+ $Exportpath.Replace(".\","")
$Computer = Get-ADComputer -SearchBase $OU -Filter * -Properties Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate | Select-Object Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate

ForEach ($Computers in $Computer) {
    $fqdn = $Computers.Name
    $conected = (Test-NetConnection -ComputerName $fqdn -CommonTCPPort WINRM)

    if ($conected.TcpTestSucceeded -eq $true)
    {
        $version = Invoke-Command -ComputerName $Computers.Name -ScriptBlock {return $PSVersionTable.PSVersion.Major}

        if($version -like "5*")
        {
            Invoke-Command -ComputerName $Computers.Name -ScriptBlock {Get-LocalGroupMember -Group $Using:Group} |  Select-Object * -ExcludeProperty RunspaceID | Export-CSV $Exportpath -NoTypeInformation -Append
        }
        if($version -like "2*")
        {
            Invoke-Command -ComputerName $Computers.Name -ScriptBlock {
            $members = net localgroup administrators | where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4
            New-Object PSObject -Property @{
            Computername = $env:COMPUTERNAME
            Group = "Administrators"
            Members=$members}
            
            }|  Select-Object * -ExcludeProperty RunspaceID | Export-CSV $Exportpathold -NoTypeInformation -Append
        }
        
    }
    else
    {
        $Computers | Export-CSV $Exportpathdis   -NoTypeInformation -Append
    }
    
}


