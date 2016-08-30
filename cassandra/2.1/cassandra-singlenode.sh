#!/usr/bin/env bash

# Get running container's IP
IP=`hostname --ip-address`
if [ $# == 1 ]; then SEEDS="$1,$IP";
else SEEDS="$IP"; fi

function init_cluster_name {
	CLUSTER_FILE="/etc/cassandra/cluster_name.txt"

	CLUSTER_NAME=
	if [ -f $CLUSTER_FILE ]; then
		CLUSTER_NAME=$(cat "$CLUSTER_FILE")
	else
    CLUSTER_NAME="Test Cluster $(date +%FT%T.%N%z-$RANDOM)"
    echo $CLUSTER_NAME > $CLUSTER_FILE
	fi
}

init_cluster_name

# From spotify/cassandra-base
sed -i -e "s/num_tokens/\#num_tokens/" $CASSANDRA_CONFIG/cassandra.yaml

# Based on spotify/cassandra-singlenode
# 0.0.0.0 Listens on all configured interfaces
# but you must set the broadcast_rpc_address to a value other than 0.0.0.0
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/" $CASSANDRA_CONFIG/cassandra.yaml
sed -i -e "s/^# broadcast_rpc_address:.*/broadcast_rpc_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# With virtual nodes disabled, we need to manually specify the token
echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.initial_token=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# Pointless in one-node cluster, saves about 5 sec waiting time
echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.skip_wait_for_gossip_to_settle=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# Most likely not needed
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# Start of our own logic
# Required for a single node cluster. Otherwise, the node feel alone and commit suicide.
echo "auto_bootstrap: false" >> $CASSANDRA_CONFIG/cassandra.yaml
# Required to prevent node from connecting with each other. We also rely on the seed being 127.0.0.1 (default)
sed -i -e "s/^cluster_name:.*/cluster_name: '$CLUSTER_NAME'/" $CASSANDRA_CONFIG/cassandra.yaml

exec cassandra -f