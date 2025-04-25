-- 初期データ投入
INSERT INTO warehouse SELECT i, 'Warehouse_' || i, 'Address_' || i FROM generate_series(1, 10) AS i;
INSERT INTO district SELECT (w - 1) * 10 + d, w, 'District_' || d, 'Address_' || d
FROM generate_series(1, 10) AS w, generate_series(1, 10) AS d;
INSERT INTO customer SELECT (d - 1) * 300 + c, d, ((d - 1) / 10) + 1, 'Customer_' || c, 0.0
FROM generate_series(1, 100) AS d, generate_series(1, 300) AS c;
INSERT INTO item SELECT i, 'Item_' || i, round((random() * 100 + 1)::numeric, 2) FROM generate_series(1, 10000) AS i;
INSERT INTO stock SELECT i, w, 100 FROM generate_series(1, 10000) AS i, generate_series(1, 10) AS w;