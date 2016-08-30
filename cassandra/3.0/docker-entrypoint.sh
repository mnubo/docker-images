#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
  set -- cassandra -f "$@"
fi

CLUSTER_FILE="/etc/cassandra/cluster_name.txt"
function init_cluster_name {
  CLUSTER_NAME=
  if [ -f $CLUSTER_FILE ]; then
    CLUSTER_NAME=$(cat "$CLUSTER_FILE")
  else
    CLUSTER_NAME="Test Cluster $(date +%FT%T.%N%z-$RANDOM)"
    echo $CLUSTER_NAME > $CLUSTER_FILE
  fi
}

init_cluster_name

# Cluster name must be persisted
CASSANDRA_CLUSTER_NAME=$(cat "$CLUSTER_FILE")
# No need to have multiple
CASSANDRA_NUM_TOKENS=1
# Make sure to start Thrift
CASSANDRA_START_RPC=true
# Help with docker commit during a compaction corrupting the image
CASSANDRA_COMMITLOG_SYNC_PERIOD_IN_MS=300000
# From prod
CASSANDRA_BATCH_SIZE_WARN_THRESHOLD_IN_KB=64
CASSANDRA_BATCH_SIZE_FAIL_THRESHOLD_IN_KB=10240

# allow the container to be started with `--user`
if [ "$1" = 'cassandra' -a "$(id -u)" = '0' ]; then
  chown -R cassandra /var/lib/cassandra /var/log/cassandra "$CASSANDRA_CONFIG"
  exec gosu cassandra "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'cassandra' ]; then
  : ${CASSANDRA_RPC_ADDRESS='0.0.0.0'}

  : ${CASSANDRA_LISTEN_ADDRESS='auto'}
  if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
    CASSANDRA_LISTEN_ADDRESS="$(hostname --ip-address)"
  fi

  : ${CASSANDRA_BROADCAST_ADDRESS="$CASSANDRA_LISTEN_ADDRESS"}

  if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
    CASSANDRA_BROADCAST_ADDRESS="$(hostname --ip-address)"
  fi
  : ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

  if [ -n "${CASSANDRA_NAME:+1}" ]; then
    : ${CASSANDRA_SEEDS:="cassandra"}
  fi
  : ${CASSANDRA_SEEDS:="$CASSANDRA_BROADCAST_ADDRESS"}

  echo "CASSANDRA_SEEDS : $CASSANDRA_SEEDS"
  sed -ri 's/(- seeds:) "127.0.0.1"/\1 "'"$CASSANDRA_SEEDS"'"/' "$CASSANDRA_CONFIG/cassandra.yaml"

  for yaml in \
    broadcast_address \
    broadcast_rpc_address \
    cluster_name \
    endpoint_snitch \
    listen_address \
    num_tokens \
    rpc_address \
    start_rpc \
    commitlog_sync_period_in_ms \
    batch_size_warn_threshold_in_kb \
    batch_size_fail_threshold_in_kb \
  ; do
    var="CASSANDRA_${yaml^^}"
    val="${!var}"
    echo "$var : $val"
    if [ "$val" ]; then
      sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CONFIG/cassandra.yaml"
    fi
  done

  # for yaml in \
  #   attributes_to_disable \
  # ; do
  #   var="CASSANDRA_${yaml^^}"
  #   val="${!var}"
  #   echo "Disabling $var"
  #   if [ "$val" ]; then
  #     sed -ri 's/^(# )?('"$yaml"':.*)/#\2/' "$CASSANDRA_CONFIG/cassandra.yaml"
  #   fi
  # done

  for rackdc in dc rack; do
    var="CASSANDRA_${rackdc^^}"
    val="${!var}"
    if [ "$val" ]; then
      sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "$CASSANDRA_CONFIG/cassandra-rackdc.properties"
    fi
  done
fi

# Forcing single node
export JVM_EXTRA_OPTS="-Dcassandra.initial_token=0 -Dcassandra.skip_wait_for_gossip_to_settle=0 -Djava.rmi.server.hostname=$CASSANDRA_LISTEN_ADDRESS"
export MAX_HEAP_SIZE=512M
export HEAP_NEWSIZE=100M

exec "$@"