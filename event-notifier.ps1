# This script sends a notification to a specified URL when a user logs in or out of the system.
# It uses the Windows Event Log to detect logon and logoff events and sends a POST request with the event details.
# The script should be run with administrative privileges to access the event logs.
# It is recommended to set up a scheduled task to run this script at startup.
# Example usage:
# 'powershell -ExecutionPolicy Bypass -File "C:\Path\To\event-notifier.ps1" -Action login -Url "https://yourdomain.com/api/device-login"'
param (
    [string]$Action,
    [string]$Url,
    [string]$UserFile = "$PSScriptRoot\user.json"
)

# Prepare headers and payload
$headers = @{
    "Content-Type" = "application/json"
}

$tokenData = Get-Content $UserFile | ConvertFrom-Json
$userId = $tokenData.user_id

$payload = @{
    username = "$env:USERNAME"
    timestamp = (Get-Date).ToString("o")
    action = $Action
    user_id = $userId
    device_id = $env:COMPUTERNAME
} | ConvertTo-Json

Write-Output $payload

# Send the request
try {
    Invoke-RestMethod -Uri $Url -Method Post -Headers $headers -Body $payload
} catch {
    Write-Error "Failed to send $Action request to $Url"
}
