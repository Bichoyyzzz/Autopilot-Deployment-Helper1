# autopilot-helper.ps1
# Script PowerShell pour gérer les appareils Autopilot

# Connexion à Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Vérification des profils Autopilot
$profiles = Get-MgDeviceManagementWindowsAutopilotDeploymentProfile
Write-Output "Profils Autopilot disponibles :"
$profiles | Format-Table DisplayName, Description

# Nettoyage des anciens appareils
$devices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity
$oldDevices = $devices | Where-Object { $_.LastContactedDateTime -lt (Get-Date).AddMonths(-6) }
foreach ($device in $oldDevices) {
    Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $device.Id
}

# Export des logs d'installation
$logs = $devices | Select-Object DeviceName, DeploymentState, LastContactedDateTime
$logs | Export-Csv -Path "AutopilotLogs.csv" -NoTypeInformation

# Ajout de tags ou groupes dynamiques (exemple)
foreach ($device in $devices) {
    Update-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $device.Id -GroupTag "ModernDevice"
}
