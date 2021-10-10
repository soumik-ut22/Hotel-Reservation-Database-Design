----------------------------------------------------------------------------
-- This is done by Group 19
--- Names ----------------------- EID ---------
--- Soumi Basu                  sb59982
--- Shubham Singh
--- Soumik Choudhury
--- Surya Prasad Reddy          sp49882
--- Karthick Ramasubramanian
--- Saiteja Reddy Yerasi        sy22575
----------------------------------------------------------------------------



--------------------------------------------------------------
---- Database cleaning : Dropping tables and sequences
--------------------------------------------------------------
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE room_id_seq;
DROP SEQUENCE location_id_seq;
DROP SEQUENCE feature_id_seq;
DROP SEQUENCE customer_id_seq; 


DROP TABLE reservation_details;
DROP TABLE room;
DROP TABLE location_features_linking;
DROP TABLE location;
DROP TABLE features;
DROP TABLE customer_payment;
DROP TABLE reservation;
DROP TABLE customer;

------------------------------------------------------------
-- Creating tables and sequence for the Hotel Reservation System based on the ER diagram
------------------------------------------------------------
CREATE TABLE features
(
  feature_ID       NUMBER          NOT NULL,
  feature_Name     VARCHAR2(50)    NOT NULL,
  CONSTRAINT  feature_table_id_pk
    PRIMARY KEY (feature_ID),
  CONSTRAINT feature_name 
    UNIQUE (feature_Name)
);

CREATE TABLE location
(
  location_ID      NUMBER          NOT NULL,
  location_Name    VARCHAR2(50)    NOT NULL,
  address          VARCHAR2(50)    NOT NULL,
  city             VARCHAR2(50)    NOT NULL,
  state            CHAR(2)         NOT NULL,
  zip              CHAR(5)         NOT NULL,
  phone            CHAR(12)        NOT NULL,
  url              VARCHAR2(100)   NOT NULL,
  CONSTRAINT  location_table_id_pk
    PRIMARY KEY (location_ID),
  CONSTRAINT location_name 
    UNIQUE (location_Name),
  CONSTRAINT phone_format 
  CHECK (regexp_like (phone,'^(\d{3}-\d{3}-?\d{4}|\d{10})$'))
);

CREATE TABLE location_features_linking
(
  location_ID       NUMBER          NOT NULL,
  feature_ID        NUMBER          NOT NULL,
  CONSTRAINT  featureloc_id_pk
    PRIMARY KEY (location_ID, feature_ID),
  CONSTRAINT feature_id_fk 
  FOREIGN KEY (feature_ID) 
  REFERENCES features(feature_ID),
  CONSTRAINT location_id_fk 
  FOREIGN KEY (location_ID) 
  REFERENCES location(location_ID)
);


CREATE TABLE room
(
  room_ID        NUMBER          NOT NULL,
  location_ID    NUMBER          NOT NULL,
  floor          NUMBER          NOT NULL, --- displays the floor number, 1/2/3 etc
  room_number    NUMBER          NOT NULL,
  room_type      CHAR(1)         NOT NULL, --- D/Q/K/S/C AS MENTIONED IN THE PROBLEM
  square_footage NUMBER          NOT NULL,
  max_people     NUMBER          NOT NULL, --- MENTIONS THE NO. OF PEOPLE THAT CAN STAY IN A ROOM 
  weekday_rate   NUMBER          NOT NULL, --- weekday rate in $
  weekend_rate   NUMBER          NOT NULL, --- weekend rate in $
  CONSTRAINT  room_id_pk
    PRIMARY KEY (room_ID),
  CONSTRAINT room_location_id_fk 
  FOREIGN KEY (location_ID) 
  REFERENCES location(location_ID),
  CONSTRAINT room_type_const 
    CHECK (regexp_like (room_type,'(D|Q|K|S|C)'))
);

