On Error Resume Next
Set objUser = GetObject _
  ("LDAP://siteempresas.bancosantafe.com.ar/ DC=siteempresas,DC=bancosantafe,DC=com,DC=ar")

objUser.GetInfo

strMail = objUser.Get("mail")

WScript.echo "mail: " & strMail 