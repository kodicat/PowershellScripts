#run as admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$username = 'windows_account'
$password += 'your_password'

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $(".\$username"), $securePassword
Start-Process "C:\Users\$username\AppData\Local\Microsoft\Teams\Update.exe" '--processStart "Teams.exe"' -WorkingDirectory $env:windir -Credential $credential