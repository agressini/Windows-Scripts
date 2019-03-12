##TCP 25	Replication	SMTP
##TCP 42	If using WINS in a domain trust scenario offering NetBIOS resolution	WINS
##TCP 135	Replication	RPC, EPM
##TCP 137	NetBIOS Name resolution	NetBIOS Name resolution
##TCP 139	User and Computer Authentication, Replication	DFSN, NetBIOS Session Service, NetLogon
##TCP and UDP 389	Directory, Replication, User and Computer Authentication, Group Policy, Trusts	LDAP
##TCP 636	Directory, Replication, User and Computer Authentication, Group Policy, Trusts	LDAP SSL
##TCP 3268	Directory, Replication, User and Computer Authentication, Group Policy, Trusts	LDAP GC
##TCP 3269	Directory, Replication, User and Computer Authentication, Group Policy, Trusts	LDAP GC SSL
##TCP and UDP 88	User and Computer Authentication, Forest Level Trusts	Kerberos
##TCP and UDP 53	User and Computer Authentication, Name Resolution, Trusts	DNS
##TCP and UDP 445	Replication, User and Computer Authentication, Group Policy, Trusts	SMB, CIFS, SMB2, DFSN, LSARPC, NbtSS, NetLogonR, SamR, SrvSvc
##TCP 9389	AD DS Web Services	SOAP
##TCP 5722	File Replication	RPC, DFSR (SYSVOL)
##TCP and UDP 464	Replication, User and Computer Authentication, Trusts	Kerberos change/set password
#### 	 	 
##UDP 123	Windows Time, Trusts	Windows Time
##UDP 137 	User and Computer Authentication	NetLogon, NetBIOS Name Resolution
##UDP 138	DFS, Group Policy, NetBIOS Netlogon, Browsing	DFSN, NetLogon, NetBIOS Datagram Service
##UDP 67 and UDP 2535	DHCP (Note: DHCP is not a core AD DS service but these ports may be necessary for other functions besides DHCP, such as WDS)	DHCP, MADCAP, PXE

Function Test-PortConnection {
    [CmdletBinding()]
 
    # Parameters used in this function
    Param
    (
        [Parameter(Position=0, Mandatory = $True, HelpMessage="Provide destination source", ValueFromPipeline = $true)]
        $Destination,
 
        [Parameter(Position=1, Mandatory = $False, HelpMessage="Provide port numbers", ValueFromPipeline = $true)]
        $Ports = "80"
    ) 
 
    $ErrorActionPreference = "SilentlyContinue"
    $Results = @()
 
    ForEach($D in $Destination){
        # Create a custom object
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "Destination" -Value $D
 
        Write-Verbose "Checking $D"
        ForEach ($P in $Ports){
            $Result = (Test-NetConnection -Port $p -ComputerName $D ).PingSucceeded  
 
            If(!$Result){
                $Status = "Failure"
            }
            Else{
                $Status = "Success"
            }
 
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($status)"
        }
 
        $Results += $Object
 
&amp;amp;amp;amp;lt;# or easier way true/false value
        ForEach ($P in $Ports){
            $Result = $null
            $Result = Test-NetConnection -Port $p -ComputerName $D
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($Result)"
        }
 
        $Results += $Object
#&amp;amp;amp;amp;gt;
    }
 
# Final results displayed in new pop-up window
If($Results){
    $Results
}
}

Test-PortConnection -Destination CWPI-ALL-DIR-02 -Ports 25,42,135,137,139,389,636,3268,3269,88,53,9389,445,9389,5722,464,123,137,138,67,2535
##Test-PortConnection -Destination DC01,DC02 -Ports 363,80 | Export-Csv -Path C:\users\$env:username\desktop\results.csv -NoTypeInformation # Save it to CSV file on your desktop
##Test-PortConnection -Destination (GC "C:\Temp\Servers.txt") -Ports 363,80,1433
##Test-PortConnection -Destination (GC "C:\Temp\Servers.txt") -Ports 363,80,1433 | Out-GridView -Title "Results" # Display in new pop-up window