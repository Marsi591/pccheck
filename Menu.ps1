$ErrorActionPreference = "SilentlyContinue"

# ---------- MENUS ----------
function Show-MainMenu {
    Read-Host "
Aurora RP PC Check`n 
`nChoose a Category:
(1) Checks
(2) Clean Traces
(5) Credits
(0) Exit

Choose"
}

function Show-ChecksMenu {
    Read-Host "`nChecks Menu:
(1) Quick Check
(0) Back

Choose"
}

function Show-CreditsMenu {
    Read-Host "`nCredits:
Made by dot-sys
Edited by Marsi591 for AuroraRP

(0) Back

Choose"
}

function Show-ProgramsMenu {
    Read-Host "`nPrograms Menu:
(1) CSV File View
(2) Timeline Explorer
(3) Registry Explorer
(4) Journal Tool
(5) WinPrefetchView
(6) System Informer
(7) Everything
(0) Back

Choose"
}

# ---------- FUNCTIONS ----------
function Ensure-Folder($Path) {
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function CleanTraces {
    Write-Host "`nCleaning traces..." -ForegroundColor Yellow
    Ensure-Folder "C:\Temp\Dump"
    Ensure-Folder "C:\Temp\Scripts"

    Get-ChildItem "C:\Temp\Dump" -Recurse -Force | Remove-Item -Recurse -Force
    Get-ChildItem "C:\Temp\Scripts" -File |
        Where-Object { $_.Name -ne "Menu.ps1" } |
        Remove-Item -Force

    Write-Host "Traces cleaned." -ForegroundColor Green
    Start-Sleep 2
}

function Unzip {
    param ($Zip, $Dest)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Zip, $Dest)
}

function Download-Scripts($Urls) {
    Ensure-Folder "C:\Temp\Scripts"
    foreach ($url in $Urls) {
        $file = Join-Path "C:\Temp\Scripts" ([IO.Path]::GetFileName($url))
        Invoke-WebRequest $url -OutFile $file
        Write-Host "Downloaded $($file)" -ForegroundColor Green
    }
}

# ---------- MAIN LOOP ----------
do {
    Clear-Host
    $main = Show-MainMenu

    switch ($main) {

        "1" {
            do {
                Clear-Host
                $check = Show-ChecksMenu
                if ($check -eq "1") {
                    Write-Host "Running Quick Check..." -ForegroundColor Yellow

                    Ensure-Folder "C:\Temp\Dump"
                    Ensure-Folder "C:\Temp\Scripts"

                    $urls = @(
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/PCCheck.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/QuickMFT.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/PCIE.ps1",                       
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/Registry.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/SystemLogs.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/ProcDump.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/Localhost.ps1",
                        "https://raw.githubusercontent.com/Marsi591/pccheck/master/Viewer.html"
                    )

                    Download-Scripts $urls
                    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
                    & "C:\Temp\Scripts\PCCheck.ps1"
                }
            } while ($check -ne "0")
        }

        "2" { CleanTraces }

        "999" {
            do {
                Clear-Host
                $prog = Show-ProgramsMenu
                Ensure-Folder "C:\Temp\Dump"

                switch ($prog) {
                    "1" {
                        Invoke-WebRequest "https://www.nirsoft.net/utils/csvfileview-x64.zip" -OutFile "C:\Temp\Dump\csv.zip"
                        Unzip "C:\Temp\Dump\csv.zip" "C:\Temp\Dump\CSVFileView"
                    }
                    "2" {
                        Invoke-WebRequest "https://download.mikestammer.com/net6/TimelineExplorer.zip" -OutFile "C:\Temp\Dump\timeline.zip"
                        Unzip "C:\Temp\Dump\timeline.zip" "C:\Temp\Dump\TimelineExplorer"
                    }
                    "3" {
                        Invoke-WebRequest "https://download.mikestammer.com/net6/RegistryExplorer.zip" -OutFile "C:\Temp\Dump\registry.zip"
                        Unzip "C:\Temp\Dump\registry.zip" "C:\Temp\Dump\RegistryExplorer"
                    }
                    "4" { Start-Process "http://dl.echo.ac/tool/journal" }
                    "5" {
                        Invoke-WebRequest "https://www.nirsoft.net/utils/winprefetchview.zip" -OutFile "C:\Temp\Dump\prefetch.zip"
                        Unzip "C:\Temp\Dump\prefetch.zip" "C:\Temp\Dump\WinPrefetchView"
                    }
                    "6" { Start-Process "https://systeminformer.sourceforge.io/canary" }
                    "7" {
                        Invoke-WebRequest "https://www.voidtools.com/Everything-1.4.1.1026.x64-Setup.exe" -OutFile "C:\Temp\Dump\Everything.exe"
                    }
                }
                Start-Sleep 2
            } while ($prog -ne "0")
        }

        "5" {
            do {
                Clear-Host
                $c = Show-CreditsMenu
            } while ($c -ne "0")
        }

        "0" {
            Write-Host "Exiting..." -ForegroundColor Red
            Start-Sleep 1
            break
        }
    }

} while ($true)