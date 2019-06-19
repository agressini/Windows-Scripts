param (

    [string]$Path = "",
    [string]$Searchbase = ""   
    
)
$Path2 = $Path + "Log_crear_grupos.csv"
$Path3 = $Path + "Servidores.csv"
$Server = Import-Csv -Path $Path3 -Delimiter ";"
$csv = "Name;Grupo;OU`n" | Out-file -Append -FilePath $Path2 | Out-Null

Foreach ($Servers in $Server) 
{
    $gname = $servers.Name + "_ServerOperators"
    $gsama = $gname.Replace("_","")
    $gdesc = "Administradores del Servidor: " + $Servers.Name
    New-ADGroup -Name $gname -SamAccountName $gname -GroupCategory Security -GroupScope Global -DisplayName $gname -Path $Searchbase -Description $gdesc
    Get-ADGroup -Identity SYS_AD_ServerOperators |  Add-ADPrincipalGroupMembership -MemberOf $gname
    $csv = $servers.Name + ";" + $gname + ";" + $Searchbase  
    $csv | Out-file -Append -FilePath $Path2
}