Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | Export-Csv -NoTypeInformation -Path $env:USERPROFILE\Desktop\Grupos_AD.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Security" -and $_.GroupScope -eq "Global"} | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_SECyGL.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Security" -and $_.GroupScope -eq "Universal"}  | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_SECyUV.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Security" -and $_.GroupScope -eq "DomainLocal"} | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_SECyLOC.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Distribution" -and $_.GroupScope -eq "Global"}  | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_DISyGL.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Distribution" -and $_.GroupScope -eq "Universal"} | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_DISyUV.csv
Get-ADGroup -Filter * | select Name,GroupCategory,GroupScope | where {$_.GroupCategory -EQ "Distribution" -and $_.GroupScope -eq "DomainLocal"} | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Grupos_AD_DISyLOC.csv
Get-ADGroupMember -Identity "Domain Admins"  | Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Cantidad_DomainAdmins.csv
Get-ADGroupMember -Identity "Domain Admins" | select name,SamAccountName| Export-Csv -NoTypeInformation -Path $env:USERPROFILE\Desktop\DomainAdmins.csv
Get-ADGroupMember -Identity "Enterprise Admins"| Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Cantidad_EnterpriseAdmins.csv
Get-ADGroupMember -Identity "Domain Admins" | select name,SamAccountName| Export-Csv -NoTypeInformation -Path $env:USERPROFILE\Desktop\EnterpriseAdmins.csv
Get-ADGroupMember -Identity "Schema Admins"| Measure-Object | Out-File -FilePath $env:USERPROFILE\Desktop\Cantidad_SchemaAdmins.csv
Get-ADGroupMember -Identity "Domain Admins" | select name,SamAccountName| Export-Csv -NoTypeInformation -Path $env:USERPROFILE\Desktop\SchemaAdmins.csv
Get-ADServiceAccount -Filter * | select name,SamAccountName| Export-Csv -NoTypeInformation -Path $env:USERPROFILE\Desktop\ServiceAccount.csv


