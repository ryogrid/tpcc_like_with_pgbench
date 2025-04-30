\set w_id (:client_id + 1)
BEGIN;
CALL tpcc_stock_level(:w_id);
COMMIT;
