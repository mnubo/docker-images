# Derived from official cassandra image taken from https://github.com/docker-library/cassandra/blob/master/2.1/Dockerfile
# Main changes: remove volume, conflate RUN statements to decrease number of layers
FROM mnubo/jre8:u91

ENV CASSANDRA_VERSION 2.1.14
ENV CASSANDRA_CONFIG /etc/cassandra

ENV MAX_HEAP_SIZE=512M
ENV HEAP_NEWSIZE=100M

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C && \
    echo 'deb http://www.apache.org/dist/cassandra/debian 21x main' >> /etc/apt/sources.list.d/cassandra.list && \
    apt-get update && \
	  apt-get install -y procps cassandra="$CASSANDRA_VERSION" && \
	  rm -rf /var/lib/apt/lists/* && \
    sed -ri 's/^(rpc_address:).*/\1 0.0.0.0/' "$CASSANDRA_CONFIG/cassandra.yaml" && \    
    rm -f /etc/security/limits.d/cassandra.conf && \
    apt-get clean all

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

ADD cassandra-singlenode.sh /usr/local/bin/cassandra-singlenode

ENTRYPOINT ["cassandra-singlenode"]
