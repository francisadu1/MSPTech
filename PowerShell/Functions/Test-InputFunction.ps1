
#To validate PostalCode - 99999

Function Test-PostalCode
{
 Param([Parameter(Mandatory=$true,HelpMessage="Enter a valid Postal Code xxx-xxx-xxxx")][ValidatePattern("[0-9][0-9][0-9][0-9]")]$PostalCode)
 Write-host "The Pin Code $PostalCode is valid"
}

Test-PostalCode
 

#To Validate phone number -  999-999-9999

Function Test-PhoneNumber
{
 Param([ValidatePattern("\d{3}-\d{3}-\d{4}")]$Number)
  Write-host "The phone number $Number is valid"
}

Test-PhoneNumber -Number 999-999-9999


#To Validate email address

function Test-Email ([string]$Email)
{
  return $Email -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$"
} 

 #To Validate IP Range - 255.255.255.255 
 
 function Test-IPAddress ([string]$IP)
 {
 if($IP -match "(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})" -and -not ([int[]]$matches[1..4] -gt 255))
 {
   Write-host "The $IP IP is valid"
 }
 }

#To Validate the filename for ########_???_?.jpg pattern



function Test-Filename ([string]$TestPattern = ("[^[\w[\`\'\˜\=\+\#\ˆ\@\$\&\-\_\.\(\)\{\}\;\[\]]]].jpg"))

}
Param([ValidatePattern('$TestPattern'))])$filename
Write-host "The filename $filename is valid" 
}

