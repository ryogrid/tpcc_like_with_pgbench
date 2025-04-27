\set w_id random(1, :scale)
BEGIN;
CALL tpcc_delivery(:w_id);
COMMIT;
