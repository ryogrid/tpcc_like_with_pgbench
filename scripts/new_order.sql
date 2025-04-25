\set w_id random(1, 10)
\set d_id random(1, 10)
\set c_id random(1, 3000)
\set i_id1 random(1, 10000)
\set i_id2 random(1, 10000)
\set qty1 random(1, 5)
\set qty2 random(1, 5)

BEGIN;
INSERT INTO orders (o_d_id, o_w_id, o_c_id) VALUES (:d_id, :w_id, :c_id);
SELECT lastval() AS last_id;
\gset
\set o_id :last_id
SELECT i_price FROM item WHERE i_id = :i_id1;
\gset
\set price1 :i_price
INSERT INTO order_line VALUES (:o_id, 1, :i_id1, :w_id, :qty1, :price1 * :qty1);
UPDATE stock SET s_quantity = s_quantity - :qty1 WHERE s_i_id = :i_id1 AND s_w_id = :w_id;
SELECT i_price FROM item WHERE i_id = :i_id2;
\gset
\set price2 :i_price
INSERT INTO order_line VALUES (:o_id, 2, :i_id2, :w_id, :qty2, :price2 * :qty2);
UPDATE stock SET s_quantity = s_quantity - :qty2 WHERE s_i_id = :i_id2 AND s_w_id = :w_id;
COMMIT;