<#
.SYNOPSIS
Gets currently installed applications.

.EXAMPLE
C:\>./Get-InstalledApplications.ps1
#>

#Assumptions: A list of currently installed applications that can be untinstalled.
#Run PS as Admin

#No arguments allowed
[CmdLetBinding()]
param()

#Get untinstall keys from registry.
$AppKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | `
    Where-Object {$_.GetValueNames() -contains 'DisplayName'};

#Add to appkey list if 64bit from WOW6432Node
if (![System.IntPtr]::Size -eq 4) {
    $AppKeys = $AppKeys + (Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | `
        Where-Object {$_.GetValueNames() -contains 'DisplayName'});
}

#create a Custom Object for each app
foreach ($appKey in $AppKeys){
    $appObj = New-Object -TypeName psobject

    $appObj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $appKey.GetValue('DisplayName')
    $appObj | Add-Member -MemberType NoteProperty -Name DisplayVersion -Value $appKey.GetValue('DisplayVersion')
    $appObj | Add-Member -MemberType NoteProperty -Name Publisher -Value $appKey.GetValue('Publisher')
    $appObj | Add-Member -MemberType NoteProperty -Name InstallDate -Value $appKey.GetValue('InstallDate')
    $appObj | Add-Member -MemberType NoteProperty -Name InstallLocation -Value $appKey.GetValue('InstallLocation')
    $appObj | Add-Member -MemberType NoteProperty -Name InstallSource -Value $appKey.GetValue('InstallSource')
    $appObj | Add-Member -MemberType NoteProperty -Name ModifyPath -Value $appKey.GetValue('ModifyPath')
    $appObj | Add-Member -MemberType NoteProperty -Name QuietUninstallString -Value $appKey.GetValue('QuietUninstallString')
    $appObj | Add-Member -MemberType NoteProperty -Name UninstallString -Value $appKey.GetValue('UninstallString')
    $appObj | Add-Member -MemberType NoteProperty -Name GUID -Value (($appKey.GetValue('UninstallString') -split '{' -split '}')[1])

    $appObj
}
