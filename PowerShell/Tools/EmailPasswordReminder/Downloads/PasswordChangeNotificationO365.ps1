#################################################################################################################
# 
# Version 1.0 September 2016
# Fernando Pérez 
# Based on Robert Pearman (WSSMB MVP)
# 
# Script to Automated Email using Office 365 account to remind users Passwords Expiracy.
# Office 365 require SSL
# Requires: Windows PowerShell Module for Active Directory
#
#
##################################################################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com" # Office 365 official smtp server
$expireindays = 10 # number of days for password to expire 
$from = "Your email address <youremail@domain.com>" # email from 
$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "c:\Scripts\PasswordChangeNotification.csv" # ie. c:\Scripts\PasswordChangeNotification.csv
$testing = "Disabled" # Set to Disabled to Email Users
$testRecipient = "yourtestrecipient@domain.com" 
$date = Get-Date -format ddMMyyyy
#
###################################################################################################################

# Add EMAIL Function
Function EMAIL{

	Param(
		$emailSmtpServer = $smtpServer,   #change to your SMTP server
		$emailSmtpServerPort = 587,
		$emailSmtpUser = "username@domain.com",   #Email account you want to send from
		$emailSmtpPass = "passsword",   #Password for Send from email account
		$emailFrom = "emailfromaddress@domain.com",   #Email account you want to send from
		$emailTo,
		$emailAttachment,
		$emailSubject,
		$emailBody
	)
	Process{
	
	$emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
	$emailMessage.Subject = $emailSubject
	$emailMessage.IsBodyHtml = $true
	$emailMessage.Priority = [System.Net.Mail.MailPriority]::High
	$emailMessage.Body = $emailBody
 
	$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
	$SMTPClient.EnableSsl = $true
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
	$SMTPClient.Send( $emailMessage )
	}
}

# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn"
    }
} # End Logging Check

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.Name
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }
  
    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
        
    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -ge "1")
    {
        $messageDays = "in " + "$daystoexpire" + " days."
    }
    else
    {
        $messageDays = "today."
    }

    # Email Subject Set Here
    $subject="Your password will expire $messageDays"
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="    
	<p>Dear $name,<br></P><br>
    <p>Your Password will expire $messageDays.<br>
    Please change your password before it expires to avoid problems accessing to your work services. <br></P><br>
    <p>Thanks, <br> 
    </P><br><br>
    <p>Dear $name,<br></P><br>
    <P>Su contrase&ntilde;a caducar&aacute; en $daystoExpire d&iacute;as.<br>
    Por favor cambie su contrase&ntilde;a antes de que &eacute;sta expire para evitar problemas al acceder a su entorno de trabajo. <br></P><br>
    <P>Gracias, <br> 
    </P><br><br>
	<p>Caro $name,<br></P><br>
    <p>A sua password vai expirar dentro de $daystoExpire dias<br>
    Por favor altere a mesma antes dela expirar de forma a evitar ter problemas de acesso ao seu ambiente de trabalho. <br></P><br>
    <p>Obrigado, <br> 
    </P>"

   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = "youremailaddress@domain.com"    
    }# End No Valid Email

    # Send Email Message
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
    {
         # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson" 
        }

		EMAIL -emailTo $emailaddress -emailSubject $subject -emailBody $body

    } # End Send Message
    
} # End User Processing



# End