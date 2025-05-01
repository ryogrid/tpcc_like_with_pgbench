-----------------------------------------------------------------
-- All catalog objects the five procedures need
-----------------------------------------------------------------

-- 1.1  Helper: random last-name generator (TPC-C §4.3.2.3)
--      Converts a number 0-999 into a 3-syllable last name.
CREATE OR REPLACE FUNCTION tpcc_make_last_name(num INT)
RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
WITH base(syll) AS (VALUES
 ('BAR'),('OUGHT'),('ABLE'),('PRI'),('PRES'),('ESE'),
 ('ANTI'),('CALLY'),('ATION'),('EING'))
SELECT (SELECT syll FROM base OFFSET (num/100)::int LIMIT 1) ||
       (SELECT syll FROM base OFFSET ((num/10)%10)::int LIMIT 1) ||
       (SELECT syll FROM base OFFSET (num%10)::int LIMIT 1);
$$;
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE tpcc_schema_create()
LANGUAGE plpgsql
AS $$
BEGIN
    ----------------------------------------------------------------
    -- Drop objects if they exist (so the script is rerunnable)
    ----------------------------------------------------------------
    DROP TABLE IF EXISTS order_line   CASCADE;
    DROP TABLE IF EXISTS new_order    CASCADE;
    DROP TABLE IF EXISTS orders       CASCADE;
    DROP TABLE IF EXISTS history      CASCADE;
    DROP TABLE IF EXISTS customer     CASCADE;
    DROP TABLE IF EXISTS stock        CASCADE;
    DROP TABLE IF EXISTS item         CASCADE;
    DROP TABLE IF EXISTS district     CASCADE;
    DROP TABLE IF EXISTS warehouse    CASCADE;
    DROP SEQUENCE IF EXISTS order_id_seq CASCADE;

    ----------------------------------------------------------------
    -- Tables  (identical to those used in the earlier procedures)
    ----------------------------------------------------------------
    CREATE TABLE warehouse (
        w_id        INTEGER PRIMARY KEY,
        w_name      VARCHAR(10),
        w_street_1  VARCHAR(20),
        w_street_2  VARCHAR(20),
        w_city      VARCHAR(20),
        w_state     CHAR(2),
        w_zip       CHAR(9),
        w_tax       NUMERIC(4,4),
        w_ytd       NUMERIC(12,2)
    );

    CREATE TABLE district (
        d_id         INTEGER,
        d_w_id       INTEGER,
        d_name       VARCHAR(10),
        d_street_1   VARCHAR(20),
        d_street_2   VARCHAR(20),
        d_city       VARCHAR(20),
        d_state      CHAR(2),
        d_zip        CHAR(9),
        d_tax        NUMERIC(4,4),
        d_ytd        NUMERIC(12,2),
        d_next_o_id  INTEGER,
        PRIMARY KEY (d_w_id, d_id),
        -- FOREIGN KEY (d_w_id) REFERENCES warehouse (w_id)
    );

    CREATE TABLE customer (
        c_id           INTEGER,
        c_d_id         INTEGER,
        c_w_id         INTEGER,
        c_first        VARCHAR(16),
        c_middle       CHAR(2),
        c_last         VARCHAR(16),
        c_street_1     VARCHAR(20),
        c_street_2     VARCHAR(20),
        c_city         VARCHAR(20),
        c_state        CHAR(2),
        c_zip          CHAR(9),
        c_phone        CHAR(16),
        c_since        TIMESTAMP,
        c_credit       CHAR(2),
        c_credit_lim   NUMERIC(12,2),
        c_discount     NUMERIC(4,4),
        c_balance      NUMERIC(12,2),
        c_ytd_payment  NUMERIC(12,2),
        c_payment_cnt  INTEGER,
        c_delivery_cnt INTEGER,
        c_data         TEXT,
        PRIMARY KEY (c_w_id, c_d_id, c_id),
        -- FOREIGN KEY (c_w_id, c_d_id) REFERENCES district (d_w_id, d_id)
    );

    CREATE TABLE history (
        h_c_id     INTEGER,
        h_c_d_id   INTEGER,
        h_c_w_id   INTEGER,
        h_d_id     INTEGER,
        h_w_id     INTEGER,
        h_date     TIMESTAMP,
        h_amount   NUMERIC(6,2),
        h_data     VARCHAR(24)
    );

    CREATE TABLE orders (
        o_id         INTEGER,
        o_d_id       INTEGER,
        o_w_id       INTEGER,
        o_c_id       INTEGER,
        o_entry_d    TIMESTAMP,
        o_carrier_id INTEGER,
        o_ol_cnt     INTEGER,
        o_all_local  INTEGER,
        PRIMARY KEY (o_w_id, o_d_id, o_id),
        -- FOREIGN KEY (o_w_id, o_d_id) REFERENCES district (d_w_id, d_id),
        -- FOREIGN KEY (o_w_id, o_d_id, o_c_id)
        --              REFERENCES customer (c_w_id, c_d_id, c_id)
    );

    CREATE TABLE new_order (
        no_o_id  INTEGER,
        no_d_id  INTEGER,
        no_w_id  INTEGER,
        PRIMARY KEY (no_w_id, no_d_id, no_o_id),
        -- FOREIGN KEY (no_w_id, no_d_id, no_o_id)
        --              REFERENCES orders (o_w_id, o_d_id, o_id)
    );

    CREATE TABLE order_line (
        ol_o_id        INTEGER,
        ol_d_id        INTEGER,
        ol_w_id        INTEGER,
        ol_number      INTEGER,
        ol_i_id        INTEGER,
        ol_supply_w_id INTEGER,
        ol_delivery_d  TIMESTAMP,
        ol_quantity    INTEGER,
        ol_amount      NUMERIC(6,2),
        ol_dist_info   CHAR(24),
        PRIMARY KEY (ol_w_id, ol_d_id, ol_o_id, ol_number),
        -- FOREIGN KEY (ol_w_id, ol_d_id, ol_o_id)
        --              REFERENCES orders (o_w_id, o_d_id, o_id)
    );

    CREATE TABLE item (
        i_id     INTEGER PRIMARY KEY,
        i_im_id  INTEGER,
        i_name   VARCHAR(24),
        i_price  NUMERIC(5,2),
        i_data   VARCHAR(50)
    );

    CREATE TABLE stock (
        s_i_id        INTEGER,
        s_w_id        INTEGER,
        s_quantity    INTEGER,
        s_dist_01     CHAR(24), s_dist_02 CHAR(24), s_dist_03 CHAR(24),
        s_dist_04     CHAR(24), s_dist_05 CHAR(24), s_dist_06 CHAR(24),
        s_dist_07     CHAR(24), s_dist_08 CHAR(24), s_dist_09 CHAR(24),
        s_dist_10     CHAR(24),
        s_ytd         INTEGER,
        s_order_cnt   INTEGER,
        s_remote_cnt  INTEGER,
        s_data        VARCHAR(50),
        PRIMARY KEY (s_w_id, s_i_id),
        -- FOREIGN KEY (s_w_id) REFERENCES warehouse (w_id),
        -- FOREIGN KEY (s_i_id) REFERENCES item (i_id)
    );

    CREATE INDEX idx_warehouse ON warehouse (w_id);
    CREATE INDEX idx_distinct ON district (d_id);
    -- CREATE INDEX idx_customer ON customer (c_w_id, c_id);
    CREATE INDEX idx_item ON item (i_id);
    -- CREATE INDEX idx_stock ON stock (s_i_id, s_w_id);
    -- CREATE INDEX idx_new_order ON new_order (no_w_id, no_d_id, no_o_id);
    -- CREATE INDEX idx_orders ON orders (o_w_id, o_d_id, o_c_id);
    -- CREATE INDEX idx_order_line ON order_line (ol_o_id, ol_supply_w_id, ol_i_id, ol_number);

    ----------------------------------------------------------------
    -- Global sequence for o_id (your New-Order procedure uses it)
    ----------------------------------------------------------------
    CREATE SEQUENCE order_id_seq START 1;
