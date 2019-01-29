cd "C:\Users\Antonino Gressini\Desktop\AXA"

Get-ChildItem -Recurse -Include "Ping*.csv" | foreach {
Write-host $_.FullName
Get-Content $_.FullName  -wait | where { $_ -match "False" }
} 