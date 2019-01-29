$path = "$env:USERPROFILE\Desktop\OUACL_BR\"
$ofile = $path + "OU_Permissions.csv"
If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}
Set-Location -Path $env:USERPROFILE\Desktop\OUACL_BR\

$schemaIDGUID = @{} 
#ignore duplicate errors if any# 
$ErrorActionPreference = 'SilentlyContinue' 
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID | 
ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)} 
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID | 
ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)} 
$ErrorActionPreference = 'Continue'
# Get OU por comandos.
#$OUs = Get-ADOrganizationalUnit -Filter 'Name -like "Production"'| Select-Object -ExpandProperty DistinguishedName
#Get OU con archivo TXT
$OUs = Get-Content -Path .\OUS_BR.txt
# retrieve OU permissions. 
# Add report columns to contain the OU path and string names of the ObjectTypes. 
ForEach ($OU in $OUs) { 
$report += Get-Acl -Path "AD:\$OU" | 
Select-Object -ExpandProperty Access | 
Select-Object @{name='organizationalUnit';expression={$OU}}, ` 
@{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, ` 
@{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, ` 
* 
# Export report out to a CSV file for analysis in Excel.
$report | Export-Csv -Path $ofile -NoTypeInformation -Append
}
 
