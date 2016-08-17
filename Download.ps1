$url = "http://www.powershell-doktor.de"
$datei = "d:\Download.htm"

write-host "Laden beginnen ..."

try
{
$wc = (new-object System.Net.WebClient)
$html = $wc.DownloadString($url)

"Speichere Datei"

$html | Set-Content -path $datei
}
catch [System.Exception] 
{
  write-warning "Fehler beim Laden: " + $_.Exception.Message
}