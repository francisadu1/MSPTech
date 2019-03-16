function Test-UserExists
{
   param
   (
       [Parameter(Mandatory)]
       [string]
       $SAMAccountName
   )

   @(Get-ADUser -LDAPFilter "(samaccountname=$SAMAccountName)").Count -ne 0

}


# # specify user name and user domain
# $UserDomain = $env:USERDOMAIN
# $UserName = $env:USERNAME
# $Password = Read-Host -Prompt "Enter password to test"

# # test password
# Add-Type -AssemblyName System.DirectoryServices.AccountManagement
# $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
# $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType , $UserDomain)
# $PrincipalContext.ValidateCredentials($UserName,$Password)
