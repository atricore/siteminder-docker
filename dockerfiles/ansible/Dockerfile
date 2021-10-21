FROM alpine:3.11
RUN apk add --no-cache openssh-client ansible git

RUN mkdir -p /root/.ssh
COPY ./keys/id_rsa /root/.ssh/id_rsa
COPY ./keys/id_rsa.pub /root/.ssh/id_rsa.pub

RUN chmod 600 /root/.ssh/id_rsa \
 && chmod 640 /root/.ssh/id_rsa.pub \
 && echo "Host *" > /root/.ssh/config && echo " StrictHostKeyChecking no" >> /root/.ssh/config

COPY ./requirements.yml /ansible/requirements.yml
COPY ./servers.yml /ansible/inventories/servers.yml

RUN ansible-galaxy install -n -p /ansible/roles -r /ansible/requirements.yml --ignore-errors

COPY ./ansible /ansible

WORKDIR /ansible

ENTRYPOINT [ "ansible-playbook", "-i", "inventories/servers.yml", "complete-sm-setup.yml" ]
