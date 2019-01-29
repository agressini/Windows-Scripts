$headers = @{}
$headers.Add("Server", "Server1")
$headers.Add("Authorization", "Basic Administrator MyPassword!")
Invoke-RestMethod -Method GET -Headers $headers -Uri http://Server1/RestService/rest.svc/pools
new-aduser