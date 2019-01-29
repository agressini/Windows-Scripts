$nodes = Get-ClusterNode
$reporte = "Fecha,ComputerName,ResolvedAddresses,PingSucceeded,NameResolutionSucceededn`n"
$fechaf = (Get-date).AddMinutes(1)
$path = $env:USERPROFILE + '\Desktop\pings_' + (Get-Date).Month + '.csv'

$reporte | Out-File $path 

do{
    foreach ($node in $nodes)
    {
        $currentdate = Get-Date
        #Test-Connection $node
        $test = Test-NetConnection $node
        $reporte = $currentdate.ToString('yyyy-MM-dd HH:mm:ss') +","+$test.ComputerName+","+$test.ResolvedAddresses+","+$test.PingSucceeded+","+$test.NameResolutionSucceeded+"`n"
        $reporte.ToString() |Out-File $path -Append
    }
}while ($currentdate -le $fechaf)
