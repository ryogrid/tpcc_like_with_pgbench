\set w_id (:client_id + 1)
BEGIN;
CALL tpcc_payment(:w_id);
COMMIT;
