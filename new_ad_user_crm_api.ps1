#################################################################################
#                             Semi Automated New AD user                        #
#################################################################################

#Vars
$ou = 'OU=Users,OU=Papyrus,DC=papyrus,DC=dev'
#$ou = 'CN=Users,DC=arigato,DC=local'
$upn = ''
$home_dir = ''
$profile_dir = ''
$create_folder = ''
$lname = ''
$gname = ''
$fullname = ''
$samacountname = ''
$userok = $false
$chku = ''
$err=@()
$pw = '' 
$ErrorActionPreference = "silentlycontinue"
$disname = ''
$typeof = ''
$phone = ''
$userok2 = $false
$userok3 = $false
$create_folder2 = ''
$create_folder3 = ''

#Ask for user type

do{
    $typeof = Read-Host "What type of user is it? Developer = 1 or Standard = 2"
        switch ($typeof)
        {
            1{
            $userok = $true
            Write-Host "OK! Developer"
            }
            2{
            $userok = $true
            Write-Host "OK! Standar"
            }
            default{
            $userok = $false
            Write-Host "Please choose between Dev = 1 or Standar = 2"
            }
        }
    
 }while (!$userok)

 #Ask for full name (Separate by blank space)
 do
 {
    $fullname = Read-Host "What is the full name of the user (Separate by blank space, eg. Bruce Wayne)"

    $gname = $fullname.split(' ')[0]
    $gname = $gname.ToLower()
    $lname = $fullname.split(' ')[1]
    $lname = $lname.ToLower()
    $samacountname = ($gname) +'_'+ ($lname.Substring(0,1))
    $upn = $samacountname + "@papyrus.dev"
    #$upn = $samacountname + "@arigato.local"
    $disname = $gname +' '+ ($lname.Substring(0,1))
    
    #Check username
    $chku = Get-ADUser -Identity $samacountname -ErrorAction SilentlyContinue -ErrorVariable +err | select SamAccountName

    if(($fullname -match ' ') -and ($chku.SamAccountName -ne $samacountname))
    {
        Write-Host $samacountname " is OK and will be used"
        $userok2 = $true 
    }
    else
    {
        Write-Host "The username provided already exists or don't meet the criteria, please enter a valid full name eg. Thomas Wayne"
        $userok2 = $false
    }
 }
 while(!$userok2)

 #Ask for users phone number

 do
 {
    $phone = Read-Host "What is his/hers phone number?"
    $phone.Length

    if (($phone.Length -gt 4) -and ($phone -ne ''))
    {
        Write-Host $phone " is ok"
        $userok3 = $true
    }
    else
    {
        Write-Host "Please, write a valid phone number must have 5 digits at least"
        $userok3 = $false
    }
 }
 while(!$userok3)

#Create user
$pw = ConvertTo-SecureString "Papyrus.$phone" -AsPlainText -Force 
New-ADUser -Name $disname -SamAccountName $samacountname -DisplayName $disname -GivenName $gname -Surname ($lname.Substring(0,1)) -Path $ou -UserPrincipalName $upn -ChangePasswordAtLogon $true -AccountPassword $pw -Enabled $true 

