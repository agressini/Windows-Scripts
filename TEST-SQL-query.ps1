$SERVER = "SQL-ATSP-LSTNR1" 
$DBNAME = "master"
$query = "SELECT DB_NAME() AS DatabaseName, DATABASEPROPERTYEX('master', 'Status') AS DBStatus" 
Try 
{ 
$SQLConnection = New-Object System.Data.SQLClient.SQLConnection 
$SQLConnection.ConnectionString ="server=$SERVER;database=$DBNAME;Integrated Security=True;" 
$SQLConnection.Open() 
} 
catch 
{ 
    [System.Windows.Forms.MessageBox]::Show("Failed to connect SQL Server:")  
} 
 
$SQLCommand = New-Object System.Data.SqlClient.SqlCommand 
$SQLCommand.CommandText = $query 
$SQLCommand.Connection = $SQLConnection 
 
$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
$SqlAdapter.SelectCommand = $SQLCommand                  
$SQLDataset = New-Object System.Data.DataSet 
$SqlAdapter.fill($SQLDataset) | out-null 
 
$tablevalue = @() 
foreach ($data in $SQLDataset.tables[0]) 
{ 
    $tablevalue = $data[0] 
    $tablevalue 
}  
$SQLConnection.close()

 