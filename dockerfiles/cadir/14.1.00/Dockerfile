FROM centos:8
#
#
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
#
ENV CADIR_TGZ=cadir14.1.00_linux_x86_64_directory.tar.gz \
    BASE_DIR=/opt/CA/Directory \
    INSTALL_TEMP=/tmp/cadir_temp 

ENV SCRIPT_DIR=${INSTALL_TEMP}/dockertools 

# Installation of OS packages
# ----------------------------------------------------------------
RUN yum install -y which unzip rng-tools java-1.8.0-openjdk-1.8.0.292.b10-1.el8_4.x86_64 ksh python2 openldap-clients openssh-server && \
    ln -s /usr/bin/python2 /usr/local/bin/python

RUN groupadd etrdir && \
    useradd dsa -g etrdir

# Increase entropy
# ----------------
RUN mv /dev/random /dev/random.org && \
    ln -s /dev/urandom /dev/random

USER root

# Copy packages and scripts
# -------------------------
COPY container-scripts/* ${SCRIPT_DIR}/
COPY install/* ${INSTALL_TEMP}/
COPY cadir_install_responses.properties ${INSTALL_TEMP}/
COPY config/siteminder/ps/ldif/* ${INSTALL_TEMP}/
COPY config/siteminder/contoso/ldif/* ${INSTALL_TEMP}/

RUN chmod +x ${SCRIPT_DIR}/setup_psdsa.sh

# Install CA Directory
# -------------------------
RUN tar zxvf ${INSTALL_TEMP}/${CADIR_TGZ} -C ${INSTALL_TEMP}

WORKDIR ${INSTALL_TEMP}/dxserver/install

RUN ./dxsetup.sh -responsefile ${INSTALL_TEMP}/cadir_install_responses.properties

# Copy Siteminder Policy Server configuration and database files
COPY --chown=dsa:etrdir config/siteminder/ps/config/schema/netegrity.dxc /opt/CA/Directory/dxserver/config/schema
COPY --chown=dsa:etrdir config/siteminder/ps/config/schema/etrust.dxc /opt/CA/Directory/dxserver/config/schema
COPY --chown=dsa:etrdir config/siteminder/ps/config/schema/psdsa.dxg /opt/CA/Directory/dxserver/config/schema
COPY --chown=dsa:etrdir config/siteminder/ps/config/servers/psdsa.dxi /opt/CA/Directory/dxserver/config/servers
COPY --chown=dsa:etrdir config/siteminder/ps/config/limits/psdsa.dxc /opt/CA/Directory/dxserver/config/limits
COPY --chown=dsa:etrdir config/siteminder/ps/config/knowledge/psdsa.dxc /opt/CA/Directory/dxserver/config/knowledge
COPY --chown=dsa:etrdir config/siteminder/ps/data/psdsa.db /opt/CA/Directory/dxserver/data

# Setup SSH access
# ----------------
RUN rm -f /run/nologin && \
    mkdir /var/run/sshd && \
    ssh-keygen -A && \
    sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
    grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

USER dsa

RUN mkdir ~dsa/.ssh && \
    chmod 700 ~dsa/.ssh && \
    ssh-keygen -A && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCun+DcAcmQ3FC4gFxOg9yeGbHSnWZLjdNctoypPs9pYy4r6U5UCywQeiLO2WInjJt1tIY78+ahyVqdZ4kI2pFbcbcEsxcp8pcDI1HYHDS+7cDx7NkFROQEOqf32EyIERIbkbE0W5POY2gr7XwksXJhEY7yMHm7dHgF30OzIzi8f3kSeMcgH1wTkOzTMCCKlgCtiw/lQsy25z6ba9mTsvcvXlIo6IQ55CtHNvPsCxZIZbPs5xr/QWbhVgfs608FSengjPGDE/0Qou+h3BVAo4vpDi0O4WhzTV0mEP0z3r6DzwneaaRvajGNUzjBOcz1Eb7i0vCAOY1k5zwzT2n8HRDjx/qn10qujoETYbs2CHaRoyEbcQKsanVNuSHpBlUZo1aTbznhyBJipbdfh9HvNfEOEgkTH7c36OonJ/CmoFJvc0rldgYYZfHQfpQWFWDLY+eLPFFft0DD2lNCjm/cCOcVccTx1muP7gpg5Bu2PFRPJXs63HJlXh1hnjvK0XXoI1U= gianluca@Gianlucas-MacBook-Pro-2.local" >> ~dsa/.ssh/authorized_keys

USER root 
CMD ["/usr/sbin/sshd", "-D"]