[CmdletBinding()]
param (

    [Parameter(Mandatory=$false,Position=0)]
    [ValidateSet("ReportOnly","Execution")]
    [string]
    $Mode = "ReportOnly",
    [Parameter(Mandatory=$True,Position=1)]
    [string]
    $OU,
    [Parameter(Mandatory=$True,Position=2)]
    [ValidateSet("Administrators","Remote Desktop Users")]
    [string]
    $Group,
    [Parameter(Mandatory=$false,Position=3)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ImportFile
    
)
Write-Host "Seting up Variables..." -ForegroundColor Yellow
$Now = Get-Date
$ExportPath = "$env:USERPROFILE\Desktop\"
$logPath = ($ExportPath + "Get-LocalADMV2-log.txt")
$ReportPath = $ExportPath + "Computers_" +($Now).ToString("yyMMddhhmm") + ".csv"
$LocalAdminsPath = $ExportPath + "LocalAdmins_" +($Now).ToString("yyMMddhhmm") + ".csv"
$LocalAdminsPaths = $ExportPath + "LocalAdmins_old_posh_" +($Now).ToString("yyMMddhhmm") + ".csv"
$Noconectionpath = $ExportPath + "No_connection" +($Now).ToString("yyMMddhhmm") + ".csv"

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

switch ($Mode) {
    "ReportOnly" {

                    Write-Host "Report only mode" -ForegroundColor Cyan | Out-File -Encoding utf8 -FilePath $logPath -Append
                    "Report only mode" | Out-File -Encoding utf8 -FilePath $logPath -Append
                    Try {
                            $Computer = Get-ADComputer -SearchBase $OU -Filter * -Properties Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate | Select-Object Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate | Where-Object {$_.OperatingSystem -match "Windows*"}
                            Write-Host "Cantidad de Computers (incluye sub OUs): " ($Computer | Measure-Object).Count | Out-File -Encoding utf8 -FilePath $logPath -Append
                            "Cantidad de Computers (incluye sub OUs): " + ($Computer | Measure-Object).Count | Out-File -Encoding utf8 -FilePath $logPath -Append
                            $Computer | Export-Csv -Path $ReportPath -NoTypeInformation -Append
                    }
                    Catch {
                            "Error: No se puede leer los objetos en la OU $OUs.CanonicalName" | Out-File -Encoding utf8 -FilePath $logPath -Append
                            Throw (Write-Warning -Message "Verifique los permisos para leer los datos en: " $OUs.DistinguishedName)
                     }
    }

    "Execution" {
                    Write-Host "Execution mode" -ForegroundColor Green
                    "Execution mode" | Out-File -Encoding utf8 -FilePath $logPath -Append

                    Try {
                        If ($ImportFile -ne "")
                        {
                            $Computer = Import-Csv -Path $ImportFile
                        }
                        Else
                        {
                            $Computer = Get-ADComputer -SearchBase $OU -Filter * -Properties Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate | Select-Object Name,IPv4Address,DNSHostName,OperatingSystem,LastLogonDate | Where-Object {$_.OperatingSystem -match "Windows*"}
                            Write-Host "Cantidad de Computers (incluye sub OUs): " ($Computer | Measure-Object).Count | Out-File -Encoding utf8 -FilePath $logPath -Append
                            "Cantidad de Computers (incluye sub OUs): " + ($Computer | Measure-Object).Count | Out-File -Encoding utf8 -FilePath $logPath -Append
                            $Computer | Export-Csv -Path $ReportPath -NoTypeInformation -Append
                        }
                    }
                    Catch {

                            "Error: Courrio algun problema conectando" | Out-File -Encoding utf8 -FilePath $logPath -Append
                            Throw (Write-Warning -Message )

                    }

                    Try{
                        ForEach ($Computers in $Computer) {

                            $fqdn = $Computers.Name
                            Write-Host "conectandose a: $fqdn" | Out-File -Encoding utf8 -FilePath $logPath -Append
                            $conected = (Test-NetConnection -ComputerName $fqdn -CommonTCPPort WINRM)
                            "Server: $fqdn TCP TEST " + $conected.TcpTestSucceeded | Out-File -Encoding utf8 -FilePath $logPath -Append
                            "Server: $fqdn DNS TEST " + $conected.NameResolutionSucceeded | Out-File -Encoding utf8 -FilePath $logPath -Append

                            if ($conected.TcpTestSucceeded -eq $true)
                                {
                                    $version = Invoke-Command -ComputerName $Computers.Name -ScriptBlock {return $PSVersionTable.PSVersion.Major}

                                    if($version -like "5*")
                                        {
                                            Invoke-Command -ComputerName $Computers.Name -ScriptBlock {Get-LocalGroupMember -Group $Using:Group} |  Select-Object "PSComputerName","Name","PrincipalSource","ObjectClass" | Export-CSV $LocalAdminsPath -NoTypeInformation -Append   
                                        }
                                        

                                    if($version -like "2*" -or $version -like "4*")
                                        {
                                            Invoke-Command -ComputerName $Computers.Name -ScriptBlock {
                                                $members = net localgroup administrators | Where-Object {$_ -AND $_ -notmatch "command completed successfully"} | Select-Object -skip 4
                                                $adms = @()
                                                
                                                foreach ($member in $members)
                                                        {
                                                            $adm = New-Object System.Object
                                                            $adm | Add-Member -type NoteProperty -name ComputerName -Value $env:COMPUTERNAME
                                                            $adm | Add-Member -type NoteProperty -name Group -Value "Administrators"
                                                            $adm | Add-Member -type NoteProperty -name Members -Value $member
                                                            $adms += $adm
                                                        }
                                                        Return $adms
                                                            
                                             }|Select-Object Computername,Group,Members| Export-CSV $LocalAdminsPaths -NoTypeInformation -Append
                                        }

                                    "Information collected Using Powershell " + $version + " from Server: $fqdn" | Out-File -Encoding utf8 -FilePath $logPath -Append
        
                                }
                                else
                                    {
                                        "Information NOT collected from Server: $fqdn due to connection issues" | Out-File -Encoding utf8 -FilePath $logPath -Append
                                        $Computers | Export-CSV $Noconectionpath -NoTypeInformation -Append
                                    }
                        }
                   

                    }
                    Catch{
                            "Error: Courrio algun problema conectando WinRM. Server: $fqdn. Resultado $conected" | Out-File -Encoding utf8 -FilePath $logPath -Append
                            Throw (Write-Error -Message "No pudimos conectar con un servidor $fqdn. $conected")
                    }

    }
    Default {}
}

$Now = Get-Date
Write-Host "closing Log..." -ForegroundColor Yellow
"Closed Log at " + $env:COMPUTERNAME + " Ending date/time " + $Now | Out-File -Encoding utf8 -FilePath $logPath -Append