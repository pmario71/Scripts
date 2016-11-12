# Link to source information
# https://blog.doenselmann.com/proxy-settings-mit-powershell-konfigurieren/
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$todo = Get-ItemProperty -Path $path -Name ProxyEnable

if ($todo -eq '1') {
    Write-Host "Proxy is enabled  -->  disabling"
    Set-ItemProperty -Path $path -Name ProxyEnable -Value 0
}
else {
    Write-Host "Proxy is disabled  -->  enabling"
    Set-ItemProperty -Path $path -Name ProxyEnable -Value 1
}