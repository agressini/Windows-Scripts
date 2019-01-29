$path = "$env:USERPROFILE\Desktop\NTP_ALL_DC\"

If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}

Get-ADForest | %{Get-ADDomainController -Filter *} | select hostname,IPv4Address, site | 
Foreach { 
            try{
                $ofile = $path + $_.hostname+ "_" +(Get-Date).ToString('yyyyMMddHHmmss') + ".txt"
                $res= Invoke-Command -ComputerName $_.hostname -ScriptBlock{hostname.exe
                w32tm.exe /query /status
                w32tm.exe /query /configuration
                w32tm.exe /query /peers} -ErrorAction Continue
                $res | Out-File -FilePath $ofile}
            catch{
                $Error | Out-File -FilePath $ofile
                Continue
            }


}
                                                                 