END;
$$;

CREATE OR REPLACE PROCEDURE tpcc_load_data(p_scale INT)
LANGUAGE plpgsql
AS $$
DECLARE
    w        INT;
    d        INT;
BEGIN
    IF p_scale < 1 THEN
        RAISE EXCEPTION 'scale factor must be >= 1';
    END IF;

    ----------------------------------------------------------------
    -- (1)  ITEM  – fixed 100 000 rows, loaded once
    ----------------------------------------------------------------
    INSERT INTO item (i_id, i_im_id, i_name, i_price, i_data)
    SELECT i,
           (random()*10000)::INT,
           format('Item-%s', i),
           ((random()*9900 + 100)::NUMERIC)/100,   -- 1.00–100.00
           'FOO'
    FROM generate_series(1, 100000) AS g(i);

    ----------------------------------------------------------------
    -- (2)  Per-warehouse data
    ----------------------------------------------------------------
    FOR w IN 1 .. p_scale LOOP
        ------------------------------------------------------------
        -- 2-A  WAREHOUSE
        ------------------------------------------------------------
        INSERT INTO warehouse
              (w_id, w_name, w_street_1, w_street_2,
               w_city, w_state, w_zip, w_tax, w_ytd)
        VALUES (w, format('Wh%03s', w), 'Street1', 'Street2',
                'City', 'ST', '123456789',
                ((random()*2000)::NUMERIC)/10000,   -- 0.0000–0.2000
                300000.00);

        ------------------------------------------------------------
        -- 2-B  STOCK (100 000 rows / warehouse)
        ------------------------------------------------------------
        INSERT INTO stock
        SELECT i_id, w,
               (random()*91 + 10)::INT,   -- 10-100
               'dist01','dist02','dist03','dist04','dist05',
               'dist06','dist07','dist08','dist09','dist10',
               0, 0, 0, 'data'
        FROM item;   -- leverages the 100 000 rows

        ------------------------------------------------------------
        -- 2-C  DISTRICT, CUSTOMER, HISTORY (10×, 3000×)
        ------------------------------------------------------------
        FOR d IN 1 .. 10 LOOP
            INSERT INTO district
                  (d_id, d_w_id, d_name, d_street_1, d_street_2,
                   d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id)
            VALUES (d, w, format('Dist%02s', d), 'Street1', 'Street2',
                    'City', 'ST', '123456789',
                    ((random()*2000)::NUMERIC)/10000,
                    30000.00,
                    3001);   -- spec: first unused O_ID = 3001

            ----------------------------------------------------------------
            -- CUSTOMER & HISTORY (3 000 rows)
            ----------------------------------------------------------------
            INSERT INTO customer
            SELECT c_id,
                   d, w,
                   format('First%04s', c_id),
                   'OE',
                   tpcc_make_last_name(
                       /* spec NURand(255,0,999) */ ((c_id-1)%1000)),
                   'Street1','Street2','City','ST','123456789',
                   '555-1234', clock_timestamp(),
                   CASE WHEN random()<0.1 THEN 'BC' ELSE 'GC' END,
                   50000.00,        -- credit limit
                   ((random()*5000)::NUMERIC)/10000,  -- discount
                   -10.00,          -- balance
                   10.00,           -- ytd_payment
                   1,               -- payment_cnt
                   0,               -- delivery_cnt
                   'data'
            FROM generate_series(1, 3000) AS gs(c_id);

            INSERT INTO history
            SELECT c_id, d, w,
                   d, w, clock_timestamp(),
                   10.00,
                   'init'
            FROM generate_series(1, 3000) AS gs(c_id);

            ----------------------------------------------------------------
            -- ORDERS (3 000), NEW_ORDER (900), ORDER_LINE (≈ 30 000)
            ----------------------------------------------------------------
            -- Random permutation of C_IDs for the 3 000 orders
            WITH perm(c_id) AS (
               SELECT c_id
                 FROM generate_series(1,3000) g(c_id)
                ORDER BY random())
            INSERT INTO orders
            SELECT o_id, d, w,
                   perm.c_id,
                   clock_timestamp(),
                   CASE WHEN o_id < 2101 THEN (random()*10+1)::INT ELSE NULL END,
                   (random()*11+5)::INT,     -- ol_cnt 5-15
                   1                         -- all_local = 1 at load time
            FROM generate_series(1,3000) g(o_id)
            JOIN perm ON perm.c_id = g.o_id;   -- 1-to-1 mapping

            -- NEW_ORDER rows for O_ID 2101-3000 (i.e., 900 rows)
            INSERT INTO new_order
            SELECT o_id, d, w
              FROM generate_series(2101,3000) g(o_id);

            -- ORDER_LINE rows
            INSERT INTO order_line
            SELECT o_id, d, w,
                   line_no,               -- ol_number
                   (random()*99999+1)::INT,  -- i_id 1-100 000
                   w,                     -- supply_w_id = home wh at load
                   NULL,                  -- delivery_d
                   5,                     -- quantity
                   ((random()*9999+1)::NUMERIC)/100,  -- amount
                   'distinfo'
            FROM generate_series(1,3000) g(o_id)
            CROSS JOIN LATERAL generate_series(1,
                    (SELECT o_ol_cnt FROM orders
                     WHERE o_w_id=w AND o_d_id=d AND o_id=g.o_id)) gs(line_no);
        END LOOP;  -- district
    END LOOP;      -- warehouse
