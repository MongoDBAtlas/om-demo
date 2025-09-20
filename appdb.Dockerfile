FROM mongodb/mongodb-enterprise-server:8.2-ubi8

COPY --chown=mongod:mongod ./conf/rsAuthKey /var/lib/mongo/rsAuthKey
RUN chmod 400 /var/lib/mongo/rsAuthKey