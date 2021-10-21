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
$ldap_usrlkp_start  = 'cn=';
$ldap_usrlkp_end    = ',ou=Contoso,o=psdsa,c=US';
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

#                                                                              #
# End site-specific configuration                                              #
#                                                                              #


$policymgtapi = Netegrity::PolicyMgtAPI->New();
$session = $policymgtapi->CreateSession($adminName, $adminPwd);
 
die "\nFATAL: Cannot create session. Please check admin credentials\n" 
    unless ($session != undef);

#clean_ps_store();

setup_ps_store();

sub setup_ps_store {

    # Create a User Directory
    print "\tCreating User Directory \'contoso-userdir\'...";

    $userdir = $session->CreateUserDir( "contoso-userdir",
                                        $userdir_namespace,
                                        $userdir_server,
                                        $odbc_queryscheme,
                                        "Contoso User Directory",
                                        $ldap_srchroot,
                                        $ldap_usrlkp_start,
                                        $ldap_usrlkp_end,
                                        $ldap_usrname,
                                        $ldap_usrpwd,
                                        0,
                                        2,
                                        10,
                                        0,
                                        $ldap_require_creds
                                        );

    if(!defined $userdir) {
        die "\nFATAL: Unable to create User Directory \'contoso-userdir\'\n";
    }

    print "done\n";


    print "\tCreating Host Configuration for SPS \'sps-hco\'...";


    $hco = $session->CreateHostConfig( $host_conf_name,
                                    $host_conf_name,
                                    1,
                                    20,
                                    2,
                                    2,
                                    60
                                    );

    if(!defined $hco) {
        die "\nFATAL: Unable to create HCO \'sps-hco\'\n";
    }

    $hco->AddServer($policy_svr_host, 44441, 44442, 44443);

    print "done\n";

    print "\tCreating Agent \'spsapacheagent\'...";
    $agent = $session->CreateAgent( "spsapacheagent",
                                    $session->GetAgentType("Web Agent"),
                                    "Secure Proxy UI Agent"
                                );
    if(!defined $agent) {
        die "\nFATAL: Unable to create Agent \'spsapacheagent\'\n";
    }

    print "done\n";
}

sub clean_ps_store() {

    $session->DeleteDomain('DOMAIN-SPSADMINUI-spsapacheagent');
    if($status == -1) {
        print "Error deleting domain\n";
    }

    $session->DeleteAgentConfig( 'spsapacheagent-settings');
    if($status == -1) {
        print "Error deleting agent s\n";
    }

    $status = $session->DeleteHostConfig( $host_conf_name );
    if($status == -1) {
        print "Error deleting host config\n";
    }

    $status = $session->DeleteAgent( "spsapacheagent");
    if($status == -1) {
        print "Error deleting agent\n";
    }

    $status = $session->DeleteUserDir("contoso-userdir");
    if($status == -1) {
        print "Error deleting contoso-userdir\n";
    }

}