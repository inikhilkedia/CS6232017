CREATE SCHEMA week5
    AUTHORIZATION postgres;

CREATE TABLE postgres.week5.depot (
	dep_id varchar(10) NOT NULL,
	addr varchar(30),
	volume int4
);

ALTER TABLE postgres.week5.depot ADD PRIMARY KEY (dep_id);

INSERT INTO postgres.week5.depot(dep_id, addr, volume) VALUES ('d1', 'New York', 9000);
INSERT INTO postgres.week5.depot(dep_id, addr, volume) VALUES ('d2', 'Syracuse', 6000);
INSERT INTO postgres.week5.depot(dep_id, addr, volume) VALUES ('d4', 'New York', 2000);

CREATE TABLE postgres.week5.product (
	prod_id varchar(10) NOT NULL,
	pname varchar(25),
	price numeric
);

ALTER TABLE postgres.week5.product ADD PRIMARY KEY (prod_id);
ALTER TABLE postgres.week5.product ADD CONSTRAINT ck_product_price CHECK (price > 0);

INSERT INTO postgres.week5.product(prod_id, pname, price) VALUES ('p1', 'tape', 2.5);
INSERT INTO postgres.week5.product(prod_id, pname, price) VALUES ('p2', 'tv', 250);
INSERT INTO postgres.week5.product(prod_id, pname, price) VALUES ('p3', 'vcr', 80);

CREATE TABLE postgres.week5.stock (
	prod_id varchar(10) NOT NULL,
	dep_id varchar(10) NOT NULL,
	quantity int4
);

ALTER TABLE postgres.week5.stock ADD PRIMARY KEY (prod_id, dep_id);
ALTER TABLE postgres.week5.stock ADD FOREIGN KEY (dep_id) REFERENCES postgres.week5.depot (dep_id);
ALTER TABLE postgres.week5.stock ADD FOREIGN KEY (prod_id) REFERENCES postgres.week5.product (prod_id);

INSERT INTO postgres.week5.stock(prod_id, dep_id, quantity) VALUES ('p1', 'd1', 1000);
INSERT INTO postgres.week5.stock(prod_id, dep_id, quantity) VALUES ('p2', 'd4', 1500);
INSERT INTO postgres.week5.stock(prod_id, dep_id, quantity) VALUES ('p2', 'd1', -400);
INSERT INTO postgres.week5.stock(prod_id, dep_id, quantity) VALUES ('p3', 'd2', 2000);

-- 1. What are the #prods whose name begins with a 'p' and are less than $300.00?

SELECT
	prod_id
FROM
	postgres.week5.product
WHERE
	pname LIKE 'p%' AND
	price < 300;

-- 2. Names of the products stocked in "d2".
-- (a) without in/not in

SELECT
	stock.dep_id,
	product.pname
FROM
	postgres.week5.stock stock,
	postgres.week5.product product
WHERE
	stock.prod_id = product.prod_id AND
	stock.dep_id = 'd2';

-- (b) with in/not in

SELECT
	stock.dep_id,
	product.pname
FROM
	postgres.week5.stock stock,
	postgres.week5.product product
WHERE
	stock.prod_id = product.prod_id AND
	stock.dep_id IN ('d2');

-- 3. #prod and names of the products that are out of stock.
-- (a) without in/not in

SELECT
	product.pname,
	product.prod_id
FROM
	postgres.week5.product product,
	postgres.week5.stock stock
WHERE
	product.prod_id = stock.prod_id AND
	stock.quantity < 1;

-- (b) with in/not in

SELECT
	product.pname,
	product.prod_id
FROM
	postgres.week5.product product,
	postgres.week5.stock stock
WHERE
	product.prod_id = stock.prod_id AND
	stock.quantity IN (
	SELECT
		quantity
	FROM
		week5.stock
	WHERE
		quantity<1);

-- 4. Addresses of the depots where the product "p1" is stocked.
-- (a) without exists/not exists and without in/not in

SELECT
	depot.addr
FROM
	postgres.week5.depot depot,
	postgres.week5.stock stock
WHERE
	depot.dep_id = stock.dep_id AND
	stock.prod_id = 'p1' AND
	stock.quantity > 0;

-- (b) with in/not in

SELECT
	depot.addr
FROM
	postgres.week5.depot depot,
	postgres.week5.stock stock
WHERE
	depot.dep_id = stock.dep_id AND
	stock.prod_id IN ('p1') AND
	stock.quantity IN (
	SELECT
		quantity
	FROM
		week5.stock
	WHERE
		quantity>0);

-- (c) with exists/not exists

SELECT
	depot.addr
FROM
	postgres.week5.depot,
	postgres.week5.stock
WHERE EXISTS (
			SELECT *
			FROM
				postgres.week5.stock
			WHERE
				stock.dep_id = depot.dep_id AND
				prod_id = 'p1' AND
				quantity > 0 );

-- 5. #prods whose price is between $250.00 and $400.00.
-- (a) using intersect.

SELECT
	prod_id
FROM
	postgres.week5.product
WHERE
	price >= 250
	INTERSECT 
			SELECT prod_id
			FROM week5.product
			WHERE price < 400;

-- (b) without intersect.

SELECT
	prod_id
FROM
	postgres.week5.product
WHERE
	price BETWEEN 250 AND 400;

-- 6. How many products are out of stock?

SELECT
	COUNT(prod_id)
FROM
	postgres.week5.stock
WHERE
	quantity < 1;

-- 7. Average of the prices of the products stocked in the "d2" depot.

SELECT
	AVG(product.price)
FROM
	postgres.week5.product product,
	postgres.week5.stock stock
WHERE
	product.prod_id = stock.prod_id AND
	stock.dep_id = 'd2';

-- 8. #deps of the depot(s) with the largest capacity (volume).

SELECT
	dep_id
FROM
	postgres.week5.depot
WHERE
	volume IN (
SELECT
	MAX(volume)
FROM
	depot);

-- 9. Sum of the stocked quantity of each product.

SELECT
	prod_id,
	SUM(quantity) AS TOTALEACH
FROM
	postgres.week5.stock
GROUP BY
	prod_id;

-- 10. Products names stocked in at least 3 depots.
-- (a) using count

SELECT
	product.pname,
	COUNT(stock.dep_id)
FROM
	postgres.week5.product product,
	postgres.week5.stock stock
WHERE
	product.prod_id = stock.prod_id
GROUP BY
	product.pname
HAVING COUNT(dep_id) >= 3;

-- 11. #prod stocked in all depots.
-- (a) using count

SELECT
	COUNT(dep_id),
	prod_id
FROM
	postgres.week5.stock
GROUP BY
	prod_id
HAVING COUNT(dep_id) = 3;
