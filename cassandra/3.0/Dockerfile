# Derived from official cassandra image taken from https://github.com/docker-library/cassandra/blob/master/3.0/Dockerfile
# Main changes: remove volume, conflate RUN statements to decrease number of layers
FROM debian:jessie-backports

ENV CASSANDRA_VERSION 3.0.8
# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
ENV CASSANDRA_CONFIG /etc/cassandra

# groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra: explicitly set user/group IDs
# sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/cassandra-env.sh: https://issues.apache.org/jira/browse/CASSANDRA-11661

RUN groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra \
  && set -x \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y --auto-remove ca-certificates wget \
  && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C \
  && echo 'deb http://www.apache.org/dist/cassandra/debian 30x main' >> /etc/apt/sources.list.d/cassandra.list \
  && apt-get update \
  && apt-get install -y cassandra="$CASSANDRA_VERSION" \
  && rm -rf /var/lib/apt/lists/* \
  && sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/cassandra-env.sh \
  && mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
  && chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
  && chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG" \
  && echo "auto_bootstrap: false" >> $CASSANDRA_CONFIG/cassandra.yaml

COPY docker-entrypoint.sh /docker-entrypoint.sh

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cassandra", "-f"]