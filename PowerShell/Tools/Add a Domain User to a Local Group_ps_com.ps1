# Add a domain user to a local group on the local or a remote computer

$computerName = Read-Host 'Enter computer name or press <Enter> for localhost'
$userName = Read-Host 'Enter user name'
$localGroupName = Read-Host 'Enter local group name'

if ($computerName -eq "") {$computerName = "$env:computername"}
[string]$domainName = ([ADSI]'').name
([ADSI]"WinNT://$computerName/$localGroupName,group").Add("WinNT://$domainName/$userName")

Write-Host "User $domainName\$userName is now member of local group $localGroupName on $computerName."