CREATE TABLE customer
(
  customer_ID           NUMBER           NOT NULL,
  first_name            VARCHAR2(20)     NOT NULL, --- ASSUMING NAMES ARE USUALLY NOT LENGTHIER THAN 20 CHARACTERS
  last_name             VARCHAR2(20)     NOT NULL, --- ASSUMING NAMES ARE NOT LENGTHIER THAN 20 CHARACTERS
  email                 VARCHAR(255)     NOT NULL,
  phone                 CHAR(12)         DEFAULT    000-000-0000 , 
  address_line_1        VARCHAR2(50)     NOT NULL,
  address_line_2        VARCHAR2(50),               --- can be NULL
  city                  VARCHAR2(20)     NOT NULL,  --- ASSUMING CITY NAMES ARE NOT LENGTHIER THAN 20 CHARACTERS
  state                 CHAR(2)          NOT NULL,
  zip                   CHAR(5)          NOT NULL,
  birthdate             DATE,                       --- can be NULL
  stay_credits_earned   NUMBER           DEFAULT 0,
  stay_credits_used     NUMBER           DEFAULT 0,
  CONSTRAINT  customer_id_pk
    PRIMARY KEY (customer_ID),
  CONSTRAINT customer_email 
    UNIQUE (email),
  CONSTRAINT credit_earned_used 
    CHECK (stay_credits_used <= stay_credits_earned),
  CONSTRAINT email_length_check 
    CHECK (length(email) >= 7),
  CONSTRAINT cust_phone_format
    CHECK (regexp_like (phone,'^(\d{3}-\d{3}-?\d{4}|\d{10})$'))  
);

CREATE TABLE reservation
(
  reservation_ID        NUMBER          NOT NULL,
  customer_ID           NUMBER          NOT NULL,
  confirmation_nbr      CHAR(8)         NOT NULL,
  date_created          DATE            DEFAULT SYSDATE,
  check_in_date         DATE            NOT NULL,
  check_out_date        DATE,                               --- can be NULL
  status                CHAR(1)         NOT NULL,
  discount_code         VARCHAR(12),                        --- can be NULL, MAX LENGTH OF 12 GIVEN IN HW1
  reservation_total     NUMBER          NOT NULL, 
  customer_rating       NUMBER,                             --- can be NULL, ASSUMING RATING IF THERE, CAN ONLY BE BETWEEN 1-5 
  notes                 VARCHAR(255),                       --- can be NULL
  CONSTRAINT  reservation_id_pk
    PRIMARY KEY (reservation_ID),
  CONSTRAINT customer_id_fk 
  FOREIGN KEY (customer_ID) 
  REFERENCES customer(customer_ID),
  CONSTRAINT conf_number UNIQUE (confirmation_nbr), 
  CONSTRAINT reservation_status 
    CHECK (regexp_like (status,'(U|I|C|N|R)')),
  CONSTRAINT rating_check 
    CHECK (customer_rating BETWEEN 1 AND 5) --- checking for the rating to lie between 1-5
);

CREATE TABLE reservation_details
(
  reservation_ID       NUMBER          NOT NULL,
  room_ID              NUMBER          NOT NULL,
  number_of_guests     NUMBER          NOT NULL,
  CONSTRAINT room_details_id_pk 
    PRIMARY KEY (room_ID, reservation_ID),
  CONSTRAINT reservation_details_id_fk 
    FOREIGN KEY (reservation_ID) 
    REFERENCES reservation(reservation_ID),
  CONSTRAINT room_details_id_fk 
    FOREIGN KEY (room_ID) 
    REFERENCES room(room_ID)
);

CREATE TABLE customer_payment
(
  payment_ID                NUMBER          NOT NULL,
  customer_ID               NUMBER          NOT NULL,
  cardholder_first_name     VARCHAR(20)     NOT NULL, --- assuming customer first name cannot be more than 20 characters
  cardholder_mid_name       VARCHAR(20),              --- assuming customer middle name cannot be more than 20 characters, this field can be NULL based on the understanding that not everyone has a middle name
  cardholder_last_name      VARCHAR(20)     NOT NULL, --- assuming customer last name cannot be more than 20 characters
  cardtype                  CHAR(4)         NOT NULL,
  cardnumber                NUMBER(16)      NOT NULL, --- as given in HW1 that card number is 15-16 digits
  expiration_date           DATE            NOT NULL,
  cc_id                     NUMBER(3)       NOT NULL, --- since the cc_id is a 3-digit code
  billing_address           VARCHAR(100)    NOT NULL, 
  billing_city              VARCHAR2(20)    NOT NULL, --- ASSUMING CITY NAMES ARE NOT LENGTHIER THAN 20 CHARACTERS,
  billing_state             CHAR(2)         NOT NULL,
  billing_zip               CHAR(5)         NOT NULL,
  CONSTRAINT  payment_id_pk
    PRIMARY KEY (payment_ID),
  CONSTRAINT customer_pay_id_fk 
    FOREIGN KEY (customer_ID) 
    REFERENCES customer(customer_ID),
  CONSTRAINT card_no_check 
    CHECK (LENGTH(cardnumber) >=15),
  CONSTRAINT cc_id_check 
    CHECK (LENGTH(cc_id) = 3)
);

