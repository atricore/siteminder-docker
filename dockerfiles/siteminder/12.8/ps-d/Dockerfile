FROM atricore/sm-ps:12.8
#
ENV PS_ZIP=ps-12.8-sp05-linux-x86-64.zip \
    ADMINUI_PRE_REQ_ZIP=adminui-pre-req-12.8-sp05-linux-x86-64.zip \
    ADMINUI_ZIP=adminui-12.8-sp05-linux-x86-64.zip \
    SDK_ZIP=smsdk-12.8-sp05-linux-x86-64.zip \
    BASE_DIR=/opt/CA/siteminder \
    INSTALL_TEMP=/tmp/sm_temp

ENV SCRIPT_DIR=${INSTALL_TEMP}/dockertools 

COPY --chown=smuser:smuser container-scripts/* ${SCRIPT_DIR}/
RUN chmod +x ${SCRIPT_DIR}/*.sh