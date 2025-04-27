\set w_id random(1, :scale)
BEGIN;
CALL tpcc_stock_level(:w_id);
COMMIT;
