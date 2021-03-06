<#
.SYNOPSIS
Runs command (scriptblock) on remote host

.PARAMETER ComputerName
Fully qualified domain name (FQDN), for the computer name.

.PARAMETER Username
Username

.PARAMETER Password
Password

.PARAMETER ScriptBlock
command or script to be executed on remote host.

.PARAMETER DisableValidationAndPing
Switch disables FQDN Validation and Ping test on the remote host.

.EXAMPLE
C:\>.\Invoke-RemoteCommand.ps1 -ComputerName host.example.com -Username example_user -password example_password -ScriptBlock {Get-ChildItem C:\;}
#>
#Assumptions: WinRm is enabled, on domain, or workstation in a workgroup has be setup individiaully to allow WinRm, and user permission to do so.
# see: https://4sysops.com/archives/enable-powershell-remoting-on-a-standalone-workgroup-computer/

[CmdLetBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$ScriptBlock,
	[Parameter(Mandatory = $false)]
	[switch]$DisableValidationAndPing
)



function Invoke-MyCommand(){
[CmdLetBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [ScriptBlock]$ScriptBlock,
	[Parameter(Mandatory = $false)]
	[switch]$DisableValidationAndPing
)
	#From Regular Expressions Cookbook, 2nd Edition - Safari Online
	$FQDNRegex = "^((?=[a-z0-9-]{1,63}\.)[a-z0-9]+(-[a-z0-9]+)*\.)+([a-z]{2,63})$";

	if(($ComputerName -notmatch $FQDNRegex) -and ($DisableValidationAndPing -ne $true)){
		Write-Host "ComputerName `"$ComputerName`" needs to be a fully qualified domain name(FQDN)." -ForegroundColor Red;
		Exit 1;
	}

	if((-not (Test-Connection $ComputerName -Count 1 -Quiet)) -and ($DisableValidationAndPing -ne $true) ){
		Write-Host "Remote server `"$ComputerName`" is not reachable by ping." -ForegroundColor Red;
		Exit 1;
	}

	try
	{
		$secureStringPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force;
        $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $secureStringPassword);
		$session = New-PSSession -ComputerName $ComputerName -Credential $Credentials -ErrorAction Stop;

		Invoke-Command -Session $session -ScriptBlock $ScriptBlock -ErrorAction Stop;

	}
	catch [System.Management.Automation.Remoting.PSRemotingTransportException]
	{
		Write-Host "Connection Error: $_.Exception.Message" -ForegroundColor red;
		exit 1;
	}
	catch [System.Management.Automation.RemoteException]
	{
		Write-Host "Remote Script Block Error: $_.Exception.Message" -ForegroundColor Red;
		exit 1;
	}
	catch
	{
		Write-Host "Error: $_.Exception.Message" -ForegroundColor Red;
		exit 1;
	}
	finally
	{
		Remove-PSSession -Session $session;
	}


}
if($DisableValidationAndPing){
	Invoke-MyCommand -ComputerName $ComputerName -UserName $Username -Password byteme2 -ScriptBlock $ScriptBlock -DisableValidationAndPing;
}else{
	Invoke-MyCommand -ComputerName $ComputerName -UserName $Username -Password byteme2 -ScriptBlock $ScriptBlock;
}
