CREATE SCHEMA nacs623projectschema
    AUTHORIZATION postgres;

CREATE TABLE postgres.nacs623projectschema.depot (
	depid varchar(10) NOT NULL,
	addr varchar(30),
	volume int4
);

ALTER TABLE postgres.nacs623projectschema.depot ADD PRIMARY KEY (depid);

INSERT INTO postgres.nacs623projectschema.depot(depid, addr, volume) VALUES ('d1', 'New York', 9000);
INSERT INTO postgres.nacs623projectschema.depot(depid, addr, volume) VALUES ('d2', 'Syracuse', 6000);
INSERT INTO postgres.nacs623projectschema.depot(depid, addr, volume) VALUES ('d4', 'New York', 2000);

CREATE TABLE postgres.nacs623projectschema.product (
	prodid varchar(10) NOT NULL,
	pname varchar(25),
	price numeric
);

ALTER TABLE postgres.nacs623projectschema.product ADD PRIMARY KEY (prodid);
ALTER TABLE postgres.nacs623projectschema.product ADD CONSTRAINT ck_product_price CHECK (price > 0);

INSERT INTO postgres.nacs623projectschema.product(prodid, pname, price) VALUES ('p1', 'tape', 2.5);
INSERT INTO postgres.nacs623projectschema.product(prodid, pname, price) VALUES ('p2', 'tv', 250);
INSERT INTO postgres.nacs623projectschema.product(prodid, pname, price) VALUES ('p3', 'vcr', 80);

CREATE TABLE postgres.nacs623projectschema.stock (
	prodid varchar(10) NOT NULL,
	depid varchar(10) NOT NULL,
	quantity int4
);

ALTER TABLE postgres.nacs623projectschema.stock ADD PRIMARY KEY (prodid, depid);
ALTER TABLE postgres.nacs623projectschema.stock ADD FOREIGN KEY (depid) REFERENCES postgres.nacs623projectschema.depot (depid) ;
ALTER TABLE postgres.nacs623projectschema.stock ADD FOREIGN KEY (prodid) REFERENCES postgres.nacs623projectschema.product (prodid) ON DELETE CASCADE;

INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p1', 'd1', 1000);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p1', 'd2', -100);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p1', 'd4', 1200);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p3', 'd1', 3000);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p3', 'd4', 2000);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p2', 'd4', 1500);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p2', 'd1', -400);
INSERT INTO postgres.nacs623projectschema.stock(prodid, depid, quantity) VALUES ('p2', 'd2', 2000);