# Install-OSUpdates

** Still in Development **

A PowerShell module to automate Windows Server patching using SCCM or WSUS. Supports update detection, installation, and optional reboot.

## Features
- Supports SCCM and WSUS patching
- Remote execution across multiple servers
- Optional reboot if required
- Verbose logging and error handling

## Usage

```powershell
Import-Module .\Install-OSUpdates.psm1

Install-OSUpdates -ComputerNames @("Server01", "Server02") -PatchSource SCCM -RebootIfRequired
