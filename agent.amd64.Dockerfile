FROM ubuntu:24.04

# critical depencencies
RUN apt update && apt install -y net-tools vim

# prerequisites for automation agent for EA installation
RUN apt install -y \
    libcurl4 libgssapi-krb5-2 libldap2 liblzma5 \
    libsasl2-2 libsasl2-modules \
    libsasl2-modules-gssapi-mit libwrap0 openssl

# install OM agent
ARG ADEB=http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.ubuntu2404.deb
ADD ${ADEB} /tmp/agent.deb
RUN apt install -y /tmp/agent.deb &&\
    apt autoremove && apt clean &&\
    rm -f /tmp/agent.deb

# configure agent
ARG CONFFILE=/etc/mongodb-mms/automation-agent.config
ARG mmsGroupId
ARG mmsApiKey
RUN sed -i "s@.*mmsGroupId=.*@mmsGroupId=${mmsGroupId}@" ${CONFFILE} &&\
    sed -i "s@.*mmsApiKey=.*@mmsApiKey=${mmsApiKey}@" ${CONFFILE} &&\
    sed -i "s@.*mmsBaseUrl=.*@mmsBaseUrl=http://om:8080@" ${CONFFILE} &&\
    mkdir -p /data &&\
    mkdir -p /var/run/mongodb-mms-automation &&\
    echo 'PATH=/var/lib/mongodb-mms-automation/bin:$PATH' >> /root/.bashrc

COPY --chown=mongodb:mongodb ./conf/agent_start.sh /opt/mongodb-mms-automation