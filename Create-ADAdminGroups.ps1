param (
    [string]$pathServers="",
    [string]$OU=""
)

$descriptionA = "Creado el " + (Get-Date).DateTime + " - Grupo de administradores de: "
$descriptionO = "Creado el " + (Get-Date).DateTime + " - Grupo de operadores de: "  

Import-Csv -Path $pathServers -Delimiter ";" | ForEach-Object{

    if (Get-ADGroup -Identity $_.Groupadmin)
    {Write-Host $_.Groupadmin " ya Existe"}
    else
    {
    $descA = $descriptionA + $_.Servername

    New-ADGroup -Name $_.Groupadmin -SamAccountName $_.Groupadmin -GroupCategory Security -GroupScope Global -DisplayName $_.Groupadmin  -Path $OU -Description $descA
    }

    if (Get-ADGroup -Identity $_.Groupops)
    {Write-Host $_.Groupops " ya Existe"}
    else
    {
    $descO = $descriptionO + $_.Servername

    New-ADGroup -Name $_.Groupops -SamAccountName $_.Groupops -GroupCategory Security -GroupScope Global -DisplayName $_.Groupops -Path $OU -Description $descO
    }
}


