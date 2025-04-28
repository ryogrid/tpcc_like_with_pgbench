\set w_id (:client_id + 1)
BEGIN;
CALL tpcc_new_order(:w_id);
COMMIT;
