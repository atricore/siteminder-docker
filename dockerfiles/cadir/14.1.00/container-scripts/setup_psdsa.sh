#!/bin/bash
source /opt/CA/Directory/dxserver/install/.dxprofile 
/opt/CA/Directory/dxserver/bin/dxnewdb psdsa
/opt/CA/Directory/dxserver/bin/dxserver start psdsa
ldapadd -h dx -p 7777 -x -f /tmp/cadir_temp/setup.ldif
ldapadd -h dx -p 7777 -x -f /tmp/cadir_temp/sgonzalez.ldif