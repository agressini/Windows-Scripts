$computers = @("CWPI-SQL-PCI-CL","CWPI-SQL-PCI-01","CWPI-SQL-PCI-02","DWPI-SQL-PCI-01","SQL-API-AG","CWPI-ALL-SQL-01", "CWPI-ALL-SQL-02","DWPI-ALL-SQL-01""CWPI-SQL-SIA8-CL","CWPI-SQL-SIA-04","CWPI-SQL-SIA-05","DWPI-SQL-SIA-02","CWPI-SQL-SIA-CL","CWPI-SQL-SIA-01","CWPI-SQL-SIA-02","DWPI-SQL-SIA-01")
$reporte = "Fecha,ComputerName,ResolvedAddresses,PingSucceeded,NameResolutionSucceededn`n"
$fechaf = (Get-date).AddMinutes(1)
$path = $env:USERPROFILE + '\Desktop\pingsSQL_' + (Get-Date).Month + '.csv'

$reporte | Out-File $path 

do{
    foreach ($computer in $computers)
    {
        $currentdate = Get-Date
        $test = Test-NetConnection $computer
        $reporte = $currentdate.ToString('yyyy-MM-dd HH:mm:ss') +","+$test.ComputerName+","+$test.ResolvedAddresses+","+$test.PingSucceeded+","+$test.NameResolutionSucceeded+"`n"
        $reporte.ToString() |Out-File $path -Append
    }
}while ($currentdate -le $fechaf)

