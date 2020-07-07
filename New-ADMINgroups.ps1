param (
    [Parameter(Mandatory=$false,Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ImportFile,

    [Parameter(Mandatory=$True,Position=1)]
    [string]
    $OU,

    [Parameter(Mandatory=$True,Position=2)]
    [string]
    $Sufijo = "_LOCAL Admin",
    
    [Parameter(Mandatory=$True,Position=2)]
    [string]
    $Description = "Administradores locales"
)
Write-Host "Seting up Variables..." -ForegroundColor Yellow
$Now = Get-Date
$ExportPath = "$env:USERPROFILE\Desktop\"
$logPath = ($ExportPath + "New-LocalADM-Group-log.txt")
$ReportPath = $ExportPath + "LocalADM-Group_" +($Now).ToString("yyMMddhhmm") + ".csv"

Write-Host "Starting log..." -ForegroundColor Yellow
"Starting Log at " + $env:COMPUTERNAME + " Starting date/time " + $Now | Out-File -Encoding utf8 -FilePath $logPath -Append

Try {$OUs = Get-ADOrganizationalUnit -Identity $OU -Properties * -ErrorAction Stop
    "Distinguished name valido: $OU" | Out-File -Encoding utf8 -FilePath $logPath -Append
    Write-Host "Target OU: " $OUs.CanonicalName
    }

Catch {"Error: el valor $OU. no es valido" | Out-File -Encoding utf8 -FilePath $logPath -Append
    Throw (Write-Warning -Message "La ou no puede ser procesada, proporcione un Distinguished Name valido por Ej. OU=Servers,DC=secure-demos,DC=algeiba,DC=com")
    }

    Try {
        switch ($ImportFile) {
            "*" {
                Write-Host "Computers imported from: "$ImportFile
                "Archivo encontrado: $ImportFile" | Out-File -Encoding utf8 -FilePath $logPath -Append
            }
            "" {
                "Información: no se importo el archivo" | Out-File -Encoding utf8 -FilePath $logPath -Append
                Write-Host "Information: no file to import"
            }
            Default {}
        }
            
        
}

Catch {
    "Error: el archivo $ImportFile. no existe" | Out-File -Encoding utf8 -FilePath $logPath -Append
    Throw (Write-Warning -Message "El archivo no existe, provea un archivo compatible para la importación en CSV y con los campos Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate")
}

Write-Host "Todos las salidas como log y reporte van guardarse en: " $ExportPath
"Todos las salidas como log y reporte van guardarse en: " + $ExportPath | Out-File -Encoding utf8 -FilePath $logPath -Append

Write-Host "Importando datos" -ForegroundColor Green

Try {
    If ($ImportFile -ne "")
    {
        $Server = Import-Csv -Path $ImportFile -Delimiter ";"
    }
   
}
Catch {

        "Error: Courrio algun problema conectando" | Out-File -Encoding utf8 -FilePath $logPath -Append
        Throw (Write-Warning -Message )
}


Write-Host "Creando Archivo de salida: " $ExportPath -ForegroundColor Green
"Creando Archivo de salida: " + $ExportPath | Out-File -Encoding utf8 -FilePath $logPath -Append
$csv = "Name;Grupo;OU`n" | Out-file -Append -FilePath $ReportPath | Out-Null

Foreach ($Servers in $Server) 
{
    $gname = $servers.Name + $Sufijo
    #$gsama = $gname.Replace("_","")
    $gdesc = $Description + "`n Servidor: " + $Servers.Name

    Write-Host "Creando grupo: " $gname -ForegroundColor Green
    "Creando grupo: " + $gname | Out-File -Encoding utf8 -FilePath $logPath -Append
    
    New-ADGroup -Name $gname -SamAccountName $gname -GroupCategory Security -GroupScope Global -DisplayName $gname -Path $OU -Description $gdesc
    
    Write-Host "Agregando SYS_AD_ServerOperators como miembro" -ForegroundColor Green
    "Agregando SYS_AD_ServerOperators como miembro" | Out-File -Encoding utf8 -FilePath $logPath -Append
    
    Get-ADGroup -Identity SYS_AD_ServerOperators |  Add-ADPrincipalGroupMembership -MemberOf $gname
    $csv = $servers.Name + ";" + $gname + ";" + $OU  
    $csv | Out-file -Append -FilePath $ReportPath

    Write-Host "Finalizo la creacion del grupo: " $gname -ForegroundColor Green
    "Finalizo la creacion del grupo: " + $gname | Out-File -Encoding utf8 -FilePath $logPath -Append
    

}