##VARIABLES
$path = "$env:SystemDrive\PFScripts\"
$date = (Get-Date).ToString('MMddyyyyHHmm')
$ofile = "$date" + "_sync_summary.csv"

#VERIFICACION DE RUTA
If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}
else
{
    Set-Location -Path $path
    Sync-MailPublicFolders.ps1 -Credential (Get-Credential) -CsvSummaryFile:$ofile
}

##Mantenimiento

Get-ChildItem -Path $path  | Where-Object {$_.LastWriteTime -lt (get-date).AddDays(-15)} | 
    move-item -destination "F:\target"

