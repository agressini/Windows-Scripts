$Server = Read-Host "Enter the UNC Name of the remote server to speedtest"
	$Source = pwd
	$Size = 20
	$Source=$Source.Path
    Remove-Item $Source\Local-Speedtest.txt -ErrorAction SilentlyContinue
    Set-Location $Source
    $DummySize = $Size * 1048576
    $CreateMsg = fsutil file createnew Local-Speedtest.txt $DummySize

        $TotalSize = (Get-ChildItem $Source\Local-Speedtest.txt -ErrorAction Stop).Length

        $Target = "\\$Server\c$\SpeedTest"        
        If (Test-Path $Target){
                New-Item -Path $Target -ItemType Directory -ErrorAction Stop | Out-Null
                
        Try {
            $WriteTest = Measure-Command { 
                Copy-Item $Source\Local-Speedtest.txt $Target -ErrorAction Stop
            }
            
            $ReadTest = Measure-Command {
                Copy-Item $Target\Local-Speedtest.txt $Source\TestRead.txt -ErrorAction Stop
            }
            $Status = "OK"
            $WriteMbps = [Math]::Round((($TotalSize * 8) / $WriteTest.TotalSeconds) / 1048576,2)
            $ReadMbps = [Math]::Round((($TotalSize * 8) / $ReadTest.TotalSeconds) / 1048576,2)
        }
        Catch {
            Write-Warning "Problem during speed test: $($Error[0])"
            $Status = "$($Error[0])"
            $WriteMbps = $ReadMbps = 0
            $WriteTest = $ReadTest = New-TimeSpan -Days 0
        }
        
        Write-host "Server = $Server `nStatus = "OK" `nWriteMbps = $WriteMbps `nReadMbps = $ReadMbps"
        }
		Write-host "Server = $Server `n Status = "OK" `n WriteMbps = $WriteMbps `n ReadMbps = $ReadMbps"
        Remove-item -recurse $Target\Local-Speedtest.txt -ErrorAction SilentlyContinue -confirm:$false -force
        Remove-item -recurse $Source\TestRead.txt -ErrorAction SilentlyContinue -confirm:$false -force