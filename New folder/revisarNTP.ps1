$path = "$env:USERPROFILE\Desktop\NTP_cencosud.csv"

$csv = "Hostname," + "Source," + "Type," + "NTPServer"+"`n"

Get-ChildItem -Path "C:\Users\Antonino Gressini\Documents\CENCOSUD\CENCOSUD\Relevamiento\Relevamiento_22-11\NTP_ALL_DC"  | ForEach-Object {
$csv += (Get-Content $_.FullName)[0]+"," + (Get-Content $_.FullName)[8]+"," + (Get-Content $_.FullName)[46]+"," + (Get-Content $_.FullName)[47]+","+"`n"
}

$csv | Out-File  -FilePath $path

