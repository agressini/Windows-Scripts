$clusterNodes = Get-ClusterNode;
ForEach($item in $clusterNodes)
{Get-VM -ComputerName $item.Name | Select Name,{$_.MemoryAssigned/1Gb},ProcessorCount; }