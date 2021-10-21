################################################################################
#                                                                              #
#   Copyright (C) 2021, Atricore, Inc. All rights reserved                     #
#                                                                              #
################################################################################


#                                                                              #
# This script creates an agent, a user directory and a host configuration      #
# object.                                                                      #
#                                                                              #
# Execute *before* SPS install script and supply the 'sps-hco' to the          #
# installer.                                                                   #
#                                                                              #

use Netegrity::PolicyMgtAPI;

#                                                                              #
# Begin site-specific configuration                                            #
# The follwing information should be changed before running this sample.       #
#                                                                              #

$adminName          = 'siteminder';
$adminPwd           = 'siteminder';

$userdir_namespace  = 'LDAP:';
$userdir_server     = 'dx:7777';  # IP Address if LDAP, Data Source Name if ODBC

#
# LDAP User Directory Settings
#
$ldap_srchroot      = 'ou=Contoso,o=psdsa,C=US';
$ldap_usrlkp_start  = '(cn=';
$ldap_usrlkp_end    = ',ou=Contoso,o=psdsa,c=US)';
$ldap_usrname       = '';
$ldap_usrpwd        = '';
$ldap_require_creds = 0;

#
# Host Config settings
#
$host_conf_name     = "sps-hco";
$host_conf_desc     = "Secure Proxy Server Host";

#
# Policy server host
#
$policy_svr_host    = "ps";

$schemeName="exampleapp-authscheme";

#                                                                              #
# End site-specific configuration                                              #
#                                                                              #

$policymgtapi = Netegrity::PolicyMgtAPI->New();
$session = $policymgtapi->CreateSession($adminName, $adminPwd);
 
die "\nFATAL: Cannot create session. Please check admin credentials\n" 
    unless ($session != undef);

print "\n\tCleaning up...";
$session->DeleteDomain($session->GetDomain("exampleapp-domain"));
$session->DeleteAuthScheme($session->GetAuthScheme($schemeName));
#$session->DeleteDomain($session->GetDomain("exampleapp-domain"));
$session->DeleteUserDir( $session->GetUserDir("contoso-userdir"));
$session->DeleteAgent( $session->GetAgent("spsapacheagent"));

print "done\n";

