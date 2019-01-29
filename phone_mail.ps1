#Ask for users phone number

 do
 {
    $phone = Read-Host "What is his/hers phone number?"
    $phone.Length

    if (($phone.Length -gt 4) -and ($phone -ne ''))
    {
        $userok3 = $true
        $phone2= $phone
        $phone = $phone.Substring($phone.Length-4)
        Write-Host "The last numbers are: "$phone 
        
    }
    else
    {
        Write-Host "Please, write a valid phone number must have 5 digits at least"
        $userok3 = $false
    }
 }
 while(!$userok3)


#Ask for users mail

 do
 {
    $mail = Read-Host "What is his/hers mail?"

    if (($mail -match '\.') -and ($mail -match '@'))
    {
        Write-Host $mail " is ok " $mail.Substring(0,3)
        $userok4 = $true
    }
    else
    {
        Write-Host "Please, write a valid mail someone@domain.com"
        $userok4 = $false
    }
 }
 while(!$userok4)