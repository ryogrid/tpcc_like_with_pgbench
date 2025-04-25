# TPC-C Like Benchmark for PostgreSQL

This repository contains a simplified version of the TPC-C benchmark using `pgbench` custom scripts.

## Structure
- `init/`: Schema and data loader
- `scripts/`: Benchmark transaction scripts (New Order, Payment, Delivery)
- `analyze/`: Utilities to estimate tpmC
- `run.sh`: One-click init and benchmark

## Usage
```bash
./run.sh
```

Ensure that the database `tpcc` is available and `pgbench` is installed.
