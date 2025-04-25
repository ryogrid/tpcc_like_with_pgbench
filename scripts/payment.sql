\set w_id random(1, 10)
\set d_id random(1, 10)
\set c_id random(1, 3000)
\set amount random_gaussian(1, 5000, 200)

BEGIN;
UPDATE customer SET c_balance = c_balance + :amount WHERE c_id = :c_id;
COMMIT;