# Liste des OS autorisés
$AllowedOsVersions = @("Windows Server 2012", "Windows Server 2012 R2", "Windows Server 2008", "Windows Server 2008 R2", "Windows Small Business Server 2011", "Microsoft Windows Server 2012 R2 Essentials", "Microsoft Windows Server 2012 R2 Standard", "Microsoft Windows Server 2012 Standard", "Microsoft Windows Server 2008 R2 Standard", "Microsoft Windows  Small Business Server 2011 Standard"  )

# Récupération de la version de l'OS
$OsVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption

# Vérification si l'OS est autorisé
if ($AllowedOsVersions -contains $OsVersion) {
   
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
}
else {
    Write-Host "Le script ne peut pas s'executer sur l'OS $OsVersion"
}
