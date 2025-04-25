\set w_id random(1, 10)
\set d_id random(1, 10)

BEGIN;
SELECT o_id FROM orders WHERE o_w_id = :w_id AND o_d_id = :d_id ORDER BY o_id ASC LIMIT 1;
\gset
UPDATE order_line SET ol_amount = ol_amount + 0 WHERE ol_o_id = :o_id;
COMMIT;