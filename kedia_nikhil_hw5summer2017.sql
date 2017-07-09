-- SQL - product, depot, stock
-- Firstly the whole table creation and population.

CREATE SCHEMA week5nk
    AUTHORIZATION postgres;

CREATE TABLE postgres.week5nk.depot (
	depid varchar(10) NOT NULL,
	addr varchar(30),
	volume int4
);

ALTER TABLE postgres.week5nk.depot ADD PRIMARY KEY (depid);

INSERT INTO postgres.week5nk.depot(depid, addr, volume) VALUES ('d1', 'New York', 9000);
INSERT INTO postgres.week5nk.depot(depid, addr, volume) VALUES ('d2', 'Syracuse', 6000);
INSERT INTO postgres.week5nk.depot(depid, addr, volume) VALUES ('d4', 'New York', 2000);

CREATE TABLE postgres.week5nk.product (
	prodid varchar(10) NOT NULL,
	pname varchar(25),
	price numeric
);

ALTER TABLE postgres.week5nk.product ADD PRIMARY KEY (prodid);
ALTER TABLE postgres.week5nk.product ADD CONSTRAINT ck_product_price CHECK (price > 0);

INSERT INTO postgres.week5nk.product(prodid, pname, price) VALUES ('p1', 'tape', 2.5);
INSERT INTO postgres.week5nk.product(prodid, pname, price) VALUES ('p2', 'tv', 250);
INSERT INTO postgres.week5nk.product(prodid, pname, price) VALUES ('p3', 'vcr', 80);

CREATE TABLE postgres.week5nk.stock (
	prodid varchar(10) NOT NULL,
	depid varchar(10) NOT NULL,
	quantity int4
);

ALTER TABLE postgres.week5nk.stock ADD PRIMARY KEY (prodid, depid);
ALTER TABLE postgres.week5nk.stock ADD FOREIGN KEY (depid) REFERENCES postgres.week5nk.depot (depid);
ALTER TABLE postgres.week5nk.stock ADD FOREIGN KEY (prodid) REFERENCES postgres.week5nk.product (prodid);

INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p1', 'd1', 1000);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p1', 'd2', -100);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p1', 'd4', 1200);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p3', 'd1', 3000);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p3', 'd4', 2000);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p2', 'd4', 1500);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p2', 'd1', -400);
INSERT INTO postgres.week5nk.stock(prodid, depid, quantity) VALUES ('p2', 'd2', 2000);

-- Write the following queries in SQL.

-- 1. What are the #prods whose name begins with a 'p' and are less than $300.00?

SELECT
	prodid
FROM
	postgres.week5nk.product
WHERE
	pname LIKE 'p%' AND
	price < 300;

-- 2. Names of the products stocked in "d2".

-- (a) without in/not in

SELECT
	stock.depid,
	product.pname
FROM
	postgres.week5nk.stock stock,
	postgres.week5nk.product product
WHERE
	stock.prodid = product.prodid AND
	stock.depid = 'd2';

-- (b) with in/not in

SELECT
	stock.depid,
	product.pname
FROM
	postgres.week5nk.stock stock,
	postgres.week5nk.product product
WHERE
	stock.prodid = product.prodid AND
	stock.depid IN ('d2');

-- 3. #prod and names of the products that are out of stock.

-- (a) without in/not in

SELECT
	product.pname,
	product.prodid
FROM
	postgres.week5nk.product product,
	postgres.week5nk.stock stock
WHERE
	product.prodid = stock.prodid AND
	stock.quantity < 1;

-- (b) with in/not in

SELECT
	product.pname,
	product.prodid
FROM
	postgres.week5nk.product product,
	postgres.week5nk.stock stock
WHERE
	product.prodid = stock.prodid AND
	stock.quantity IN (
	SELECT
		quantity
	FROM
		week5nk.stock
	WHERE
		quantity<1);

-- 4. Addresses of the depots where the product "p1" is stocked.

-- (a) without exists/not exists and without in/not in

SELECT
	depot.addr
FROM
	postgres.week5nk.depot depot,
	postgres.week5nk.stock stock
WHERE
	depot.depid = stock.depid AND
	stock.prodid = 'p1' AND
	stock.quantity > 0;

-- (b) with in/not in

SELECT
	depot.addr
FROM
	postgres.week5nk.depot depot,
	postgres.week5nk.stock stock
WHERE
	depot.depid = stock.depid AND
	stock.prodid IN ('p1') AND
	stock.quantity IN (
	SELECT
		quantity
	FROM
		week5nk.stock
	WHERE
		quantity>0);

-- (c) with exists/not exists
-- The query below give the ouput 8 Times. Couldn't understand how to fix it. Tried all different sorts of things.

SELECT
	depot.addr
FROM
	postgres.week5nk.depot,
	postgres.week5nk.stock
WHERE EXISTS (
			SELECT *
			FROM
				postgres.week5nk.stock
			WHERE
				stock.depid = depot.depid AND
				prodid = 'p1' AND
				quantity > 0 );

-- 5. #prods whose price is between $250.00 and $400.00.

-- (a) using intersect.

SELECT
	prodid
FROM
	postgres.week5nk.product
WHERE
	price >= 250
	INTERSECT 
			SELECT prodid
			FROM week5nk.product
			WHERE price < 400;

-- (b) without intersect.

SELECT
	prodid
FROM
	postgres.week5nk.product
WHERE
	price BETWEEN 250 AND 400;

-- 6. How many products are out of stock?

SELECT
	COUNT(prodid)
FROM
	postgres.week5nk.stock
WHERE
	quantity < 1;

-- 7. Average of the prices of the products stocked in the "d2" depot.

SELECT
	AVG(product.price)
FROM
	postgres.week5nk.product product,
	postgres.week5nk.stock stock
WHERE
	product.prodid = stock.prodid AND
	stock.depid = 'd2';

-- 8. #deps of the depot(s) with the largest capacity (volume).

SELECT
	depid
FROM
	postgres.week5nk.depot
WHERE
	volume IN (
SELECT
	MAX(volume)
FROM
	depot);

-- 9. Sum of the stocked quantity of each product.

SELECT
	prodid,
	SUM(quantity) AS TOTALEACH
FROM
	postgres.week5nk.stock
GROUP BY
	prodid;

-- 10. Products names stocked in at least 3 depots.

-- (a) using count

SELECT
	product.pname,
	COUNT(stock.depid)
FROM
	postgres.week5nk.product product,
	postgres.week5nk.stock stock
WHERE
	product.prodid = stock.prodid
GROUP BY
	product.pname
HAVING COUNT(depid) >= 3;

-- (b) without using count
-- Couldn't figure it out. Looking forward to your answer.

-- 11. #prod stocked in all depots.

-- (a) using count

SELECT
	COUNT(depid),
	prodid
FROM
	postgres.week5nk.stock
GROUP BY
	prodid
HAVING COUNT(depid) = 3;

-- (b) using exists/not exists
-- Couldn't figure it out. Looking forward to your answer.