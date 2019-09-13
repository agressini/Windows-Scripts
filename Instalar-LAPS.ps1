Import-Module AdmPwd.PS
Update-AdmPwdADSchema 
Set-AdmPwdComputerSelfPermissions -OrgUnit ‘Domain Computers‘
Find-AdmPwdExtendedRights -Identity ‘Domain Computers‘
Set-AdmPwdReadPasswordPermissions -Orgunit ‘Domain Computers‘ -AllowedPrinciples PeteNetLiveHelpDesk
Get-AdmPwdPassword -ComputerName hostname

