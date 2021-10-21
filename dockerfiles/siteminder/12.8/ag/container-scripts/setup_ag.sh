#!/bin/bash
source /opt/CA/secure-proxy/default/ca_sps_env.sh
/opt/CA/secure-proxy/default/ca-sps-config.sh -i silent -f /tmp/sp_temp/ca-sps-config-installer.properties
cp /tmp/sp_temp/server.conf /opt/CA/secure-proxy/default/proxy-engine/conf 
cp /tmp/sp_temp/proxyrules.xml /opt/CA/secure-proxy/default/proxy-engine/conf