################################################################################
#                                                                              #
#   Copyright (C) 2021, Atricore, Inc. All rights reserved                     #
#                                                                              #
################################################################################

#                                                                              #
# This script associates the user directory created in the                     #
# 'ProxyUIPrerequisites.pl' script to the ProxyUI configuration (i.e. domain)  #
# created by the SPS installer.                                                #
# Therefore, it has to be run afterwards SPS's 'setup_ag.sh' script.           #                                                              #
#                                                                              #

use Netegrity::PolicyMgtAPI;

$adminName          = 'siteminder';
$adminPwd           = 'siteminder';

$user_lookup_string = 'cn=admin';  # Example: ou=People or name=jdoe

#                                                                              #
# End site-specific configuration                                              #
#                                                                              #

$policymgtapi = Netegrity::PolicyMgtAPI->New();
$session = $policymgtapi->CreateSession($adminName, $adminPwd);
 
die "\nFATAL: Cannot create session. Please check admin credentials\n" 
    unless ($session != undef);
    
print "\tGetting Domain \'DOMAIN-SPSADMINUI-spsapacheagent\'...\n";

$domain = $session->GetDomain('DOMAIN-SPSADMINUI-spsapacheagent');

if(!defined $domain) {
    die "\nFATAL: Unable to find domain \'DOMAIN-SPSADMINUI-spsapacheagent\'";
}

print "\tGetting Policy \'POLICY-SPSADMINUI-spsapacheagent\'...";

$policy = $domain->GetPolicy("POLICY-SPSADMINUI-spsapacheagent" );
if(!defined $policy) {
    die "\nFATAL: Unable to find Policy \'POLICY-SPSADMINUI-spsapacheagent\'\n";
}

print "done\n";

print "\tGetting User directory \'contoso-userdir\'...";

$user_dir = $session->GetUserDir('contoso-userdir');

if(!defined $user_dir) {
    die "\nFATAL: Unable to find user directory \'contoso-userdir\'";
}

print "done\n";
 
print "\tAdding User Directory \'contoso-userdir\' to SPS domain...";

$status = $domain->AddUserDir($user_dir);

if($status == 0) {
    print "done\n";
} else {
    die "\nFATAL: Unable add contoso-userdir to SPS domain\n";
}

print "\tAdding selected user to policy...";
$user = $user_dir->LookupEntry($user_lookup_string);
if(defined $user) {
    $policy->AddUser($user);
    print "done\n";
} else {
    print "user not found\n"

}

print "\tGetting Default Agent Configuration Object\'SPSDefaultSettings\'...";
$default_agent_config = $session->GetAgentConfig( 'SPSDefaultSettings' );

if(!defined $default_agent_config) {
    die "\nFATAL: Unable to find Configuration Object \'SPSDefaultSettings\'\n";
}
    
print "\tCreating Agent Configuration Object\'spsapacheagent-settings\'...";
$agent_config = $session->CreateAgentConfig( 'spsapacheagent-settings',
                                            'Secure Proxy UI Agent Configuration Object'
                            );
if(!defined $agent_config) {
    die "\nFATAL: Unable to create Agent Configuration Object \'spsapacheagent-settings\'\n";
}

$agent_name_assoc = $agent_config->AddAssociation('AgentName', 'spsapacheagent', 0);
if(!defined $agent_name_assoc) {
    die "\nFATAL: Unable to create AgentName association\n";
}

$default_agent_name_assoc = $agent_config->AddAssociation('DefaultAgentName', 'spsapacheagent', 0);
if(!defined $default_agent_name_assoc) {
    die "\nFATAL: Unable to create DefaultAgentName association\n";
}

$agent_config->AddAssociation('DefaultAgentName', 'spsapacheagent', 0);

@default_agent_associations = $default_agent_config->GetAssociations() ;
foreach $association(@default_agent_associations) {
    print "\t".$association->Name()."=".$association->Value()."\n";
    $agent_config->AddAssociation($association->Name(), $association->Value(), 0);
}

print "done\n";


