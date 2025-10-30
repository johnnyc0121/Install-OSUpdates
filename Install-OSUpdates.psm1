function Install-OSUpdates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerNames,

        [Parameter()]
        [ValidateSet("SCCM", "WSUS")]
        [string]$PatchSource = "SCCM",

        [Parameter()]
        [int]$TimeoutMinutes = 60,

        [Parameter()]
        [switch]$RebootIfRequired
    )

    foreach ($Computer in $ComputerNames) {
        Write-Verbose "Starting patch cycle for $Computer using $PatchSource"

        try {
            if ($PatchSource -eq "SCCM") {
                Invoke-CimMethod -ComputerName $Computer -Namespace "root\ccm" -ClassName "SMS_Client" -MethodName "TriggerSchedule" -Arguments @{sScheduleID = "ScanExecID"}
                Write-Verbose "Triggered SCCM scan on $Computer"
            }
            elseif ($PatchSource -eq "WSUS") {
                Invoke-Command -ComputerName $Computer -ScriptBlock {
                    wuauclt.exe /detectnow
                    wuauclt.exe /reportnow
                }
                Write-Verbose "Triggered WSUS scan on $Computer"
            }

            Start-Sleep -Seconds 10

            $Updates = Invoke-Command -ComputerName $Computer -ScriptBlock {
                $Session = New-Object -ComObject Microsoft.Update.Session
                $Searcher = $Session.CreateUpdateSearcher()
                $Searcher.Search("IsInstalled=0 and Type='Software'")
            }

            if ($Updates.Updates.Count -gt 0) {
                Write-Verbose "$($Updates.Updates.Count) updates found for $Computer"

                Invoke-Command -ComputerName $Computer -ScriptBlock {
                    $Session = New-Object -ComObject Microsoft.Update.Session
                    $Downloader = $Session.CreateUpdateDownloader()
                    $Downloader.Updates = $Updates.Updates
                    $Downloader.Download()

                    $Installer = $Session.CreateUpdateInstaller()
                    $Installer.Updates = $Updates.Updates
                    $Result = $Installer.Install()

                    if ($Result.RebootRequired -and $using:RebootIfRequired) {
                        Restart-Computer -Force
                    }
                }
            }
            else {
                Write-Verbose "No updates found for $Computer"
            }
        }
        catch {
            Write-Warning "Failed to patch $Computer: $_"
        }
    }
}
