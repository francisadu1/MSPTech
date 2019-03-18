$PrimaryURL = "https://www.systemmonitor.co.uk/api/?apikey=2862e0ae216858e74ae8f2f03d788bb4"
$ClientUrl = $PrimaryURL + "&service=list_clients"

[xml]$ClientXML = (New-Object System.Net.WebClient).DownloadString($ClientUrl)
$ClientIDs = $ClientXML.result.items.client | Select-Object @{name = "Name"; Expression = {$_.name.innertext}}, clientid | Sort-Object Name
