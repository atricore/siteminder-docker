################################################################################
#                                                                              #
#   Copyright (C) 2021, Atricore, Inc. All rights reserved                     #
#                                                                              #
################################################################################

#                                                                              #
# This script configures an application secured by the Secure Proxy Server.    #
# The example application is a containazired openresty-based - therefore nginx #
# and Lua - application.                                                       #
#                                                                              #
  
use Netegrity::AgentAPI;
use Netegrity::PolicyMgtAPI;
 
#                                                                              #
# Begin site-specific configuration                                            #
# The follwing information should be changed before running this sample.       #
#                                                                              #

$adminName          = 'siteminder';
$adminPwd           = 'siteminder';
$agentIP            = '127.0.0.1';
$agentSecret        = 'secret';

$userdir_namespace  = 'LDAP:';
$userdir_server     = 'dx:7777';  # IP Address if LDAP, Data Source Name if ODBC
$user_lookup_string = 'cn=admin';  # Example: ou=People or name=jdoe

#===

$username           = 'jsmith';     # user to authenticate for protected resource
$userpwd            = 'password';   # user password (Basic Authentication)

$userdir_namespace  = 'LDAP:';
$userdir_server     = '127.0.0.1';  # IP Address if LDAP, Data Source Name if ODBC
$user_lookup_string = 'cn=admin';  # Example: ou=People or name=jdoe

#
# Authentication Scheme Settings
#
$schemeName="exampleapp-authscheme";
$schemeType="HTML Form Template";
$schemeDesc="My Example App Auth Scheme";
$protLevel=5;
#$schemeLib="smjavaapi";
$schemeLib="smauthhtml";
#$schemeParam="/siteminderagent/forms/login.fcc;ACS=0;REL=1";
$schemeParam="http://ag.34.133.255.103.nip.io:9090/forms/k8slogin.fcc;ACS=0;REL=0";
$schemeSecret="ThisIsMySecretNotYours";
$isTemplate=0;
$isUsedByAdmin=0;
$saveCreds=0;
$isRadius=0;
$ignorePwd=0;

#                                                                              #
# End site-specific configuration                                              #
#                                                                              #

$policymgtapi = Netegrity::PolicyMgtAPI->New();
$session = $policymgtapi->CreateSession($adminName, $adminPwd);
 
die "\nFATAL: Cannot create session. Please check admin credentials\n" 
    unless ($session != undef); 

clean_ps_store();

setup_ps_store();

sub setup_ps_store {
 
    # Create an agent. Agent will be a 4x Agent

    print "\n\tGetting SPS Agent \'spsapacheagent\'...";
    $agent = $session->GetAgent('spsapacheagent');

    if(!defined $agent) {
        die "\nFATAL: Unable to get Agent \'spsapacheagent\'\n";
    }

    print "done\n";

    # Create a User Directory

    print "\tGetting Contoso User Directory \'contoso-userdir\'...";

    $userdir = $session->GetUserDir( "contoso-userdir");

    if(!defined $userdir) {
        die "\nFATAL: Unable to get User Directory \'contoso-userdir\'\n";
    }

    print "done\n";

    # Create Authentication Scheme

    print "\tCreating Authentication Scheme \'exampleapp-authscheme\'...";

    $schemeTemplate=$session->GetAuthScheme('HTML Form Template');
    
    $auth_scheme = $session->CreateAuthScheme($schemeName, $schemeTemplate, $schemeDesc, $protLevel,
                $schemeLib, $schemeParam, $schemeSecret, $isTemplate, $isUsedByAdmin, $saveCreds, $isRadius, $ignorePwd);
    
    if(!defined $auth_scheme) {
        die "\nFATAL: Unable to create Authentication Scheme \'exampleapp-authscheme\'\n";
    }

    print "done\n";

    # Create a Domain

    print "\tCreating Domain \'exampleapp-domain\'...";

    $domain = $session->CreateDomain(   "exampleapp-domain",
                                        "Example App Domain"
                                    );

    if(!defined $domain) {
        die "\nFATAL: Unable to create Domain \'exampleapp-domain\'\n";
    }

    $domain->AddUserDir($userdir);

    print "done\n";


    # Create a Realm under the transpolar-domain Domain

    print "\tCreating Realm \'exampleapp-realm\'...";

    $realm = $domain->CreateRealm(  "exampleapp-realm",
                                    $agent,
                                    $auth_scheme,
                                    "Example App Realm",
                                    "/private/"
                                 );

    if(!defined $realm) {
        die "\nFATAL: Unable to create Realm \'exampleapp-realm\'\n";
    }

    print "done\n";


    # Create a Rule under the exampleapp-realm Realm

    print "\tCreating Rule \'exampleapp-rule\'...";

    $rule = $realm->CreateRule( "exampleapp-rule",
                                "Sample Example App Rule",
                                "GET",
                                "*"
                              );

    if(!defined $rule) {
        die "\nFATAL: Unable to create Rule \'exampleapp-rule\'\n";
    }

    print "done\n";


    # Create a Policy under the transpolar-domain Domain

    print "\tCreating Policy \'exampleapp-policy\'...";

    $policy = $domain->CreatePolicy(    "exampleapp-policy",
                                        "Example App Policy"
                                   );

    if(!defined $policy) {
        die "\nFATAL: Unable to create Policy \'exampleapp-policy\'\n";
    }

    $policy->AddRule($rule);
    print "done\n";

    print "\tAdding selected user to policy...";
    $user = $userdir->LookupEntry($user_lookup_string);
    if(defined $user) {
        $policy->AddUser($user);
        print "done\n";
    } else {
        print "user not found\n"

    }
    
}

sub clean_ps_store {
    print "\n\tCleaning up...";
    $session->DeleteDomain($session->GetDomain("exampleapp-domain"));
    $session->DeleteAuthScheme($session->GetAuthScheme($schemeName));
    print "done\n";
}
