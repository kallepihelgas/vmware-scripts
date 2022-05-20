$mypath = $MyInvocation.MyCommand.Path
Write-Host Running script: $mypath

Import-Module -Name powershell-yaml -Verbose

$mypath = $MyInvocation.MyCommand.Path
$folder = Split-Path $mypath -Parent
$config_file = "$folder\esxi_rules.yml"
Write-Host $config_file
$file = Get-Content -Path $config_file
$items = $file | ConvertFrom-Yaml

$esx_hosts = Get-VMHost -State  Connected,Maintenance # | Where-Object {$_.ConnectionState -ne "NotResponding"}

foreach ($esx_host in $esx_hosts) {
  Write-Host "Setting firewall on $esx_host" -ForegroundColor Green

  $esxcli = Get-EsxCli -VMhost $esx_host -V2

  $fw_disable_status = $false
  $enabled_rules = $esxcli.network.firewall.ruleset.list.Invoke() | Where-Object {$_.Enabled -eq $true} | Select-Object Name

  # Disable firewall before modifing rules
  Write-Host "Disable firewall before modifing rules" -BackgroundColor Red
  $arguments = $esxcli.network.firewall.set.CreateArgs()
  $arguments.enabled = "false"
  $fw_disable_status = $esxcli.network.firewall.set.invoke($arguments)

  if ($fw_disable_status -ne "true") {
    Write-Host Failed to disable firewall $esx_host ... skipping -ForegroundColor Red
    break
  }
    
  foreach ($enable_service in $enabled_rules) {
    if ($items.rules.servicename -notcontains $enable_service.Name) {
      Write-Host No rule in the config for $enable_service.Name -ForegroundColor DarkRed
    }
    else {
      foreach ($service in $items.rules) {
        if ($enable_service.Name -eq $service.servicename) {
          $service_name = $service.name
          Write-Host "Configuring $service_name" -ForegroundColor DarkBlue
          Write-Host "Checking for allowed all IP-s."
          $arguments0 = $esxcli.network.firewall.ruleset.allowedip.list.CreateArgs()
          $arguments0.rulesetid = $service.servicename
          $allowed_all_ip_status = $esxcli.network.firewall.ruleset.allowedip.list.Invoke($arguments0).AllowedIPAddresses
        if ($allowed_all_ip_status -imatch "All") {
          Write-Host "Disable allowed all IPs" -ForegroundColor Yellow
          $arguments1 = $esxcli.network.firewall.ruleset.set.CreateArgs()
          $arguments1.enabled = $true
          $arguments1.allowedall = $false
          $arguments1.rulesetid = $service.servicename
          $esxcli.network.firewall.ruleset.set.Invoke($arguments1) | Out-Null
        }

        Write-Host Clearing old ip-s before applying new list ip ip-s.
        $arguments4 = $esxcli.network.firewall.ruleset.allowedip.list.CreateArgs()
        $arguments4.rulesetid = $service.servicename
        $old_ips = $esxcli.network.firewall.ruleset.allowedip.list.Invoke($arguments4).AllowedIPAddresses
        foreach ($old_ip in $old_ips) {
          $arguments3 = $esxcli.network.firewall.ruleset.allowedip.remove.CreateArgs()
          $arguments3.rulesetid = $service.servicename
          $arguments3.ipaddress = $old_ip
          $esxcli.network.firewall.ruleset.allowedip.remove.Invoke($arguments3) | Out-Null
        }
        foreach ($ip in $service.allowedip) {
          Write-Host Adding $ip to $service.servicename allowed list.
          $arguments2 = $esxcli.network.firewall.ruleset.allowedip.add.CreateArgs()
          $arguments2.rulesetid = $service.servicename
          $arguments2.ipaddress = $ip
          $esxcli.network.firewall.ruleset.allowedip.add.Invoke($arguments2)
        }
        $esxcli.network.firewall.refresh.Invoke() | Out-Null
        Write-Host Done with $enable_service.Name
        }
      }
    }
  }

  # Enable firewall after modifing rules
  Write-Host "Enable firewall after modifing rules" -BackgroundColor Red
  $arguments = $esxcli.network.firewall.set.CreateArgs()
  $arguments.enabled = "true"
  $esxcli.network.firewall.set.invoke($arguments) | Out-Null

  #### ESXi host firewall settings ####
}
