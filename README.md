# Node exporter Throughput Benchmark

Notes to myself:

## Versions:
We have two versions:

- `main`: benchmarks all iterations without taking measurements to get maximum throughput
- `precise`: takes a measurement between each metric collect, thus reducing overall performance. Useful to get latency jitter.

## Call stack CPU (`/proc`):

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

## INSTALL

we get a bunch of errors if we try to reinsert the same `/proc` values into the internal metrics hashmap again. Unfortunately, those errors could very much impact the measured performance. Thus, we have to patch them out and allow for bad inserts.

I couldn't manage to fork and replace [`prometheus/client_golang`](https://github.com/prometheus/client_golang), so please patch it yourself:

0. Install all dependencies and do an initial build: `make build`
1. Search for `"collected metric %q { %s} was collected before with the same name and label values"` in your `~/go/pkg`. For me, it shouwed to
   `pkg/mod/github.com/prometheus/client_golang@v1.17.0/prometheus/registry.go:942` in the function `checkMetricConsistency`
   It looks something like
   ```
if _, exists := metricHashes[hSum]; exists {
  return fmt.Errorf(
    "collected metric %q { %s} was collected before with the same name and label values",
     name, dtoMetric,
  )
}
   ```
   Comment out the return.
2. rebuild: `make build`
   you can find out whether it worked by adding a print somewhere there :)
