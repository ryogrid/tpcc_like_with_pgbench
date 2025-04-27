\set w_id random(1, :scale)
BEGIN;
CALL tpcc_order_status(:w_id);
COMMIT;
