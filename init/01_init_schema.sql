-- 倉庫
CREATE TABLE warehouse (
    w_id INT PRIMARY KEY,
    w_name TEXT,
    w_address TEXT
);
-- 地区
CREATE TABLE district (
    d_id INT PRIMARY KEY,
    d_w_id INT REFERENCES warehouse(w_id),
    d_name TEXT,
    d_address TEXT
);
-- 顧客
CREATE TABLE customer (
    c_id INT PRIMARY KEY,
    c_d_id INT REFERENCES district(d_id),
    c_w_id INT REFERENCES warehouse(w_id),
    c_name TEXT,
    c_balance NUMERIC
);
-- 商品
CREATE TABLE item (
    i_id INT PRIMARY KEY,
    i_name TEXT,
    i_price NUMERIC
);
-- 在庫
CREATE TABLE stock (
    s_i_id INT REFERENCES item(i_id),
    s_w_id INT REFERENCES warehouse(w_id),
    s_quantity INT,
    PRIMARY KEY (s_i_id, s_w_id)
);
-- 注文
CREATE TABLE orders (
    o_id SERIAL PRIMARY KEY,
    o_d_id INT REFERENCES district(d_id),
    o_w_id INT REFERENCES warehouse(w_id),
    o_c_id INT REFERENCES customer(c_id),
    o_entry_d TIMESTAMPTZ DEFAULT now()
);
-- 注文明細
CREATE TABLE order_line (
    ol_o_id INT REFERENCES orders(o_id),
    ol_number INT,
    ol_i_id INT REFERENCES item(i_id),
    ol_supply_w_id INT REFERENCES warehouse(w_id),
    ol_quantity INT,
    ol_amount NUMERIC,
    PRIMARY KEY (ol_o_id, ol_number)
);