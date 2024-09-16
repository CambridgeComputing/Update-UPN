<#
.Synopsis
    A script to change the UPN suffix of all users in a specified OU.

.Description
    This script connects to Active Directory and changes the User Principal Name (UPN) suffix of all users in a specified Organizational Unit (OU).
    The UPN suffix is changed to the input of --UPNSuffix. If the user's current UPN suffix is already what's defined in --UPNSuffix, the UPN is left unchanged.
    This version of the script adds the ability to save a CSV that has the user account login name, old UPN, and new UPN.

.Parameter OU
    Specifies the Distinguished Name (DN) of the OU.
    This parameter is mandatory.

.Parameter UPNSuffix
    Specifies the UPN suffix to be changed to.
    This parameter is mandatory.

.Parameter OutCSV
    Specifies the path to save the CSV file.
    This parameter is optional.

.Parameter DryRun
    Specifies whether to actually change the UPN suffix. If this parameter is present, the UPN suffix will not be changed.
    This parameter is optional.

.Parameter ShowAll
    Specifies whether to display detailed output. If this parameter is present, the script will display verbose output for
    all accounts processed, otherwise only changed accounts will be shown.
    This parameter is optional.

.Example
    .\ChangeUPNSuffix.ps1 -OU "OU=YourOU,DC=YourDomain,DC=com" -UPNSuffix "newDomain.com" -OutCSV "C:\Temp\UPNChanges.csv" -ShowALl
    This command changes the UPN suffix of all users in the OU 'YourOU' in the domain 'YourDomain.com' to 'newDomain.com',
    saves the changes to 'C:\Temp\UPNChanges.csv', and displays verbose output.

.Notes
    Author: Dennis McDonald
    Date: 09/16/2024
    Version: 1.1
    Tested on: Windows Server 2016

.Link
    https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2019-ps
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$OU,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$true)]
    [string]$UPNSuffix,

    [Parameter(Mandatory=$false)]
    [string]$OutCSV,

    [Parameter(Mandatory=$false)]
    [switch]$ShowAll
)

# Import Active Directory module
Import-Module ActiveDirectory

# Get all users in the OU
$Users = Get-ADUser -Filter * -SearchBase $OU

# Initialize an empty array to hold the UPN changes
$UPNChanges = @()

# Initialize a counter for the loop
$i = 0

# Get the total number of users for the progress bar
$total = $Users.Count

# Loop through each user and change the UPN suffix
Write-Host ""
foreach ($User in $Users) {
    $i++
    Write-Progress -Activity "Changing UPN" -Status "Processing user $($i) of $total" -PercentComplete ($i / $total * 100)

    # Get the current UserPrincipalName
    $UPN = $User.UserPrincipalName

    # Check if the UPN already ends with the desired suffix
    if ($UPN -notlike "*@$UPNSuffix") {
        # Split the UPN into username and current domain
        $UPNParts = $UPN.Split("@")

        # Construct the new UserPrincipalName
        $NewUPN = $UPNParts[0] + "@$UPNSuffix"

        if ($DryRun) {
            Write-Host -ForegroundColor Yellow "UPN of $($User.SamAccountName) will be updated from $UPN to $NewUPN"
        } else {
            # Set the UserPrincipalName attribute to the new value
            Set-ADUser $User -UserPrincipalName $NewUPN

            Write-Host -ForegroundColor Green "UPN of $($User.SamAccountName) was updated from $UPN to $NewUPN"
        }

        # Add the UPN change to the array
        $UPNChanges += [PSCustomObject]@{
            UserName = $User.SamAccountName
            OldUPN = $UPN
            NewUPN = $NewUPN
        }
    } elseif ($ShowAll) {
        Write-Host "UPN of $($User.SamAccountName) is already correct: $($User.UserPrincipalName)"
    }
}

# If the OutCSV parameter is specified, save the UPN changes to a CSV file
if ($OutCSV) {
    $UPNChanges | Export-Csv -Path $OutCSV -NoTypeInformation
    Write-Host "Saved UPN changes to " -NoNewline
    Write-Host "$OutCSV" -ForegroundColor Green -NoNewline
}

Write-Host ""
