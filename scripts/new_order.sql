\set w_id random(1, :scale)
BEGIN;
CALL tpcc_new_order(:w_id);
COMMIT;
