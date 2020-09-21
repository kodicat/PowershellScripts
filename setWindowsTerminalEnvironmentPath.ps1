$winApps = "c:\Program Files\WindowsApps\";
$wtEnvVariable = "WT_Path";
$wtName = (Get-ChildItem -Path $winApps -Filter "Microsoft.WindowsTerminal_*__8wekyb3d8bbwe")[0].Name;
if ($wtName) {
	[System.Environment]::SetEnvironmentVariable($wtEnvVariable, $winApps + $wtName, [System.EnvironmentVariableTarget]::User);
}