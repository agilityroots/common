<#
.SYNOPSIS
Programmatic Installation of Octopus Deploy
.DESCRIPTION
Assuming SQL Server is already present, you can use this script to silently install Octopus Deploy.
.PARAMETER AdminEmail
Email Address of your desired administrator.
.PARAMETER AdminPassword
Strong Password for your admin account. (Username is 'admin')
.PARAMETER LicBase64
Convert your license string to Base64, then pass it as a parameter here.
.EXAMPLE
.\installOctopusDeploy.ps1 -AdminEmail my@email.com -AdminPassword my@5trongPwd -LicBase64 ConvertYourLicenseStringToBase64AndPaste
.NOTES
For security, do not pass parameters in directly. Store the parameters in your environment and read them when calling this script. 

Assumes SQL Server 2014 Express already installed.
#>
param(
    [Parameter(Mandatory=$True,HelpMessage="Valid Email Address for admin user.")]
    [STRING]$AdminEmail,
    [Parameter(Mandatory=$True,HelpMessage="Password for admin user. Must contain lower/upper/numeric/special characters.")]
    [STRING]$AdminPassword,
    [Parameter(Mandatory=$True,HelpMessage="Base-64 encoded Octopus license string")]
    [STRING]$LicBase64
)

$ErrorActionPreference = "Stop"
$targetPath="C:\Temp\Octopus.msi";
$installPath="C:\Octopus\";
$octopusInstallUrl="https://download.octopusdeploy.com/octopus/Octopus.3.17.1-x64.msi";
$octoServer = "C:\Octopus\Octopus.Server.exe"
$octoConfig = "C:\Octopus\OctopusServer.config"
$octoDB = "foo"

mkdir "C:\Temp" -ErrorAction SilentlyContinue

if (!(Test-Path $targetPath)) {
  Invoke-WebRequest -Uri "$octopusInstallUrl" -OutFile $targetPath;
} else {
  Write-Host "Installer already downloaded";
}
Write-Host "Beginning Install";
Start-Process msiexec.exe -Wait -ArgumentList "/i $targetPath /quiet RUNMANAGERONEXIT=no INSTALLLOCATION=`"$installPath`"";

# Set environment corresponding to Octopus Credentials on the server
# TODO This step is not necessary
[Environment]::SetEnvironmentVariable("OCTOPUS_ADMIN_PASSWORD", "$AdminPassword", "Machine")
[Environment]::SetEnvironmentVariable("OCTOPUS_LICENSE_BASE64", "$LicBase64", "Machine")


# OCTOPUS_ADMIN_PASSWORD
# OCTOPUS_LICENSE_BASE64
& "$octoServer" create-instance --instance "OctopusServer" --config "$octoConfig"
& "$octoServer" database --instance "OctopusServer" --connectionString "Data Source=(local)\SQLEXPRESS;Initial Catalog=$octoDB;Integrated Security=True" --create --grant "NT AUTHORITY\SYSTEM"
& "$octoServer" configure --instance "OctopusServer" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "WIN-BI6QQBJBB5S"
& "$octoServer" service --instance "OctopusServer" --stop
& "$octoServer" admin --instance "OctopusServer" --username "admin" --email "$AdminEmail" --password "$AdminPassword"
& "$octoServer" license --instance "OctopusServer" --licenseBase64 $LicBase64

& "$octoServer" service --instance "OctopusServer" --install --reconfigure --start --dependOn 'MSSQL$SQLEXPRESS'
