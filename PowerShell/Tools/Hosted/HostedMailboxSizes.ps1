Write-Host "Generate a list of mailbox sizes and write to a file" -foregroundcolor Yellow -backgroundcolor DarkBlue

$d1 = Get-Date -format "yyyyMMdd"
$d2 = Get-Date -format "ddd dd MMM yyyy"
$f = "HostedMX01MailboxSizes_" + $d1 + ".txt"
del $f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Company A"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Company A >>$f
echo ========= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Company B"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Company B >>$f
echo ========= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "AEG Hospitality"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo AEG Hospitality >>$f
echo =============== >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Aggmore"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Aggmore >>$f
echo ======= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Fortitude"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Fortitude >>$f
echo ========= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Hannah Fryer"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Hannah Fryer >>$f
echo ============ >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "IRRFC"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo IRRFC >>$f
echo ===== >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Longmead"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Longmead >>$f
echo ======== >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Riverside"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Riverside >>$f
echo ========= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Pepco"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Pepco >>$f
echo ===== >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Sparkes"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Sparkes >>$f
echo ======= >>$f
echo $sizes >>$f

$sizes = Get-Mailbox | where {$_.customAttribute1 -eq "Spirit"} | Get-MailboxStatistics | sort-object TotalItemSize -descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount 
echo Spirit >>$f
echo ====== >>$f
echo $sizes >>$f

# Sanity check user accounts have correct custom attribute and address book policy set.
$sizes = Get-Mailbox | Sort-Object CustomAttribute1, AddressBookPolicy, DisplayName | ft DisplayName, AddressBookPolicy, CustomAttribute1
echo "*** All User (non system/journal) Mailboxes Should Have CustomAttribute1 and AddressBookPolicy set ***" >>$f
echo "======================================================================================================" >>$f
echo $sizes >>$f

# Sanity check user accounts have correct OWA Mailbox Policy set.
$sizes = Get-CASMailbox | Sort-Object OWAMailboxPolicy, DisplayName | ft DisplayName, OWAMailboxPolicy
echo "*** All User (non system/journal) Mailboxes Should Have OWA Mailbox policy set to 'Default' ***" >>$f
echo "======================================================================================================" >>$f
echo $sizes >>$f

Write-Host "Send an email with the file as an attachment" -foregroundcolor Yellow -backgroundcolor DarkBlue

$server = "Duo-HostedMX01"
$username = "hosted01\BESAdmin"
$password = ConvertTo-SecureString "Dying Br33d" -AsPlainText -Force
$credentials = new-object Management.Automation.PSCredential($username, $password)
$to = "backupalerts@duostream.co.uk"
$from = "BESAdmin@hosted01.duostream.net"
$subject = "Hosted Users Mailbox Sizes " + $d2

Send-MailMessage -SmtpServer $server -Credential $credentials -To $to -From $from -subject $subject -Attachments $f

Write-Host "Done" -foregroundcolor Yellow -backgroundcolor DarkBlue