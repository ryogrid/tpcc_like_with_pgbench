\set w_id random(1, 10)
\set d_id random(1, 10)

BEGIN;
SELECT COUNT(*) AS low_stock
FROM stock
WHERE s_w_id = :w_id AND s_quantity < 20;
COMMIT;