---- Creating sequence for the tables

  CREATE SEQUENCE payment_id_seq
    START WITH 1 INCREMENT BY 1;

  CREATE SEQUENCE reservation_id_seq
    START WITH 1 INCREMENT BY 1;
    
  CREATE SEQUENCE room_id_seq
    START WITH 1 INCREMENT BY 1;
    
  CREATE SEQUENCE location_id_seq
    START WITH 1 INCREMENT BY 1;
    
  CREATE SEQUENCE feature_id_seq
    START WITH 1 INCREMENT BY 1;
    
  -- sequence for customer_id
  CREATE SEQUENCE customer_id_seq
    START WITH 100001 INCREMENT BY 1;

------------------------------------------------------------------------------------------
--- Inserting into the database
------------------------------------------------------------------------------------------

INSERT INTO location
VALUES (location_id_seq.NEXTVAL , 'South Congress', '1826 Easy Street', 'Austin', 'TX', '78700', '512-123-4567', 'https://www.sourapplehotels.us/south_congress');

INSERT INTO location
VALUES (location_id_seq.NEXTVAL , 'East 7th Lofts', '8391 Bulls Rd', 'Austin', 'TX', '78123','123-234-3455', 'https://www.sourapplehotels.us/east_lofts');

INSERT INTO location
VALUES (location_id_seq.NEXTVAL , 'Balcones Canyonlands', '987 Looney Ln', 'Marble Falls', 'TX','79703', '514-354-0101', 'https://www.sourapplehotels.us/balcones_canyonlands');

COMMIT;

--- Inserting features

INSERT INTO features
VALUES (feature_id_seq.NEXTVAL, 'Free Wi-Fi');

INSERT INTO features
VALUES (feature_id_seq.NEXTVAL, 'Free Breakfast');

INSERT INTO features
VALUES (feature_id_seq.NEXTVAL, 'Free Parking');

COMMIT;

--- Insert into location_features_linking

INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'South Congress'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Parking'));
INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'South Congress'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Breakfast'));

INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'Balcones Canyonlands'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Breakfast'));
INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'Balcones Canyonlands'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Parking'));

INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'East 7th Lofts'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Parking'));
INSERT INTO location_features_linking (location_ID, feature_ID) 
VALUES ((SELECT location_ID FROM location WHERE location_Name = 'East 7th Lofts'),(SELECT feature_ID FROM features WHERE feature_name = 'Free Wi-Fi'));

COMMIT;

--- Inserting in rooms table (2 per location)
 
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'South Congress'), 1, 101, 'D', 400, 2, 82, 110);
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'South Congress'), 1, 111, 'Q', 300, 1, 52, 70);
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'Balcones Canyonlands'), 2, 211, 'K', 500, 2, 85, 115);
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'Balcones Canyonlands'), 1, 121, 'S', 800, 8, 132, 150);
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'East 7th Lofts'), 1, 1011, 'D', 400, 2, 82, 110);
INSERT INTO room
VALUES (room_id_seq.NEXTVAL, (SELECT location_ID FROM location WHERE location_Name = 'East 7th Lofts'), 2, 2121, 'C', 100, 1, 45, 50);

COMMIT;

--- Inserting into the customer table
  
INSERT INTO customer 
VALUES (customer_id_seq.NEXTVAL, 'Soumi', 'Basu', 'sb59982@utexas.edu', '412-111-1234','Nowhere on earth, 1111', NULL, 'NoCity', 'AA', 77777, NULL , 10, 2 );
INSERT INTO customer 
VALUES (customer_id_seq.NEXTVAL, 'Richard', 'Parker', 'richard.park@fb.com', '122-134-4324','Wonderland', '2722', 'San Diego', 'CL', 12345, TO_DATE('12/25/2000', 'MM/DD/YYYY') , 100, 54 );

