#!/bin/bash

N=100

rm -rf ./results
mkdir ./results

echo "Starting"
./node_exporter.sh > results/node_exporter.log 2>&1 &
PID=$!
sleep 5

for i in $(seq 1 $N)
do
    echo "Request $i"
    curl localhost:9100/metrics >> results/benchmark.log
    sleep 1
done

kill $PID

