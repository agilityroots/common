About the Scripts
=================

## [installIIS.ps1](installIIS.ps1)

[reference](https://docs.microsoft.com/en-us/iis/install/installing-iis-85/installing-iis-85-on-windows-server-2012-r2)

* Performs a silent install of Internet Information Services (boils down to enabling a Windows Feature). 
* By default all subfeatures of IIS are enabled.

## [installOctopusDeploy.ps1](installOctopusDeploy.ps1)

* Downloads, Installs and Configures Octopus Deploy. 
* This is a parameterized script with the ability to add a license as well as configure an initial Admin User.
* The script assumes SQL Server to be installed locally. Tested with SQL Server Express 2014 installed using Chocolatey.
