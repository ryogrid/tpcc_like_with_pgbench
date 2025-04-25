\set c_id random(1, 3000)

BEGIN;
SELECT o_id, o_entry_d
FROM orders
WHERE o_c_id = :c_id
ORDER BY o_entry_d DESC
LIMIT 1;
COMMIT;