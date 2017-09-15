# ref: https://docs.microsoft.com/en-us/iis/install/installing-iis-85/installing-iis-85-on-windows-server-2012-r2
Set-ExecutionPolicy Unrestricted
import-module servermanager
add-windowsfeature web-server -includeallsubfeature
