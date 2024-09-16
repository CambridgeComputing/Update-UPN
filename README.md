# Update-UPN.ps1

A PowerShell script to change the UPN suffix of all users in a specified OU.

## Description

This script connects to Active Directory and changes the User Principal Name (UPN) suffix of all users in a specified Organizational Unit (OU). The UPN suffix is changed to the input of `--UPNSuffix`. If the user's current UPN suffix is already what's defined in `--UPNSuffix`, the UPN is left unchanged. This version of the script also adds the ability to save a CSV that has the user account login name, old UPN, and new UPN.

## Parameters

### Mandatory Parameters
- `OU`: Specifies the Distinguished Name (DN) of the OU. This parameter is mandatory.
- `UPNSuffix`: Specifies the UPN suffix to be changed to. This parameter is mandatory.

### Optional Parameters
- `OutCSV`: Specifies the path to save a CSV file with all changes made. This parameter is optional.
- `DryRun`: Specifies whether to actually change the UPN suffix. If this parameter is present, the UPN suffix will not be changed. This parameter is optional.
- `ShowAll`: Specifies whether to display detailed output. If this parameter is present, the script will display verbose output for all accounts processed, otherwise only changed accounts will be shown. This parameter is optional.

## Usage

```powershell
.\Update-UPN.ps1 -OU "OU=YourOU,DC=YourDomain,DC=com" -UPNSuffix "newDomain.com" -OutCSV "C:\Temp\UPNChanges.csv" -ShowAll
```

This command changes the UPN suffix of all users in the OU 'YourOU' in the domain 'YourDomain.com' to 'newDomain.com', saves the changes to 'C:\Temp\UPNChanges.csv', and displays verbose output.

## Notes
- Tested on: Windows Server 2016 AD Servers from Windows 11 Pro workstation

## Links

- [Active Directory Cmdlets in Windows PowerShell](https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2019-ps)

---