CREATE TABLE PRODUCT(
	Prodno VARCHAR(10) NOT NULL, 
	Pname VARCHAR(20), 
	Price DECIMAL
   );

CREATE TABLE DEPOT(
	Depno VARCHAR(10) NOT NULL, 
	Addr VARCHAR(20), 
	Volume DECIMAL
   );

CREATE TABLE STOCK(
	Prodno VARCHAR(10) NOT NULL, 
	Depno VARCHAR(10) NOT NULL, 
	Quantity DECIMAL
   );

   
INSERT INTO Product (Prodno, Pname, Price) VALUES ('p1', 'tape', '2.5');
INSERT INTO Product (Prodno, Pname, Price) VALUES ('p2', 'tv', '250');
INSERT INTO Product (Prodno, Pname, Price) VALUES ('p3', 'vcr', '80');

INSERT INTO Depot (Depno, Addr, Volume) VALUES ('d1', 'New York', '9000');
INSERT INTO Depot (Depno, Addr, Volume) VALUES ('d2', 'Syracuse', '6000');
INSERT INTO Depot (Depno, Addr, Volume) VALUES ('d4', 'New York', '2000');


INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p1', 'd1', '1000');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p1', 'd2', '-100');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p1', 'd4', '1200');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p3', 'd1', '3000');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p3', 'd4', '2000');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p2', 'd4', '1500');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p2', 'd1', '-400');
INSERT INTO Stock (Prodno, Depno, Quantity) VALUES ('p2', 'd2', '2000');

ALTER TABLE Product ADD CONSTRAINT pk_Product PRIMARY KEY (Prodno);
ALTER TABLE Product ADD CONSTRAINT ck_Product_Price CHECK (Price > 0);
ALTER TABLE Depot ADD CONSTRAINT pk_Depot PRIMARY KEY (Depno);
ALTER TABLE Stock ADD CONSTRAINT pk_Stock PRIMARY KEY (Prodno,Depno);
ALTER TABLE Stock ADD CONSTRAINT fk_Stock_Prod FOREIGN KEY (Prodno) REFERENCES Product(Prodno);
ALTER TABLE Stock ADD CONSTRAINT fk_Stock_Depot FOREIGN KEY (Depno) REFERENCES Depot(Depno);


-- Questions:

--What are the #prods whose name begins with a ’p’ and are less than $300.00?
SELECT PRODNO FROM PRODUCT WHERE PNAME LIKE 'p%' AND PRICE <300

 --Names of the products stocked in ”d2”
 --without in/not in
 SELECT PRODUCT.PNAME FROM PRODUCT,STOCK WHERE STOCK.DEPNO = 'd2' AND STOCK.PRODNO = PRODUCT.PRODNO
 -- with in/not in
 SELECT PNAME FROM PRODUCT WHERE PRODNO IN (SELECT PRODNO FROM STOCK WHERE STOCK.DEPNO = 'd2')
 
 --#prod and names of the products that are out of stock.
 --without in/not in
 SELECT PRODUCT.PRODNO,PRODUCT.PNAME FROM PRODUCT,STOCK WHERE STOCK.QUANTITY <0 AND STOCK.PRODNO = PRODUCT.PRODNO
 -- with in/not in
 SELECT PRODNO,PNAME FROM PRODUCT WHERE PRODNO IN (SELECT PRODNO FROM STOCK WHERE STOCK.QUANTITY <0)
 
 --Addresses of the depots where the product ”p1” is stocked.
--(a) without exists/not exists and without in/not in
SELECT DEPOT.ADDR FROM DEPOT,STOCK WHERE DEPOT.DEPNO = STOCK.DEPNO AND STOCK.PRODNO='p1'
--(b) with in/not in
SELECT ADDR FROM DEPOT WHERE DEPNO IN (SELECT DEPNO FROM STOCK WHERE STOCK.PRODNO='p1') 
--(c) with exists/not exists
SELECT DEPOT.ADDR FROM DEPOT WHERE EXISTS (SELECT DEPNO FROM STOCK WHERE STOCK.PRODNO='p1' AND STOCK.DEPNO =DEPOT.DEPNO ) 

-- **** The ck_CHECK constraint is not enforced in psql ****//

-- #prods whose price is between $250.00 and $400.00.
--(a) using intersect.
SELECT PRODNO FROM PRODUCT WHERE PRICE >=250 INTERSECT SELECT PRODNO FROM PRODUCT WHERE PRICE <=400
--(b) without intersect
SELECT PRODNO FROM PRODUCT WHERE PRICE BETWEEN 250 AND 400


--How many products are out of stock?
SELECT COUNT(DISTINCT PRODNO) FROM STOCK WHERE QUANTITY <= 0

-- Average of the prices of the products stocked in the ”d2” depot.
SELECT AVG(PRODUCT.PRICE) FROM PRODuCT,STOCK WHERE PRODUCT.PRODNO = STOCK.PRODNO AND STOCK.DEPNO = 'd2'

--#deps of the depot(s) with the largest capacity (volume).
SELECT DEPNO FROM DEPOT WHERE VOLUME = (SELECT MAX(VOLUME) FROM DEPOT)

--Sum of the stocked quantity of each product.
SELECT PRODNO,SUM(QUANTITY) FROM STOCK GROUP BY PRODNO

 -- Products names stocked in at least 3 depots
	--(a)using count 
SELECT PNAME FROM PRODUCT WHERE PRODNO IN (SELECT PRODNO FROM STOCK GROUP BY PRODNO HAVING COUNT(PRODNO)>=3)	




