<#
Script Name   : Microsoft.PowerShellISE_profile.ps1
Author        : Luke Leigh
Created       : 16/03/2019
Notes         : This script has been created in order pre-configure the following setting:-
- Shell Title - Rebranded
- Shell Dimensions configured to 150 Width x 45 Height
- Buffer configured to 9000 lines
- Creates GitHub Local Repository PSDrives and Onedrive PSDrives
EG
Name                  Root
----                  ----
blogsite              C:\GitRepos\blogsite
CiscoMeraki           C:\GitRepos\CiscoMeraki
MSPTech               C:\GitRepos\MSPTech
OneDrive              C:\Users\Luke\OneDrive
PowerRepo             C:\GitRepos\PowerRepo

- Sets starting file path to Scripts folder on ScriptsDrive
- Loads Several Functions
	CommandType     Name
	-----------     ----
	Function        Get-Appointments
	Function        Get-Password
	Function        Get-PatchTue
	Function        Get-ScriptDirectory
	Function        LoadProfile
	Function        New-Greeting
	Function        New-ObjectToHashTable
	Function        Save-Password
	Function        Select-FolderLocation
	Function        Stop-Outlook
	Function        Test-IsAdmin

- Display whether or not running as Administrator in the WindowTitle
- Clears the display

- Display Date and Time in the Console Windows
- Script Greeting based on day of week
- Display whether or not running as Administrator in the Console Window

When run from Elevated Prompt
- Preconfigures Executionpolicy settings per PowerShell Process Unrestricted
(un-necessary to configure execution policy manually
each new PowerShell session, is configured at run and disposed of on exit)
- Amend PSModulePath variable to include 'OneDrive\PowerShellModules'
- Configure LocalHost TrustedHosts value

- Measures script running performance and displays time upon completion

#>

# Start
$Stopwatch = [system.diagnostics.stopwatch]::startNew()

# Configure PSDrives

$DriveRoot = "$env:HOMEDRIVE\"
$Git = "$DriveRoot\GitRepos\"
$GitExist = Test-Path -Path "$Git"
if ($GitExist = $true) {
	$PSDrivePaths = Get-ChildItem -Path "$Git\"
    foreach ($item in $PSDrivePaths) {
		$paths = Test-Path -Path $item.FullName
        if ($paths = $true) {
			New-PSDrive -Name $item.Name -PSProvider "FileSystem" -Root $item.FullName
		}
	}
	$PersonalOneDrive = $env:OneDriveConsumer
	$OneDriveConsumer = Test-Path -Path $PersonalOneDrive
	if ($OneDriveConsumer = $true) {
		New-PSDrive -Name "OneDrive" -PSProvider "FileSystem" -Root $PersonalOneDrive
	}
	$CompanyOneDrive = $env:OneDriveCommercial
	$OneDriveCommercial = Test-Path -Path $CompanyOneDrive
	if ($OneDriveCommercial = $true) {
		New-PSDrive -Name "OneDriveBusiness" -PSProvider "FileSystem" -Root $CompanyOneDrive
	}
	Set-Location -Path PowerShellScripts:
}


# Personal Alias List
New-Alias -Name "np" -Value "C:\WINDOWS\system32\notepad.exe"
New-Alias -Name "n+" -Value "C:\Program Files\Notepad++\notepad++.exe"
New-Alias -Name "VSCode" -Value "C:\Users\Luke\AppData\Local\Programs\Microsoft VS Code\Code.exe"
New-Alias -Name "Stop-Torrents" -Value "Personal:\Documents\TransmissionCleaner\TransmissionCleaner.exe"
New-Alias -Name "LazyWinAdmin" -Value ".\LazyWinAdmin-v0.4\LazyWinAdmin.ps1"
New-Alias -Name "Get-Uptime" -Value ".\PowerShell\Tools\Get-Uptime.ps1"

# Script Functions
function Stop-Outlook {
	$OutlookRunning = Get-Process -ProcessName "Outlook"
	if ($OutlookRunning = $true) {
		Stop-Process -ProcessName Outlook
	}
}

function Get-Appointments {
	$OutlookAppointments = .\ProfileFunctions\Get-OutlookAppointments.ps1

	Write-Host "--------------------------------------------------------------------------------"
	$OutlookAppointments
	Write-Host "--------------------------------------------------------------------------------"
}

function New-Greeting {
	$Today = $(Get-Date)
	Write-Host "   Day of Week  -"$Today.DayOfWeek " - Today's Date -"$Today.ToShortDateString() "- Current Time -"$Today.ToShortTimeString()
	Switch ($Today.dayofweek)
	{
		Monday { Write-host "   Don't want to work today" }
		Friday { Write-host "   Almost the weekend" }
		Saturday { Write-host "   Everyone loves a Saturday ;-)" }
		Sunday { Write-host "   A good day to rest, or so I hear." }
		Default { Write-host "   Business as usual." }
	}
}

function Test-IsAdmin {
	<#
	.Synopsis
	Tests if the user is an administrator

	.Description
	Returns true if a user is an administrator, false if the user is not an administrator

	.Example
	Test-IsAdmin
	#>

	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object Security.Principal.WindowsPrincipal $identity
}

function Get-ScriptDirectory {
	Split-Path -Parent $PSCommandPath
}

function LoadProfile {
	@(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
		) |
		ForEach-Object {
			if(Test-Path $_){
				Write-Verbose "Running $_"
				. $_
			}
		}
	}

