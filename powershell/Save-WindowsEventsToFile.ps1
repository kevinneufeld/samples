<#
.SYNOPSIS
Saves Windows Event Logs to a text file.

.DESCRIPTION
Save all Windows Event logs to a text file.

.PARAMETER FileName
Specifies the output file name.

.EXAMPLE
C:\>./Save-WindowsEventsToFile.ps1

.EXAMPLE
C:\>./Save-WindowsEventsToFile.ps1 -FileName "example_filename.txt"

#>

#Run PS as Admin

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$FileName
    )

if ($FileName) {$OutFileName = $FileName} else { $OutFileName = "WindowsEventLogs_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss") }

Get-EventLog -List | `
    ForEach-Object {
        if( ( $_.Entries.Count -eq 0 ) -or ( $_.Entries.Count -eq $null ) ){
            Write-Output ("`n`n-- {0} -->`nNo Log Entries..." -f $_.LogDisplayName);
        }else{
            Write-Output ("`n`n-- {0} -->" -f $_.LogDisplayName);
            Get-EventLog $_.Log
        }
    } | `
    Format-Table -AutoSize | `
    Out-String -Width 4096 | `
    Out-File $OutFileName;
