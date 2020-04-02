<#
.NOTES
	Name: ExchangeServerComponentMonitor.ps1
    Author: Josh Jerdon
    Email: jojerd@microsoft.com
	Requires: PowerShell 3.0, Exchange Management Shell as well as administrator rights on the target Exchange
	server.
	Version History:
	1.0 - 2/19/2019 Initial Release
 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
.SYNOPSIS
Monitors Exchange server components within a loop cycle you define in minutes. With the Individual component monitor
I included the ability of the script to send a notification via email to let you know when a component state has changed 
from anything other than Active. I have the script break after this so that you do not continue to get emailed every X number of minutes
until you have a chance to correct the component state.

Email notifications I have tested with Outlook.com using their SMTP.LIVE.COM SMTP endpoint.

#>

$Global:ProgressPreference = 'SilentlyContinue'
#Add Support for TLS SMTP communication
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
#Check PowerShell version
if ($PSVersionTable.PSVersion.Major -gt 3) {
    Write-Host "PowerShell meets minimum version requirements, continuing" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Clear-Host

    #Add Exchange Management Capabilities Into The Current PowerShell Session.
    $CheckSnapin = (Get-PSSnapin | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"} | Select Name)
    if ($CheckSnapin -like "*Exchange.Management.PowerShell*") {
        Write-Host "Exchange Snap-in already loaded, continuing...." -ForegroundColor Green
    }
    else {
        Write-Host "Loading Exchange Snap-in Please Wait..."
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
    }
}
#Individual monitor loop
function Individual {
    Clear-Host
    Write-Host "You selected to monitor an Individual component..."; 
    start-sleep -Seconds 3; 
    $Server = Read-Host "Name Of Server You Want to Monitor?"; 
    $Component = Read-Host "Name of Component You Want to Monitor?"; 
    $SMTPServer = Read-Host "SMTP Server Name?"
    $Port = Read-Host "SMTP Server Port Number?"
    $User = Read-Host "Username?"
    Clear-Host
    $Password = Read-Host "Password?" -AsSecureString
    Clear-Host
    $EmailMessage = New-Object System.Net.Mail.MailMessage
    $EmailMessage.From = Read-Host "Who do you want the message to be from? Example User@yourdomain.com"
    $EmailTo = Read-Host "Who do you want the message to be delivered too?"
    $EmailMessage.To.Add($EmailTo)
    $SMTPClient = New-Object System.Net.Mail.SmtpClient($SMTPServer, $Port)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($User, $Password);
        Do {
    Clear-Host
    $ComponentState = Get-ServerComponentState -Identity $Server | Where-Object {$_.Component -Match "$Component"}
    $ComponentHealth = $ComponentState.State
    Write-Host " "
    if ($ComponentHealth -eq "Active"){Write-Host "Server Component $Component Is Active, going back to sleep"}
    
    else {
        Write-Host " "
        Write-Host "Component $Component Health on server $Server is $ComponentHealth, Notifying designated recipient" -ForegroundColor Red
        $EmailMessage.Subject = "Component State change!!!"
        $EmailMessage.Body = "Server Component $Component that is being monitored on Server $Server is listed as $componentHealth"
        $SMTPClient.Send($EmailMessage)
        Break
    }
    $LoopCount++
    $Time = Get-Date -Format G
    Write-Host ("Script Has Checked Server Component Health {0} times" -f $LoopCount) -ForegroundColor Green
    Write-Host "Script Has Last Checked Server Component Health at $Time" -ForegroundColor Yellow
    
    #Clearing variables to ensure script uses new data each time it queries the component health.
    $ComponentState = $null
    $ComponentHealth = $null
    Start-Sleep -Seconds $SleepSeconds
        }
        While ($true)
    }
    
    # All server component monitor loop. No notification, by default some components are inactive and will vary by environment.
    function AllComponents{
    Clear-Host
    Write-Host "You selected to monitor all Exchange server Components..."; 
    Start-Sleep -Seconds 3; 
    $AllComponentServer = Read-Host "Name Of Server You want to monitor All components on?"; 
        Do{
    Clear-Host
    Write-Host " "
    Get-ServerComponentState -Identity $AllComponentServer
       
    $LoopCount++
    $Time = Get-Date -Format G
    Write-Host " "
    Write-Host ("Script Has Checked Server Component Health {0} times" -f $LoopCount) -ForegroundColor Green
    Write-Host "Script Has Last Checked Server Component Health at $Time" -ForegroundColor Yellow
    Start-Sleep -Seconds $SleepSeconds
        }
        while ($true)
    }
[int]$SleepTimer = Read-Host "How many minutes do you want the script to sleep before checking the servers component health? Example 5, 10, 15, 20, etc (in Minutes)"
$SleepSeconds = ($SleepTimer * 60)
$LoopCount = 0
$ComponentQuestion = "Do you want to monitor an individual Exchange components, or all components?"
$Individual = New-Object System.Management.Automation.Host.ChoiceDescription "&Individual","help";
$AllComponents = New-Object System.Management.Automation.Host.ChoiceDescription "&All Components","help";
$Choices = [System.Management.Automation.Host.ChoiceDescription[]]($Individual,$AllComponents)
$Answer = $Host.UI.PromptForChoice($caption,$ComponentQuestion,$Choices,0)

switch ($Answer) {
   0 {Individual}
   1 {AllComponents}
  }

