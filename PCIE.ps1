$pciePath = "C:\Temp\Dump\PCIe"
if (-not (Test-Path $pciePath)) { New-Item -Path $pciePath -ItemType Directory -Force | Out-Null }

function Get-PCIeDevices {
    $pciDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.PNPDeviceID -match '^PCI' }

    $deviceList = foreach ($dev in $pciDevices) {
        $idParts = $dev.PNPDeviceID -split "\\|&"
        $vendor = ($idParts[0] -match "VEN_([0-9A-Fa-f]+)") ? $matches[1] : ""
        $device = ($idParts[0] -match "DEV_([0-9A-Fa-f]+)") ? $matches[1] : ""
        $subsys = ($idParts[0] -match "SUBSYS_([0-9A-Fa-f]+)") ? $matches[1] : ""
        $rev = ($idParts[0] -match "REV_([0-9A-Fa-f]+)") ? $matches[1] : ""

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

$pcieDevices = Get-PCIeDevices

$pcieDevices | Sort-Object Class, Name | Export-Csv -Path "$pciePath\PCIe_Raw.csv" -NoTypeInformation -Encoding UTF8

$pcieDevices | Sort-Object Class, Name | Format-Table Name, Manufacturer, Class, Status, VendorID, DeviceID, SubSystemID, Revision -AutoSize | Out-File "$pciePath\PCIe_Detailed.txt"

$pcieSummary = $pcieDevices | Group-Object Class | ForEach-Object {
    [PSCustomObject]@{
        Class = $_.Name
        Count = $_.Count
    }
} | Sort-Object Class

$pcieSummary | Format-Table -AutoSize | Out-File "$pciePath\PCIe_Summary.txt"
