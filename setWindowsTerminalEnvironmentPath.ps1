$winApps = "c:\Program Files\WindowsApps\";
$wtEnvVariable = "WT_Path";
$wtName = (Get-ChildItem -Path $winApps -Filter "Microsoft.WindowsTerminal_*__8wekyb3d8bbwe" | Sort-Object -Property Name -Descending)[0];
if ($wtName) {
	[System.Environment]::SetEnvironmentVariable($wtEnvVariable, $winApps + $wtName, [System.EnvironmentVariableTarget]::User);
}