COMMIT;

--- Inserting into the customer_payments table
  
INSERT INTO customer_payment 
VALUES (payment_id_seq.NEXTVAL, (SELECT customer_ID FROM customer WHERE first_name = 'Soumi'), 'Soumi', NULL, 'Basu', 1111, 3263487236741874,  TO_DATE('12/21/2026', 'MM/DD/YYYY'), 111, 'Nowhere on earth, 1111', 'NoCity', 'AA', 77777);

INSERT INTO customer_payment 
VALUES (payment_id_seq.NEXTVAL, (SELECT customer_ID FROM customer WHERE first_name = 'Richard'), 'Richard', 'Dancing', 'Parker', 1234, 3373584235742865,  TO_DATE('10/25/2028', 'MM/DD/YYYY'), 123, 'Wonderland', 'San Diego', 'CL', 12345);

COMMIT;

--- Inserting into reservation and reservation_details tables
  
/* Reservation for customer 1 */
INSERT INTO reservation
VALUES (reservation_id_seq.NEXTVAL, (SELECT customer_ID FROM customer WHERE first_name = 'Soumi'), 12341234, NULL, TO_DATE('10/05/2021', 'MM/DD/YYYY'), TO_DATE('10/15/2021', 'MM/DD/YYYY'), 'C', NULL, 1500, 4, NULL);
COMMIT;

INSERT INTO reservation_details
VALUES ((SELECT reservation_ID FROM reservation WHERE confirmation_nbr = 12341234), (SELECT room_ID from room WHERE room_number = 111),3);
COMMIT;

/* Reservation for customer 2 */
INSERT INTO reservation
VALUES (reservation_id_seq.NEXTVAL, (SELECT customer_ID FROM customer WHERE first_name = 'Richard'), 21546753,TO_DATE('10/08/2021', 'MM/DD/YYYY'), TO_DATE('10/08/2021', 'MM/DD/YYYY'), TO_DATE('10/10/2021', 'MM/DD/YYYY'), 'U', 'AKKDJF11', 789, 3, 'Decent');

INSERT INTO reservation
VALUES (reservation_id_seq.NEXTVAL, (SELECT customer_ID FROM customer WHERE first_name = 'Richard'), 27346411,TO_DATE('10/08/2020', 'MM/DD/YYYY'), TO_DATE('10/08/2020', 'MM/DD/YYYY'), TO_DATE('10/10/2020', 'MM/DD/YYYY'), 'C', NULL, 1823, 4, 'Good Service');

COMMIT;

INSERT INTO reservation_details
VALUES ((SELECT reservation_ID FROM reservation WHERE confirmation_nbr = 21546753 AND check_in_date = TO_DATE('10/08/2021', 'MM/DD/YYYY')), (SELECT room_ID from room WHERE room_number = 2121),3);

INSERT INTO reservation_details
VALUES ((SELECT reservation_ID FROM reservation WHERE confirmation_nbr = 27346411 AND check_in_date = TO_DATE('10/08/2020', 'MM/DD/YYYY')), (SELECT room_ID from room WHERE room_number = 121),5);
COMMIT;

------------------------------------------------------------------------------------------
--- Creating indexes for the foreign keys in respective tables that are not also primary keys
------------------------------------------------------------------------------------------

CREATE INDEX rom_loc_ix 
  ON room (location_ID);

CREATE INDEX reservation_ix 
  ON reservation (customer_ID);

CREATE INDEX customer_payment_ix 
  ON customer_payment (customer_ID);
  
--- Indexing two other columns from the schema

--- Creating index to be able to query through the database to find only the rooms on a particular floor 
CREATE INDEX floor_ix 
  ON room (floor); 

--- Creating index to be able to query through the database to find only the bookings on a particular date
CREATE INDEX date_created_ix 
  ON reservation (date_created);

--- DATABASE CREATED

SELECT * FROM customer;
SELECT * FROM customer_payment;
SELECT * FROM reservation_details;