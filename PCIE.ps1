$ErrorActionPreference = "Continue"
$pciePath = "C:\Temp\Dump\PCIe"
if (-not (Test-Path $pciePath)) { New-Item -Path $pciePath -ItemType Directory -Force | Out-Null }

function Get-PCIeDevices {
    $pciDevices = Get-CimInstance Win32_PnPEntity | Where-Object { 
        $_.PNPDeviceID -and ($_.PNPDeviceID.StartsWith('PCI\') -or $_.PNPDeviceID.StartsWith('PCI('))
    }

    $deviceList = foreach ($dev in $pciDevices) {
        $idParts = $dev.PNPDeviceID -split "\\|&"
        if ($idParts[0] -match "VEN_([0-9A-Fa-f]+)") {
            $vendor = $matches[1]
        } else {
            $vendor = ""
        }
        if ($idParts[0] -match "DEV_([0-9A-Fa-f]+)") {
            $device = $matches[1]
        } else {
            $device = ""
        }
        if ($idParts[0] -match "SUBSYS_([0-9A-Fa-f]+)") {
            $subsys = $matches[1]
        } else {
            $subsys = ""
        }
        if ($idParts[0] -match "REV_([0-9A-Fa-f]+)") {
            $rev = $matches[1]
        } else {
            $rev = ""
        }

        [PSCustomObject]@{
            Name         = $dev.Name
            Manufacturer = $dev.Manufacturer
            Status       = $dev.Status
            Class        = $dev.Class
            InstanceID   = $dev.PNPDeviceID
            VendorID     = $vendor
            DeviceID     = $device
            SubSystemID  = $subsys
            Revision     = $rev
        }
    }
    return $deviceList
}

try {
    $pcieDevices = Get-PCIeDevices
    
    if ($null -ne $pcieDevices -and $pcieDevices.Count -gt 0) {
        $pcieDevices | Sort-Object Class, Name | Export-Csv -Path "$pciePath\PCIe_Raw.csv" -NoTypeInformation -Encoding UTF8
        
        $pcieDevices | Sort-Object Class, Name | Format-Table Name, Manufacturer, Class, Status, VendorID, DeviceID, SubSystemID, Revision -AutoSize | Out-File "$pciePath\PCIe_Detailed.txt" -Encoding UTF8
        
        $pcieSummary = $pcieDevices | Group-Object Class | ForEach-Object {
            [PSCustomObject]@{
                Class = $_.Name
                Count = $_.Count
            }
        } | Sort-Object Class
        
        $pcieSummary | Format-Table -AutoSize | Out-File "$pciePath\PCIe_Summary.txt" -Encoding UTF8
    } else {
        [PSCustomObject]@{Name = "No Devices"; Manufacturer = ""; Status = ""; Class = ""; InstanceID = ""; VendorID = ""; DeviceID = ""; SubSystemID = ""; Revision = ""} | Export-Csv -Path "$pciePath\PCIe_Raw.csv" -NoTypeInformation -Encoding UTF8
        "No PCIe devices found" | Out-File "$pciePath\PCIe_Detailed.txt" -Encoding UTF8
        "No PCIe devices found" | Out-File "$pciePath\PCIe_Summary.txt" -Encoding UTF8
    }
} catch {
    $errorMessage = "Error in PCIE.ps1: $_"
    $errorMessage | Out-File "$pciePath\PCIe_Error.txt" -Encoding UTF8
    [PSCustomObject]@{Error = $errorMessage} | Export-Csv -Path "$pciePath\PCIe_Raw.csv" -NoTypeInformation -Encoding UTF8
}
