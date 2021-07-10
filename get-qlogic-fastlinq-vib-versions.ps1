# Display driver versions for QLogic FastLinQ QL41xxx Series 10/25 GbE Controller

$esxihosts = Get-VMHost esxi1* | Sort-Object

foreach ($esxi in $esxihosts) {
  Write-Host $esxi -ForegroundColor Green
  $esxcli = Get-EsxCli -VMhost $esxi -V2
  $drivers = @(‘qedf’,’qedentv’,’qedrntv’,’qedi’)

  foreach($driver in $drivers) {
   $driverversion = $esxcli.software.vib.list.invoke() | where {$_.Name -eq $driver} | select -Property “Version”
   Write-Host $driver – $driverversion.Version
  }
}
