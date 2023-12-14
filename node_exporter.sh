#!/bin/bash

# If not set default
if [ -z "$NUMBER_OF_PROCESSES" ]; then
    echo "DEFAULTING TO NUMBER_OF_PROCESSES=1"
    NUMBER_OF_PROCESSES=1
fi

echo "Starting Node Exporter with NUMBER_OF_PROCESSES=${NUMBER_OF_PROCESSES}"

./node_exporter --collector.disable-defaults \
  --collector.cpu \
  --collector.cpufreq \
  --collector.infiniband \
  --collector.meminfo \
  --collector.netdev \
  --collector.vmstat \
  --web.max-requests=0 \
  --runtime.gomaxprocs=${NUMBER_OF_PROCESSES}
