$path = "$env:USERPROFILE\Desktop\UPNSuffixes_"+(Get-ADDomain).Name+ "\"
$ofile = $path + (Get-ADDomain).Name + "_" +(Get-Date).ToString('yyyyMMddHHmmss') + ".txt"

If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}

$UPN = Get-ADForest | Select -ExpandProperty UPNSuffixes 

$UPN | Out-File -FilePath  $ofile