END;
$$;


-- 1.2  Five stored procedures (one per TPC-C transaction)
-----------------------------------------------------------------
-- Notes for all procedures
--   * They run in the caller’s transaction.
--   * All required SELECT … FOR UPDATE locks are taken exactly
--     as the spec (v5.11.0) demands.
--   * Any random choice uses pg’s built-in random() to keep
--     everything server-side.
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE tpcc_new_order(p_w_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_d_id         INT := (floor(random()*10)+1)::INT;      -- 1-10
    v_c_id         INT := (floor(random()*3000)+1)::INT;     -- 1-3000
    v_ol_cnt       INT := (floor(random()*11)+5)::INT;       -- 5-15
    v_remote       INT;                                      -- 1 if any line uses remote warehouse
    v_next_o_id    INT;
    v_i            INT;
    v_item_id      INT;
    v_supply_w_id  INT;
    v_quantity     INT;
    v_amount       NUMERIC;
BEGIN
    -- (a) lock DISTRICT row and fetch d_next_o_id
    SELECT d_next_o_id
      INTO v_next_o_id
      FROM district
     WHERE d_w_id = p_w_id AND d_id = v_d_id
     FOR UPDATE;

    -- (b) increment it
    UPDATE district
       SET d_next_o_id = d_next_o_id + 1
     WHERE d_w_id = p_w_id AND d_id = v_d_id;

    v_remote := 0;

    -- (c) create ORDERS and NEW_ORDER rows
    INSERT INTO orders
          (o_id, o_d_id, o_w_id, o_c_id,
           o_entry_d, o_carrier_id,
           o_ol_cnt, o_all_local)
    VALUES (v_next_o_id, v_d_id, p_w_id, v_c_id,
            clock_timestamp(), NULL,
            v_ol_cnt, 1 /*tentative, maybe updated*/);

    INSERT INTO new_order
          (no_o_id, no_d_id, no_w_id)
    VALUES (v_next_o_id, v_d_id, p_w_id);

    -- (d) order-line loop
    FOR v_i IN 1 .. v_ol_cnt LOOP
        v_item_id     := (floor(random()*100000)+1)::INT;     -- 1..100 000
        v_quantity    := (floor(random()*10)+1)::INT;        -- 1..10

        /* 1 % of all lines use a remote warehouse (if scale>1) */
        IF random() < 0.01 AND (SELECT count(*) FROM warehouse)>1 THEN
            SELECT w_id INTO v_supply_w_id
              FROM warehouse
             WHERE w_id <> p_w_id
             OFFSET floor(random()*((SELECT count(*)-1 FROM warehouse)))
             LIMIT 1;
            v_remote := 1;
        ELSE
            v_supply_w_id := p_w_id;
        END IF;

        -- fetch price & stock (lock stock row!)
        SELECT i_price
          INTO STRICT v_amount
          FROM item
         WHERE i_id = v_item_id;

        UPDATE stock
           SET s_quantity   = CASE WHEN s_quantity > v_quantity
                                   THEN s_quantity - v_quantity
                                   ELSE s_quantity + 91 - v_quantity END,
               s_ytd        = s_ytd + v_quantity,
               s_order_cnt  = s_order_cnt + 1,
               s_remote_cnt = s_remote_cnt + (v_supply_w_id<>p_w_id)::INT
         WHERE s_i_id = v_item_id
           AND s_w_id = v_supply_w_id
         RETURNING s_quantity INTO v_quantity;  -- not spec, but handy

        INSERT INTO order_line
              (ol_o_id, ol_d_id, ol_w_id,
               ol_number,
               ol_i_id, ol_supply_w_id,
               ol_delivery_d,
               ol_quantity, ol_amount,
               ol_dist_info)
        VALUES (v_next_o_id, v_d_id, p_w_id,
                v_i,
                v_item_id, v_supply_w_id,
                NULL,
                v_quantity,
                v_amount * v_quantity,
                (SELECT CASE v_d_id
                         WHEN 1 THEN s_dist_01 WHEN 2 THEN s_dist_02
                         WHEN 3 THEN s_dist_03 WHEN 4 THEN s_dist_04
                         WHEN 5 THEN s_dist_05 WHEN 6 THEN s_dist_06
                         WHEN 7 THEN s_dist_07 WHEN 8 THEN s_dist_08
                         WHEN 9 THEN s_dist_09 ELSE s_dist_10 END
                 FROM stock WHERE s_i_id = v_item_id AND s_w_id = v_supply_w_id));
    END LOOP;

    -- (e) fix o_all_local if any remote line was used
    IF v_remote = 1 THEN
        UPDATE orders
           SET o_all_local = 0
         WHERE o_w_id = p_w_id AND o_d_id = v_d_id AND o_id = v_next_o_id;
    END IF;
END;
$$;

-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE tpcc_payment(p_w_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_d_id        INT  := (floor(random()*10)+1)::INT;   -- 1-10
    v_h_amount    NUMERIC := ((floor(random()*5000)+100)::NUMERIC)/100; -- 1.00-50.00
    v_c_d_id      INT;
    v_c_w_id      INT;
    v_c_id        INT;
    v_byname      BOOLEAN;
    v_last_name   TEXT;
    v_c_balance   NUMERIC;
BEGIN
    /* 85 % local, 15 % remote warehouse for payment */
    IF random() < 0.85 THEN
        v_c_d_id := v_d_id;
        v_c_w_id := p_w_id;
    ELSE
        v_c_w_id := (SELECT w_id FROM warehouse
                      WHERE w_id <> p_w_id
                      OFFSET floor(random()*((SELECT count(*)-1 FROM warehouse)))
                      LIMIT 1);
        v_c_d_id := (floor(random()*10)+1)::INT;
    END IF;

    /* 60 % last-name selection */
    v_byname := random() < 0.60;

    IF v_byname THEN
        v_last_name :=
            tpcc_make_last_name((floor(random()*256))::INT); -- NURand(255,0,999) simplified
        SELECT c_id
          INTO v_c_id
          FROM customer
         WHERE c_w_id = v_c_w_id
           AND c_d_id = v_c_d_id
           AND c_last = v_last_name
         ORDER BY c_first   -- middle row if several
         LIMIT 1 OFFSET
         (SELECT (count(*)-1)/2 FROM customer
           WHERE c_w_id=v_c_w_id AND c_d_id=v_c_d_id AND c_last=v_last_name);
    ELSE
        v_c_id := (floor(random()*3000)+1)::INT;
    END IF;

    -----------------------------------------------------------------
    UPDATE warehouse
       SET w_ytd = w_ytd + v_h_amount
     WHERE w_id = p_w_id;

    UPDATE district
       SET d_ytd = d_ytd + v_h_amount
     WHERE d_w_id = p_w_id AND d_id = v_d_id;

    UPDATE customer
       SET c_balance     = c_balance - v_h_amount,
           c_ytd_payment = c_ytd_payment + v_h_amount,
           c_payment_cnt = c_payment_cnt + 1
     WHERE c_w_id = v_c_w_id AND c_d_id = v_c_d_id AND c_id = v_c_id
     RETURNING c_balance INTO v_c_balance;

    INSERT INTO history
          (h_c_id, h_c_d_id, h_c_w_id,
           h_d_id, h_w_id, h_date,
           h_amount, h_data)
    VALUES (v_c_id, v_c_d_id, v_c_w_id,
            v_d_id,  p_w_id, clock_timestamp(),
            v_h_amount,
            format('Pay-%s-%s', p_w_id, v_d_id));
END;
$$;

-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE tpcc_order_status(p_w_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_d_id      INT := (floor(random()*10)+1)::INT;
    v_c_id      INT;
    v_byname    BOOLEAN;
    v_last_name TEXT;
    v_last_o_id INT;
BEGIN
    v_byname := random() < 0.60;

    IF v_byname THEN
        v_last_name :=
            tpcc_make_last_name((floor(random()*256))::INT);
        SELECT c_id
          INTO v_c_id
          FROM customer
         WHERE c_w_id = p_w_id
           AND c_d_id = v_d_id
           AND c_last = v_last_name
         ORDER BY c_first
         LIMIT 1 OFFSET
         (SELECT (count(*)-1)/2 FROM customer
           WHERE c_w_id=p_w_id AND c_d_id=v_d_id AND c_last=v_last_name);
    ELSE
        v_c_id := (floor(random()*3000)+1)::INT;
    END IF;

    SELECT o_id
      INTO v_last_o_id
      FROM orders
     WHERE o_w_id = p_w_id
       AND o_d_id = v_d_id
       AND o_c_id = v_c_id
     ORDER BY o_id DESC
     LIMIT 1;

    PERFORM *
      FROM order_line
     WHERE ol_w_id = p_w_id
       AND ol_d_id = v_d_id
       AND ol_o_id = v_last_o_id;
END;
$$;

-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE tpcc_delivery(p_w_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    d             INT;
    v_o_id        INT;
    v_c_id        INT;
    v_amount      NUMERIC;
BEGIN
    FOR d IN 1 .. 10 LOOP
        SELECT no_o_id
          INTO v_o_id
          FROM new_order
         WHERE no_w_id = p_w_id
           AND no_d_id = d
         ORDER BY no_o_id
         LIMIT 1
         FOR UPDATE SKIP LOCKED;

        IF NOT FOUND THEN CONTINUE; END IF;

        DELETE FROM new_order
         WHERE no_w_id = p_w_id
           AND no_d_id = d
           AND no_o_id = v_o_id;

        UPDATE orders
           SET o_carrier_id = (floor(random()*10)+1)::INT
         WHERE o_w_id = p_w_id
           AND o_d_id = d
           AND o_id   = v_o_id
         RETURNING o_c_id INTO v_c_id;

        UPDATE order_line
           SET ol_delivery_d = clock_timestamp()
         WHERE ol_w_id = p_w_id
           AND ol_d_id = d
           AND ol_o_id = v_o_id;

        SELECT SUM(ol_amount)
          INTO v_amount
          FROM order_line
         WHERE ol_w_id = p_w_id
           AND ol_d_id = d
           AND ol_o_id = v_o_id;

        UPDATE customer
           SET c_balance     = c_balance + v_amount,
               c_delivery_cnt = c_delivery_cnt + 1
         WHERE c_w_id = p_w_id
           AND c_d_id = d
           AND c_id   = v_c_id;
    END LOOP;
END;
$$;

-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE tpcc_stock_level(p_w_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_d_id      INT := (floor(random()*10)+1)::INT;
    v_threshold INT := (floor(random()*11)+10)::INT; -- 10-20
    v_next_o_id INT;
BEGIN
    SELECT d_next_o_id
      INTO v_next_o_id
      FROM district
     WHERE d_w_id = p_w_id AND d_id = v_d_id;

    PERFORM COUNT(DISTINCT s_i_id)
      FROM stock s
      JOIN order_line ol
        ON ol_w_id = p_w_id
       AND ol_d_id = v_d_id
       AND ol_i_id = s_i_id
     WHERE s_w_id = p_w_id
       AND ol_o_id >= v_next_o_id - 20
       AND s_quantity < v_threshold;
END;
$$;

\echo '*** TPC-C bootstrap started (scale = :scale) ***'

-- default if caller forgot -v scale=N
\if :{?scale}
\else
  \set scale 1
\endif

BEGIN;

-- create schema objects
CALL tpcc_schema_create();

-- load data for the requested number of warehouses
CALL tpcc_load_data(:scale);

COMMIT;

\echo '*** bootstrap completed successfully ***'
