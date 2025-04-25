#!/bin/bash
echo "Initializing..."
psql -f init/01_init_schema.sql
psql -f init/02_load_data.sql
echo "Running benchmark..."
pgbench -n -f scripts/new_order.sql -c 10 -j 4 -T 600 tpcc
echo "Estimating tpmC..."
bash analyze/estimate_tpmc.sh
