#!/bin/bash
source /opt/CA/siteminder/ca_ps_env.ksh 
smreg -su siteminder
XPSDDInstall /opt/CA/siteminder/xps/dd/SmMaster.xdd
XPSImport /opt/CA/siteminder/db/smpolicy.xml -npass
XPSRegClient siteminder:siteminder -adminui-setup -vT 
perl /tmp/sm_temp/dockertools/ProxyUIPrerequisites.pl
perl /tmp/sm_temp/dockertools/SecureExampleApp.pl
