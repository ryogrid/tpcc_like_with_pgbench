\set w_id random(1, :scale)
BEGIN;
CALL tpcc_payment(:w_id);
COMMIT;
