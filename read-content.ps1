Set-Location C:\ESD\LoginScripts\
$archivos = Get-ChildItem -Path C:\ESD\LoginScripts\*.* -Recurse -Exclude "*.exe"

     foreach($archivo in $archivos)
     {
        $linea = Get-Content -Path $archivo.PSPath| Select-String -Pattern "\.ini"
        if ($linea)
        {   
            $index = 0
            $salida = ""
            $salida = $archivo.FullName + " contiene: `r`n" 
            $linea.Matches | ForEach-Object {
                $salida += $linea[$index].Line
                $salida += "`r`n"
                $index +=1
            }
            $salida |  Out-File -FilePath .\todoslosini.txt -Append
        }
     }   