switch ($typeof)
        {
            1{
                #group memberships
                Add-ADGroupMember 'Remote Desktop Group' -Members $samacountname
                Add-ADGroupMember Admin -Members $samacountname
                Add-ADGroupMember Developer -Members $samacountname
                Add-ADGroupMember Citation -Members $samacountname

                #process the paths
                $create_folder = "c:\papyrus.dev\RoamingProfiles\" + $samacountname +'.v6'
                $create_folder2 = "c:\papyrus.dev\SVNCHeckout\branches\" + $samacountname
                $create_folder4 = "c:\papyrus.dev\ManicTime\" + $samacountname
                $profile_dir = "\\server.papyrus.dev\RoamingProfiles$\"+ $samacountname +'.v6'
                $home_dir = "\\server.papyrus.dev\branches\"+ $samacountname

                #set home
                Set-ADUser -Identity $samacountname -HomeDirectory $home_dir -HomeDrive U;
                Set-ADUser -Identity $samacountname -ProfilePath $profile_dir
                
                #.NET libraries ACL
                $colRights = [System.Security.AccessControl.FileSystemRights]'FullControl,Read,Write,Modify,ListDirectory,ReadAndExecute' 
                $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit  
                $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly 
                $objUser = New-Object System.Security.Principal.NTAccount("PAPYRUS\$samacountname")
                $objType =[System.Security.AccessControl.AccessControlType]::Allow 
                
                #Create Folder
                New-Item -ItemType Directory -Force -Path "$create_folder" 
                Write-Host "$create_folder was created"
                Get-ACL -Path $create_folder
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder"
                Set-Acl -Path $create_folder -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder $objACL
                Write-Host "$samacountname have full control ver: $create_folder"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder 
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder $objACL
                Get-ACL $create_folder | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder

                #Create Folder2
                New-Item -ItemType Directory -Force -Path "$create_folder2"
                Write-Host "$create_folder2 was created"
                Get-ACL -Path $create_folder2
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder2
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder2"
                Set-Acl -Path $create_folder2 -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder2 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder2 $objACL
                Write-Host "$samacountname have full control ver: $create_folder2"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder2 
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder2 $objACL
                Get-ACL $create_folder2 | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder2
                
                #Create Folder4
                New-Item -ItemType Directory -Force -Path "$create_folder4"
                Write-Host "$create_folder4 was created"
                Get-ACL -Path $create_folder4
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder4
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder4"
                Set-Acl -Path $create_folder4 -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder4 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder4 $objACL
                Write-Host "$samacountname have full control ver: $create_folder4"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder4 
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder4 $objACL
                Get-ACL $create_folder4 | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder4

            }
            2{
                #group memberships
                Add-ADGroupMember 'Remote Desktop Group' -Members $samacountname
                Add-ADGroupMember Admin -Members $samacountname
                Add-ADGroupMember Developer -Members $samacountname
                Add-ADGroupMember Citation -Members $samacountname

                #process the paths
                $create_folder = "c:\papyrus.dev\RoamingProfiles\" + $samacountname +'.v6'
                $create_folder3 = "C:\papyrus.dev\HomeFolders\" + $samacountname
                $create_folder4 = "c:\papyrus.dev\ManicTime\" + $samacountname
                $profile_dir = "\\server.papyrus.dev\RoamingProfiles$\"+ $samacountname +'.v6'
                $home_dir = "\\server.papyrus.dev\HomeFolders\"+ $samacountname

                #set home
                Set-ADUser -Identity $samacountname -HomeDirectory $home_dir -HomeDrive U;
                Set-ADUser -Identity $samacountname -ProfilePath $profile_dir

                #.NET libraries ACL
                $colRights = [System.Security.AccessControl.FileSystemRights]'FullControl,Read,Write,Modify,ListDirectory,ReadAndExecute' 
                $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit  
                $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly  
                $objUser = New-Object System.Security.Principal.NTAccount("PAPYRUS\$samacountname")
                $objType =[System.Security.AccessControl.AccessControlType]::Allow 
                
                #Create Folder
                New-Item -ItemType Directory -Force -Path "$create_folder"
                Write-Host "$create_folder was created"
                Get-ACL -Path $create_folder
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder"
                Set-Acl -Path $create_folder -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder $objACL
                Write-Host "$samacountname have full control ver: $create_folder"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder 
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder $objACL
                Get-ACL $create_folder | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder

                #Create Folder3
                New-Item -ItemType Directory -Force -Path "$create_folder3"
                Write-Host "$create_folder3 was created"
                Get-ACL -Path $create_folder3
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder3
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder3"
                Set-Acl -Path $create_folder3 -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder3 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder3 $objACL
                Write-Host "$samacountname have full control ver: $create_folder3"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder3
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder3 $objACL
                Get-ACL $create_folder3 | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder3

                #Create Folder4
                New-Item -ItemType Directory -Force -Path "$create_folder4"
                Write-Host "$create_folder4 was created"
                Get-ACL -Path $create_folder4
                #Set permissions disable inheritance
                $acl = Get-ACL -Path $create_folder4
                $acl.SetAccessRuleProtection($True, $True)
                Write-Host "Inheritance was disabled in $create_folder4"
                Set-Acl -Path $create_folder4 -AclObject $acl
                #Set perrmissions add full control to the new user
                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACL = Get-ACL $create_folder4 
                $objACL.AddAccessRule($objACE) 
                Set-ACL $create_folder4 $objACL
                Write-Host "$samacountname have full control ver: $create_folder4"
                #Delete users group and taibouni
                $objUser3 = New-Object System.Security.Principal.NTAccount("BUILTIN\Users")
                $objUser4 = New-Object System.Security.Principal.NTAccount("PAPYRUS\taibouni_h")
                $objACE3 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser3, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
                $objACE4 = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser4, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
                $objACL = Get-ACL $create_folder4 
                $objACL.RemoveAccessRuleAll($objACE3) 
                $objACL.RemoveAccessRuleAll($objACE4) 
                Set-ACL $create_folder4 $objACL
                Get-ACL $create_folder4 | FL
                Write-Host "Users Group and Taibouni user are deleted"
                Get-ACL -Path $create_folder4

            }
        }    