function New-ObjectToHashTable {
	param
	(
		[Parameter(Mandatory ,ValueFromPipeline)]
		$object
		)
		process
		{
			$object |
			Get-Member -MemberType *Property |
			Select-Object -ExpandProperty Name |
			Sort-Object |
			ForEach-Object { [PSCustomObject ]@{
				Item = $_
				Value = $object. $_
			}
		}
	}
}

function Get-PatchTue {
	<#
	.SYNOPSIS
	Get the Patch Tuesday of a month
	.PARAMETER month
	The month to check
	.PARAMETER year
	The year to check
	.EXAMPLE
	Get-PatchTue -month 6 -year 2015
	.EXAMPLE
	Get-PatchTue June 2015
	#>
	param(
		[string]$month = (get-date).month,
		[string]$year = (get-date).year
		)
		$firstdayofmonth = [datetime] ([string]$month + "/1/" + [string]$year)
		(0..30 | ForEach-Object {
			$firstdayofmonth.adddays($_)
		} |
		Where-Object {
			$_.dayofweek -like "Tue*"
		})[1]
	}


	function Select-FolderLocation {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "C:\"
    $browse.ShowNewFolderButton = $true
    $browse.Description = "Select Source Directory"

    $loop = $true
    while ($loop) {
        if ($browse.ShowDialog() -eq "OK") {
            $loop = $false
        }
        else {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if ($res -eq "Cancel") {
                #Ends script
                return
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
}


$FolderLocation = Select-FolderLocation
if (![string]::IsNullOrEmpty($ReferenceFolder)) {
    Write-Host "You selected the directory: $FolderLocation"
}
else {
    "You did not select a directory."
}

function Save-Password {
	<# Example

	.EXAMPLE
	Save-Password -Label UserName

	.EXAMPLE
	Save-Password -Label Password

	#>
	param([Parameter(Mandatory)]
	[string]$Label)
	$securePassword = Read-host -Prompt 'Input password' -AsSecureString | ConvertFrom-SecureString
	$directoryPath = Select-FolderLocation
	if (![string]::IsNullOrEmpty($directoryPath)) {
		Write-Host "You selected the directory: $directoryPath"
	}
	else {
		"You did not select a directory."
	}
	$securePassword | Out-File -FilePath "$directoryPath\$Label.txt"
}

function Get-Password {
	<#
	.EXAMPLE
	$user = Get-Password -Label UserName
	$pass = Get-Password -Label password

	.OUTPUTS
	$user | Format-List

	.OUTPUTS
	Label           : UserName
	EncryptedString : domain\administrator

	.OUTPUTS
	$pass | Format-List
	Label           : password
	EncryptedString : SomeSecretPassword

	.OUTPUTS
	$user.EncryptedString
	domain\administrator

	.OUTPUTS
	$pass.EncryptedString
	SomeSecretPassword

	#>
	param(
		[Parameter(Mandatory)]
		[string]$Label
		)
		$filePath = "C:\MyPasswords\$Label.txt"
		if (-not (Test-Path -Path $filePath)) {
			throw "The password with Label [$($Label)] was not found!"
		}

		$password = Get-Content -Path $filePath | ConvertTo-SecureString
		$decPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
		[pscustomobject]@{
			Label = $Label
			EncryptedString = $decPassword
		}
	}

	#--------------------
	# Configure $PSModulePath variable
	(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	[Environment]::GetEnvironmentVariable("PSModulePath")
	$p = [Environment]::GetEnvironmentVariable("PSModulePath")
	$ModuleDrive = Join-Path -Resolve -Path "$PersonalOneDrive" -ChildPath .\Documents\WindowsPowerShell\Modules
	$p += ";$ModuleDrive"
	[Environment]::SetEnvironmentVariable("PSModulePath",$p)

	#--------------------
	# Display running as Administrator in WindowTitle
	if(Test-IsAdmin) {
		# Configure Execution Policy
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

		#--------------------
		# Update PowerShell Help
		$PatchTue = Get-PatchTue -month (Get-Date).Month -year (Get-Date).Year
		if ((get-date).ToShortDateString() = ($PatchTue).ToShortDateString()) {
			Update-Help -Force
		}

		#--------------------
		# Configure LocalHost TrustedHosts value for remote WMI access over http/https
		$TrustedHosts = Get-Item WSMAN:\localhost\Client\TrustedHosts |
		Select-Object -Property *
		if ($TrustedHosts.Value = $false) {
			Set-Item WSMAN:\localhost\Client\TrustedHosts -value *
		}
		$host.UI.RawUI.WindowTitle = "$($env:USERNAME) Elevated Shell"
	}
else
{
	$host.UI.RawUI.WindowTitle = "$($env:USERNAME) Non-elevated Shell"
}

#--------------------
# Configure Shell Default Parameters
$console = $host.UI.RawUI

$buffer = $console.BufferSize
$buffer.Width = 150
$buffer.Height = 9000
$console.BufferSize = $buffer

$size = $console.WindowSize
$size.Width = 150
$size.Height = 45
$console.WindowSize = $size

#--------------------
# Fresh Start
# Clear-Host

#--------------------
# Display Banner for Personal Profile
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "-------------------- All personalisations have been loaded ---------------------" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow

#--------------------
# Greeting based on day of week
New-Greeting


#--------------------
# Display time and Stop the timer
Write-Host "Personal Profile took" $Stopwatch.Elapsed.Milliseconds"ms."
$Stopwatch.Stop()

# End --------------#>
