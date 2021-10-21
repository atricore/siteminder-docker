# # Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# #
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# #
# # Author: Kaushik C
# #
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Access Manager 12.2.1.4.0
#
#
# Base image of this dockerfile is the FMW Infrastructure 12.2.1.4.0 docker image.
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# See oam.download file in the install directory
# fmw_12.2.1.4.0_idm_generic.jar & 
#
# Pull base image
# ---------------
#FROM registry.access.redhat.com/ubi8/ubi:8.1 as base
FROM centos:8
#
#
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
#
ENV AG_ZIP=ag-12.8-sp05-linux-x86-64.zip \
    BASE_DIR=/opt/CA/secure-proxy \
    ETC_DIR=/opt/etc \
    INSTALL_TEMP=/tmp/sp_temp \
    SCRIPT_DIR=/tmp/sp_temp/dockertools 

#
# Creation of User, Directories and Installation of OS packages
# ----------------------------------------------------------------
RUN yum install -y which unzip rng-tools  java-1.8.0-openjdk-devel-1:1.8.0.292.b10-1.el8_4.x86_64 ksh openldap-clients openssh-server xauth
RUN groupadd smuser && \
    useradd smuser -g smuser
RUN mkdir -p ${BASE_DIR} && \
    chmod a+xr ${BASE_DIR} && \ 
    chown smuser:smuser ${BASE_DIR} && \
    mkdir -p ${ETC_DIR} && \
    chmod a+xr ${ETC_DIR} && \ 
    chown smuser:smuser ${ETC_DIR} 

RUN mkdir -p ${INSTALL_TEMP} && \
    chmod a+xr ${INSTALL_TEMP} && chown smuser:smuser ${INSTALL_TEMP} 

# Setup SSH access
# ----------------
USER smuser 

RUN mkdir /home/smuser/.ssh && \
    chmod 700 /home/smuser/.ssh && \
    ssh-keygen -A && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCun+DcAcmQ3FC4gFxOg9yeGbHSnWZLjdNctoypPs9pYy4r6U5UCywQeiLO2WInjJt1tIY78+ahyVqdZ4kI2pFbcbcEsxcp8pcDI1HYHDS+7cDx7NkFROQEOqf32EyIERIbkbE0W5POY2gr7XwksXJhEY7yMHm7dHgF30OzIzi8f3kSeMcgH1wTkOzTMCCKlgCtiw/lQsy25z6ba9mTsvcvXlIo6IQ55CtHNvPsCxZIZbPs5xr/QWbhVgfs608FSengjPGDE/0Qou+h3BVAo4vpDi0O4WhzTV0mEP0z3r6DzwneaaRvajGNUzjBOcz1Eb7i0vCAOY1k5zwzT2n8HRDjx/qn10qujoETYbs2CHaRoyEbcQKsanVNuSHpBlUZo1aTbznhyBJipbdfh9HvNfEOEgkTH7c36OonJ/CmoFJvc0rldgYYZfHQfpQWFWDLY+eLPFFft0DD2lNCjm/cCOcVccTx1muP7gpg5Bu2PFRPJXs63HJlXh1hnjvK0XXoI1U= gianluca@Gianlucas-MacBook-Pro-2.local" >> /home/smuser/.ssh/authorized_keys

USER root

RUN rm -f /run/nologin && \
    mkdir /var/run/sshd && \
    ssh-keygen -A && \
    sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
    grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# Increase entropy
# ----------------
RUN mv /dev/random /dev/random.org && \
    ln -s /dev/urandom /dev/random

# Copy packages and scripts
# -------------------------
COPY --chown=smuser:smuser install/* ${INSTALL_TEMP}/
COPY --chown=smuser:smuser ca-sps-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser ca-sps-config-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser container-scripts/* ${SCRIPT_DIR}/
COPY --chown=smuser:smuser forms/* ${INSTALL_TEMP}/
COPY --chown=smuser:smuser server.conf ${INSTALL_TEMP}/
COPY --chown=smuser:smuser proxyrules.xml ${INSTALL_TEMP}/

RUN chmod +x ${SCRIPT_DIR}/*.sh

USER smuser

# Install CA Access Gateway 
# --------------------------
# Note: the setup_ag.sh script will fail if the HCO has alreafy been registered. If this is the case, disable registration by 
# setting the HOST_REGISTRATION_YES attribute in the ca-sps-config-installer.properties to '0':
# HOST_REGISTRATION_YES=1
#
# Note: Upon completing the configuration, it launches the Apache reverse proxy and Tomcat servers.
#
# Note: for starting and stopping the CA SPS (Access Gateway) use the sps-ctl script located in the
# /opt/CA/secure-proxy/default/proxy-engine directory.
#
RUN unzip ${INSTALL_TEMP}/${AG_ZIP} -d ${INSTALL_TEMP} && \
    chmod +x ${INSTALL_TEMP}/ca-proxy-12.8-sp05-linux-x86-64.bin && \
    ${INSTALL_TEMP}/ca-proxy-12.8-sp05-linux-x86-64.bin -i silent -f ${INSTALL_TEMP}/ca-sps-installer.properties 

RUN cp ${INSTALL_TEMP}/k8slogin.fcc /opt/CA/secure-proxy/default/proxy-engine/examples/forms 

USER root

# Define default command to start bash.
CMD ["/usr/sbin/sshd", "-D"]