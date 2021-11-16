FROM centos:8
#
#
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
#
ENV PS_ZIP=ps-12.8-sp05-linux-x86-64.zip \
    ADMINUI_PRE_REQ_ZIP=adminui-pre-req-12.8-sp05-linux-x86-64.zip \
    ADMINUI_ZIP=adminui-12.8-sp05-linux-x86-64.zip \
    SDK_ZIP=smsdk-12.8-sp05-linux-x86-64.zip \
    BASE_DIR=/opt/CA/siteminder \
    INSTALL_TEMP=/tmp/sm_temp

ENV SCRIPT_DIR=${INSTALL_TEMP}/dockertools 

#
# Creation of User, Directories and Installation of OS packages
# ----------------------------------------------------------------
RUN yum install -y which unzip rng-tools java-1.8.0-openjdk-1.8.0.292.b10-1.el8_4.x86_64 ksh openldap-clients openssh-server openssh-clients rsync tmux xauth libnsl
RUN groupadd smuser && \
    useradd smuser -g smuser
RUN mkdir -p ${BASE_DIR} && \
    chmod a+xr ${BASE_DIR} && \ 
    chown smuser:smuser ${BASE_DIR} 
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
COPY --chown=smuser:smuser ca-ps-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser prerequisite-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser smwamui-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser sdk-installer.properties ${INSTALL_TEMP}/
COPY --chown=smuser:smuser sm.registry ${INSTALL_TEMP}/
COPY --chown=smuser:smuser container-scripts/* ${SCRIPT_DIR}/
RUN chmod +x ${SCRIPT_DIR}/*.sh

USER smuser

# Install Policy Server
# -------------------------
RUN unzip ${INSTALL_TEMP}/${PS_ZIP} -d ${INSTALL_TEMP} && \
    chmod +x ${INSTALL_TEMP}/ca-ps-12.8-sp05-linux-x86-64.bin && \
    ${INSTALL_TEMP}/ca-ps-12.8-sp05-linux-x86-64.bin -i silent -f ${INSTALL_TEMP}/ca-ps-installer.properties

RUN cp ${INSTALL_TEMP}/smreg /opt/CA/siteminder/bin && \
    cp ${INSTALL_TEMP}/sm.registry /opt/CA/siteminder/registry/sm.registry

RUN echo ". /opt/CA/siteminder/ca_ps_env.ksh" >> /home/smuser/.bash_profile

# Install Administrative Interface Prerequisites
# -----------------------------------------------
RUN unzip ${INSTALL_TEMP}/${ADMINUI_PRE_REQ_ZIP} -d ${INSTALL_TEMP} && \
    chmod +x ${INSTALL_TEMP}/adminui-pre-req-12.8-sp05-linux-x86-64.bin && \
    ${INSTALL_TEMP}/adminui-pre-req-12.8-sp05-linux-x86-64.bin -i silent -f ${INSTALL_TEMP}/prerequisite-installer.properties

# Install Administrative Interface
# -----------------------------------------------
RUN unzip ${INSTALL_TEMP}/${ADMINUI_ZIP} -d ${INSTALL_TEMP} && \
    chmod +x ${INSTALL_TEMP}/ca-adminui-12.8-sp05-linux-x86-64.bin && \
    ${INSTALL_TEMP}/ca-adminui-12.8-sp05-linux-x86-64.bin -i silent -f ${INSTALL_TEMP}/smwamui-installer.properties

# Install the SDK
# -----------------------------------------------
RUN unzip ${INSTALL_TEMP}/${SDK_ZIP} -d ${INSTALL_TEMP} && \
    chmod +x ${INSTALL_TEMP}/ca-sdk-12.8-sp05-linux-x86-64.bin && \
    ${INSTALL_TEMP}/ca-sdk-12.8-sp05-linux-x86-64.bin -i silent -f ${INSTALL_TEMP}/sdk-installer.properties

# Important note: Make sure to SSH and run the setup_ps.sh script for registering the adminitrative UI with the policy server. 
#                 *This has to be performed only once*

# Define default command to start bash.
USER root 
CMD ["/usr/sbin/sshd", "-D"]
