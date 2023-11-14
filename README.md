# Node exporter Throughput Benchmark

Notes to myself:

Call stack CPU (`/proc`):

```
cpu_linux.go::cpuCollector.Update
^
|
collector.go::execute
^
|
collector.go::NodeCollector.Collect
^
|
prometheus/client_golang@v1.17.0/prometheus/registry.go::Registry.Gather
^
|
????
^
|
http handler in main node exporter file
```

We basically have 2 ways to benchmark this: Microbenchmarking (isolating) and e2e benchmarking.

So there are two theoretical possibilities to isolate what we want to microbench:
1. metric gathering
2. metric gathering + `net/http` overhead (but no transfer overhead)

I think 2. doesn't make sense, because the localhost transfer overhead is so low that we can use the more realistic e2e benchmarking instead.

For e2e benchmarking a load generator such as [wrk](https://github.com/wg/wrk) ([go version](https://github.com/tsliwowicz/go-wrk)) or your own cURL wrapper running against the default build can be used.

The main difficulty of the microbenchmarking is getting the whole initial state set up realistically, especailly since much of it is hidden behind other packages (see call stack above). No way I will figure that out.


Instead, we start `node_exporter` normally, call `/metrics` once and then benchmark `collector.go::NodeCollector.Collect` in that running process :D
