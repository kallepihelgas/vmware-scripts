### Cleanup old logs from /storage/log/*

# /storage/log/vmware/eam/web
find /storage/log/vmware/eam/web -name "*.log" -type f -mtime +10 -delete

#/storage/log/vmware/vmware-sps
rm -rf /storage/log/vmware/vmware-sps/sps-runtime.log.stderr
find /storage/log/vmware/vmware-sps -name "*.log" -type f -mtime +10 -delete
find /storage/log/vmware/vmware-sps -name "*.gz" -type f -mtime +10 -delete

#/storage/log/vmware/lookupsvc/tomcat
find /storage/log/vmware/lookupsvc/tomcat -name "*.log" -type f -mtime +10 -delete

#/storage/log/vmware/lookupsvc
find /storage/log/vmware/lookupsvc -name "*.txt" -type f -mtime +10 -delete

#/storage/log/vmware/vsphere-ui/logs
find /storage/log/vmware/vsphere-ui/logs -name "*.log" -type f -mtime +10 -delete
find /storage/log/vmware/vsphere-ui/logs -name "thread*.log" -type f -mtime +1 -delete
find /storage/log/vmware/vsphere-ui/logs -name "*.zip" -type f -mtime +10 -delete

#/storage/log/vmware/vsphere-ui/logs/access
find /storage/log/vmware/vsphere-ui/logs/access -name "*.txt" -type f -mtime +5 -delete

#/storage/log/vmware/vpxd
find /storage/log/vmware/vpxd -name "*.gz" -type f -mtime +10 -delete
find /storage/log/vmware/vpxd -name "*.txt" -type f -mtime +10 -delete
find /storage/log/vmware/vpxd -name "*vpxduptime" -type f -mtime +10 -delete

#/storage/log/vmware/vmware-updatemgr/vum-server
find /storage/log/vmware/vmware-updatemgr/vum-server -name "*.log*" -type f -mtime +10 -delete
find /storage/log/vmware/vmware-updatemgr/vum-server -name "*.log" -type f -mtime +10 -delete

#/storage/log/vmware/sso
find /storage/log/vmware/sso -name "*.gz" -type f -mtime +10 -delete

#/storage/log/vmware/sso/tomcat
find /storage/log/vmware/sso/tomcat -name "*.log" -type f -mtime +10 -delete

# /storage/log/vmware/vpxd-svcs
find /storage/log/vmware/vpxd-svcs -name "*.gz" -type f -mtime +10 -delete
