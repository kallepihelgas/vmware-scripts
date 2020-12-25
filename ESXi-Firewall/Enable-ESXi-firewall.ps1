$esx_hosts = Get-VMHost -State Maintenance,Connected

foreach ($esx_host in $esx_hosts) {
  Write-Host $esx_host checking
  $esxcli= get-esxcli -VMHost $esx_host -V2
  $fw_status = ($esxcli.network.firewall.get.invoke()).Enabled
  Write-Host $esx_host – $fw_status

  if ($fw_status -eq “false”) {
    Write-Host Enabling FW -ForegroundColor Green
    $arguments = $esxcli.network.firewall.set.CreateArgs()
    $arguments.enabled = “true”
    $esxcli.network.firewall.set.invoke($arguments)
  }
}
