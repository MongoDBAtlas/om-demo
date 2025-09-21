FROM amd64/ubuntu:22.04

# critical depencencies
RUN apt update && apt install -y net-tools xterm vim

ARG OMFILE=mongodb-mms-8.0.14.500.20250915T2014Z.amd64.deb
ADD https://downloads.mongodb.com/on-prem-mms/deb/${OMFILE} /tmp/${OMFILE}
RUN apt install -y /tmp/${OMFILE} &&\
    apt autoremove && apt clean &&\
    rm -f /tmp/${OMFILE}

# configure om
ARG appdb_user=pm
ARG appdb_pwd=pm1234
ARG omCentralUrl=http://om:8080
ARG CONFFILE=/opt/mongodb/mms/conf/conf-mms.properties
    ## appDB connection string
RUN sed -i "s#\(^.*//\)127.0.0.1:27017\(.*\)#\1${appdb_user}:${appdb_pwd}@appdb1,appdb2,appdb3\2#" ${CONFFILE} &&\
    ## OM central URL for agents to connect to
    echo "mms.centralUrl=${omCentralUrl}" >> ${CONFFILE} &&\
    ## OM DB URI
    echo "mongo.mongoUri=mongodb://${appdb_user}:${appdb_pwd}@appdb1,appdb2,appdb3" >> ${CONFFILE} &&\
    ## ignore initial UI setup
    echo "mms.ignoreInitialUiSetup=true" >> ${CONFFILE} &&\
    ## pass pre-flight check without UI setup
    echo "mms.fromEmailAddr=om@localhost" >> ${CONFFILE} &&\
    echo "mms.replyToEmailAddr=om@localhost" >> ${CONFFILE} &&\
    echo "mms.adminEmailAddr=om@localhost" >> ${CONFFILE} &&\
    echo "mms.mail.transport=smtp" >> ${CONFFILE} &&\
    echo "mms.mail.hostname=localhost" >> ${CONFFILE} &&\
    echo "mms.mail.port=25" >> ${CONFFILE}

COPY --chown=mongodb-mms:mongodb-mms ./conf/om.gen.key /etc/mongodb-mms/gen.key