# Docker Images for CA Siteminder

## Overview 

This repository contains [Dockerfiles](https://docs.docker.com/engine/reference/builder/) and [Ansible](https://ansible.com) configuration
to build and configure [Docker](https://www.docker.com/what-docker) images for CA Siteminder.

## CA Siteminder software download

Building these images will require downloading CA Siteminder 12.8 software from [Broadcom](https://www.broadcom.com/products/cyber-security/identity/siteminder) before installation.

In every 'install' folder there is a README.txt file specifying which CA Siteminder files should be placed in that directory. Move the downloaded software to the corresponding 'install' folder. 

## Build

From the root of the project run the following command :
```console
$ docker-compose up --build
```

## Host entry

Add an entry in your host file for binding 'extapp' to the local interface :
``` 
127.0.0.1 extapp
```

## Access protected resource

a) Open a protected resource: http://extapp:9090/private/

b) Sign-in using 'admin' as the username and 'secret' as the password.

c) The protected resource comprising a dump of the Http request will be displayed 

## Accessing the Policy Server Administrative UI

Open the 'https://localhost:8443/iam/siteminder/adminui' page and sign in with siteminder/siteminder (leave the policy server field blank).

## Accessing the Access Gateway (SPS) Administration console

Add an entry in your host file for binding 'ag' to the local interface :
``` 
127.0.0.1 ag
```

Then, open 'http://ag:9191/proxyui' and sign in using 'admin' as the username, and 'secret' as the password.

## Questions / Issues
If you got any questions or problems using the image, please visit our [Github Repository](https://github.com/atricore/siteminder-docker) and write an issue.

## Sponsors

This project is sponsored Atricore - No Code Identity and Access Management :

<a href="https://atricore.com"><img src="https://uploads-ssl.webflow.com/611d67401a94b9fb36e5b81f/611d6c7ea44ebe1b8ecd9d0c_atricore-logo.svg" width="320" /></a>
