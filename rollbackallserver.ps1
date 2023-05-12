Add-Type -AssemblyName System.Configuration
Add-Type -AssemblyName System.Web

$sqlfilename = "Rollback%20OIDC.sql"
$source = 'http://update.csid.be/Gupdate/Download/' + $sqlfilename
$queryFilepath = $PSScriptRoot + "\" + $sqlfilename
$logFilepath = $PSScriptRoot + "\result.log"

if ([System.IO.File]::Exists($logFilepath)) 
{
    del $logFilepath
}

if ([System.IO.File]::Exists($queryFilepath)) 
{
    del $queryFilepath
}

try
{
    Invoke-WebRequest -Uri $source -OutFile $queryFilepath
}
catch 
{
    echo "Telechargement impossible"
}


if ([System.IO.File]::Exists($queryFilepath))
{
	try
	{
		$config = [System.Web.Configuration.WebConfigurationManager]::OpenWebConfiguration("/inot.be")
		$connectionString = $config.ConnectionStrings.ConnectionStrings.Item('DEFAULT').ConnectionString

		$SqlBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($connectionString)

		sqlcmd -x -d $SqlBuilder.InitialCatalog -i $queryFilepath -S $SqlBuilder.DataSource -U $SqlBuilder.UserID -P $SqlBuilder.Password -o $logFilepath
		$file_data = Get-Content $logFilepath
		echo $file_data
	}
	catch 
	{
		echo "Une erreur est survenue lors de MAJ DB"
	}
}
