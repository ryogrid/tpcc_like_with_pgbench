\set w_id (:client_id + 1)
BEGIN;
CALL tpcc_order_status(:w_id);
COMMIT;
