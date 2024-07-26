-- Database project
-- Creating a mock system themed around video rental stores such as Blockbuster
-- Aims:
-- 1- Creating 3 tables - Items for rent, Customers and Rentals 
	-- Items and customer tables will have unique IDs for their respective focus instead of using an auto-incrementing ID. This is 
	-- an attempt to mirror an external system generating ID numbers in order to provide more complex multi-part IDs. 
    -- Rental table will be linked to the Item and Customer tables via FOREIGN KEY utilising Item_ID and Customer_ID respectively.
-- 2- Inserting test data into those tables via external .sql files
	-- 2a- If necessary, either due to incorrect or duplicate data when this is added, a set of commands will be used to clear links so that
    -- the necessary tables can be truncated (so ID numbers assigned to incorrect data are available). These links will then be re-established
    -- by using the ALTER command. 
-- 3- Creating a set of queries for checking data within these tables using the SELECT command, allowing for specific referencing of the Rentals
-- table via either Item ID or Customer ID number. 
-- 4- Creating a set of commands which will allow us to add new data into any of the 3 tables. These will be provided with placeholders to help 
-- illustrate how data should be laid out. 
	-- A command for adding new customer data
    -- A command for adding new items
    -- A command for adding new rentals 
-- 5- Creating commands for updating or editing data in any of the three tables. 
-- 6- Creating commands for deleting data from any of the three tables. 
	-- 6a- Creation of a separate command for redacting/anonymising identifying information upon customer request in order to maintain integrity
    -- of data within rentals table.
-- 7- Creating a set of commands for reading data from multiple tables using INNER JOIN, in order to pull all relevant data (customer name, 
-- contact details, etc.) for ease of use. 
-- 8- Creating a set of procedures to simplify complex actions created earlier.
	-- Procedure for reading all customer rentals data by providing their Customer ID number
    -- Procedure for reading all rentals for a particular item by providing that Item ID number
    -- Procedure for anonymising/scrambling customer sensitive info by providing Customer ID number

CREATE DATABASE BlockbusterRentals;
USE BlockbusterRentals;
SELECT DATABASE ();
-- Creating and establishing use of our database

-- ||1- CREATING TABLES|| -- 

-- Creating Table 1 - Items
CREATE TABLE tbl_items(
item_ID VARCHAR(8) NOT NULL PRIMARY KEY,
-- VARCHAR of 7 as we want ID numbers in the format XXX-XXXX
title VARCHAR(30) NOT NULL,
-- VARCHAR of 30 as some titles will be quite long, but assume limited space on POS for display
platform VARCHAR(4) NOT NULL, 
-- VARCHAR of 4 as assumed most POS/data pulls will use shorthand for console/format 
ageRating VARCHAR(4) NOT NULL, 
-- VARCHAR of 4 as there are limited options for age rating, but adds functionality for future changes (ie 12A, PG13) if needed
published_year DATE NOT NULL
);

SHOW TABLES; 
DESC tbl_items;
-- checking to see if we formatted this correctly

-- Creating Table 2 - Customers
CREATE TABLE tbl_customers(
customer_ID VARCHAR(7) NOT NULL PRIMARY KEY,
-- VARCHAR of 7 as we want these formatted like XXXX-XX 
firstname VARCHAR(20) NOT NULL,
surname VARCHAR(20) NOT NULL,
Email VARCHAR(60) NOT NULL, 
phone VARCHAR(12) NOT NULL 
-- VARCHAR of 12 for the standard phone format for UK, must be input without spacing
);

SHOW TABLES; 
DESC tbl_customers;
-- both tables are within the database, and formatted as desired

-- for table 3 (tbl_rentals) we need links to the two previously created tables, we will use FOREIGN KEY to do so

CREATE TABLE tbl_rentals(
rental_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
-- we want the rental ID to be unique to each instance of an item being rented out, setting an auto increment allows us to handle this more easily
item_ID VARCHAR(8) NOT NULL,
customer_ID VARCHAR(7) NOT NULL,
rental_date DATE, 
due_date DATE,				-- have left these without NOT NULL, however may update later on as due_date should be a requirement at the very least
CONSTRAINT item_ID
FOREIGN KEY (item_ID)
REFERENCES tbl_items(item_ID)
ON UPDATE CASCADE,
-- setting up the foreign key links for item_ID - cascading changes down through to here as well
CONSTRAINT customer_ID
FOREIGN KEY (customer_ID)
REFERENCES tbl_customers(customer_ID)
ON UPDATE CASCADE
-- setting up the foreign key links for customer_ID - cascading changes down through to here as well
);

SHOW TABLES; 
DESC tbl_rentals;
-- all three of our tables are now set up, we'll use the reverse engineer database (ctrl+r) to check our foreign key links are working 
-- RE shows links are established correctly

-- TABLES COMPLETE --

-- ||2- INSERTING STARTING [ITEM] DATA|| --
-- Data saved in separate sql - tbl_items test data

SELECT * FROM tbl_items;
-- to check data has been input as desired

-- in the process of adding the data to our tables, formatting has resulted in some duplicates being present. We cannot truncate 
-- this data with the foreign key links in place, so in order to clean things up we'll remove the link, truncate the table, and re-add it

-- ||2a- REMOVING LINKS FROM A TABLE AND RE-ADDING THOSE LINKS|| -- 


-- removing the foreign key links
-- We need to check what the specific links are called, so we'll use the SHOW CREATE TABLE to find these
SHOW CREATE TABLE tbl_rentals;
-- From this, we can see the links are named CONSTRAINT `tbl_rentals_ibfk_1 and CONSTRAINT `tbl_rentals_ibfk_2

ALTER TABLE tbl_rentals
DROP FOREIGN KEY tbl_rentals_ibfk_1;
ALTER TABLE tbl_rentals
DROP FOREIGN KEY tbl_rentals_ibfk_2;

-- clean out these tables so we can add our correct input data 
TRUNCATE tbl_items;

-- checking this worked
SELECT * FROM tbl_items;
-- data is clear, now we re-add the foreign key links

ALTER TABLE tbl_rentals
ADD FOREIGN KEY (item_ID) REFERENCES tbl_items(item_ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tbl_rentals
ADD FOREIGN KEY (customer_ID) REFERENCES tbl_customers(customer_ID)  ON DELETE CASCADE ON UPDATE CASCADE;
-- we check the reverse engineer view to make sure this link is now back in place. We can also use SHOW CREATE TABLE again
-- everything linked back as it was, and the table is now clear of duplicates, we then just run our INSERT INTO data again 

-- one last check to make sure everything is tidy now
SELECT * FROM tbl_items;

-- ||2- INSERTING STARTING [CUSTOMER] DATA|| --
-- Data saved in separate sql - tbl_customers test data

SELECT * FROM tbl_customers;
-- Data inserted correctly - we did have some minor formatting issues, but correction of these hasn't caused any duplicate data, so no need to truncate 
-- as we did for tbl_items

-- ||2- INSERTING [RENTAL] DATA|| --
-- We need to insert data that references both the given Customer and ID numbers, alongside data for when items were rented out and when they are due back. 
-- Because the rental_ID ia an auto-increment field, we don't need to worry about including this as a field within the INSERT INTO line
-- Data saved in separate sql - tbl_rentals test data

SELECT * FROM tbl_rentals;
-- Data inserted correctly

-- ||3- READING AND REFERENCING DATA IN THE TABLES|| --

-- Now that we have all of our tables populated, we can read entries from our rental table based on customer ID, or item ID. 
-- If we want to check rentals a customer has made for example, we do so thusly:

SELECT * FROM tbl_rentals WHERE customer_ID = '7670-12';
-- this shows us the customer has two rentals on system, which items they rented, and their due date. We also get the date they rented. 
-- we can also use this to look up how many customers have rented a specific item
SELECT * FROM tbl_rentals WHERE item_ID = '008-0338';
-- we can see from this that 3 customers have rented this item. 


-- ||4- CREATING NEW ENTRIES IN TABLES|| --
									-- Nice and easy, same as originally adding data in
-- ||CREATING NEW ENTRIES IN tbl_customers FOR NEW CUSTOMERS|| --
insert into tbl_customers (customer_ID, firstname, surname, email, phone) values ('CCCC-CC', '[firstname]', '[surname]', '[email]', '[phone]');
		-- This is the data format
insert into tbl_customers (customer_ID, firstname, surname, email, phone) values (' ', ' ', ' ', ' ', ' ');
		-- This is for inserting new data

-- ||CREATING NEW ENTRIES IN tbl_items FOR NEW ITEMS|| --
insert into tbl_items (item_ID, title, platform, ageRating, published_year) values ('III-IIII', '[title]', '[PTFM]', '[RTNG]', 'YYYY-MM-DD');
		-- This is the data format
insert into tbl_items (item_ID, title, platform, ageRating, published_year) values (' ', ' ', ' ', ' ', ' ');
		-- This is for inserting new data

-- ||CREATING NEW ENTRIES IN tbl_rentals FOR NEW RENTALS|| --
insert into tbl_rentals (item_ID, customer_ID, rental_date, due_date) values ('III-IIII', 'CCCC-CC', 'YYYY-MM-DD', 'YYYY-MM-DD');
		-- This is the data format
insert into tbl_rentals (item_ID, customer_ID, rental_date, due_date) values (' ', ' ', ' ', ' ');        
		-- This is for inserting new data
        
        
-- ||5- UPDATING RECORDS|| -- 

-- CUSTOMER DETAILS --
-- For updating a customer's details should any of these change - we do this using the customer ID as a reference point, as this cannot be changed.
UPDATE tbl_customers SET '[firstname/surname/phone/email]' = ' ' WHERE customer_ID= ' '; 
-- Change the [ ] content to the component that you need edited. 
-- For example:
-- FIRST NAME
UPDATE tbl_customers SET firstname = 'Johnathan' WHERE customer_ID= '1234-56';
					-- changes our customer "John Doe" to "Johnathan Doe"
-- SURNAME
UPDATE tbl_customers SET surname = 'Doefield' WHERE customer_ID= '1234-56';
					-- changes our "Johnathan Doe" to "Johnathan Doefield"
-- PHONE
UPDATE tbl_customers SET phone = '02079460988' WHERE customer_ID= '1234-56';
					-- updates customer phone number
-- EMAIL
UPDATE tbl_customers SET email = 'johnathan.doefield@gmail.com' WHERE customer_ID= '1234-56';
					-- updates customer e-mail
SELECT * FROM tbl_customers WHERE customer_ID = '1234-56';
-- We can now see the above has all taken effect

-- We use the same format for updating our other two tables

-- ITEM DETAILS -- 
-- For updating Item details, we reference the item ID as this, same as the customer ID, cannot be changed. 
UPDATE tbl_items SET '[title/platform/ageRating/published_year]' = ' ' WHERE item_ID= ' ';
-- Remember that we set the Items table up with specific character length parameters for the platform and ageRating columns
-- example formatting using Item ID 001-0301:
-- Title
UPDATE tbl_items SET title = 'Legend of Zelda' WHERE item_ID= '001-0301';
					-- changes out title from "The Legend of Zelda" to "Legend of Zelda"
-- Platform
UPDATE tbl_items SET platform = 'NES' WHERE item_ID= '001-0301';
					-- this doesn't actually change anything as the platform was already correct, but does illustrate the need for 4 or fewer characters
-- ageRating
UPDATE tbl_items SET ageRating = 'U' WHERE item_ID= '001-0301';
					-- Changing the Age Rating down to U, again referencing the need for 4 or fewer characters
-- published_year
UPDATE tbl_items SET published_year = '1987-11-27' WHERE item_ID= '001-0301';
					-- Changing the published date to match European release date
                    
-- RENTAL DETAILS --
-- This one would have less utility as the only data that would potentially need changing is the due date (for extensions, promotions, etc)
-- rental_date may possibly need changing (staff errors for example) so we will create a command for this as well.  
-- item_ID and customer_ID are already linked to their respective tables and as such should not be edited.
-- Whilst we can look up rentals via item_ID or customer_ID, we should NOT edit them based on this value, as customers could have rented 
-- multiple items, and items will have multiple rentals over their lifespan. 
-- rental_ID is an auto increment, and unique to each rental

UPDATE tbl_rentals SET '[due_date/rental_date]' = 'YYYY-MM-DD' WHERE rental_ID= ' ';

-- For example, if someone accidentally input a rental date 3 days earlier, you can update this as follows:
-- due_date
UPDATE tbl_rentals SET due_date = '2002-02-10' WHERE rental_ID= '33';
					-- added 3 days to the due date for rental number 33
-- rental_date
UPDATE tbl_rentals SET rental_date = '2002-02-05' WHERE rental_ID= '33';
					-- added 3 days to the rental date for rental 33


-- ||6- DELETING RECORDS|| --
-- We may need to delete customer account data, or data for an item in order to ensure that unavailable items or closed customer accounts 
-- aren't used unintentionally. We would also need this for "right to be forgotten" requests from customers, though those technically 
-- don't fall within the time period we're pretending to be in. 
-- Because we have customer ID and item ID numbers already set up, we can use those to define what needs deletion. 

-- DELETING CUSTOMER DATA --
DELETE FROM tbl_rentals WHERE customer_ID = ' ';
-- We'll delete customer number 20 (9902-35) to check this works:
DELETE FROM tbl_rentals WHERE customer_ID = '9902-35';
-- Checking this, we can see we now have no rental records for customer 9902-35
SELECT * FROM tbl_rentals WHERE customer_ID = '9902-35';
-- This works the same for our items and customer tables directly
DELETE FROM tbl_items WHERE item_ID = '020-4452';
SELECT * FROM tbl_rentals WHERE item_ID = '020-4452';
-- Deletion cascades because of the links we set up earlier
-- For a system like this, it would be sensible to have a secondary system for logging rental history based on customer ID number and ID numbers alone, 
-- with no identifying info linked to customer ID 

-- ||6a - SCRAMBLING CUSTOMER SENSITIVE INFO IN LIEU OF DELETION|| --
-- However, if a more complex system isn't possible, we can honour a deletion request by scrambling the customer's identifying information.
-- This would leave their ID number intact for historical records, whilst removing all personally identifying data from them. We do this
-- by using UPDATE once again.
UPDATE tbl_customers SET firstname = 'DELETED', surname = 'DELETED', email = 'DELETED', phone = 'DELETED' WHERE customer_ID = '8001-83';
-- this will have replaced all identifying information with 'deleted' but retained the customer ID number for rental records
SELECT * FROM tbl_customers WHERE customer_ID = '8001-83';
-- The same can be done for items as well, though it would be sensible to simply edit "title" to indicate removal, due to constraints on other 
-- columns, and to avoid losing item records.
UPDATE tbl_items SET title = '[REMOVED] Simpsons: BvsSpMu' WHERE item_ID = '019-5135';
SELECT * FROM tbl_items WHERE item_ID = '019-5135';
-- Requiring manual update using the item name rather than simply replacing it outright also provides benefits in preventing loss of stock.

-- ||7- READING DATA FROM MULTIPLE TABLES|| --

-- Whilst we can relatively easily look up customer or item rental data,  does require us to look up multiple things 
-- in order to get in touch with a customer, if they're overdue for example. 
-- Instead, we can INNER JOIN to get all the information we need in one go via the foreign key links the tables share.

SELECT tbl_rentals.rental_ID, 
tbl_rentals.due_date, 
tbl_items.item_ID,
tbl_customers.customer_ID,
tbl_customers.firstname, 
tbl_customers.surname, 
tbl_customers.phone,
tbl_customers.email
FROM tbl_rentals												
INNER JOIN	tbl_items  ON tbl_rentals.item_ID = tbl_items.item_ID
INNER JOIN  tbl_customers ON tbl_rentals.customer_ID = tbl_customers.customer_ID;		
	
-- this gives us everything we need in one table - rental ID number, date the item is due back, item ID number, name & ID of the customer, phone number
-- & email for all rentals.
-- We can refine this even further though by adding a WHERE function to specify customer ID, Item ID etc. 

SELECT tbl_rentals.rental_ID, 
tbl_rentals.due_date, 
tbl_items.item_ID,
tbl_customers.customer_ID,
tbl_customers.firstname, 
tbl_customers.surname, 
tbl_customers.phone,
tbl_customers.email
FROM tbl_rentals												
INNER JOIN	tbl_items  ON tbl_rentals.item_ID = tbl_items.item_ID
INNER JOIN  tbl_customers ON tbl_rentals.customer_ID = tbl_customers.customer_ID
WHERE tbl_customers.customer_ID = '9012-34';

-- this gives us everything we need for the customer with ID 9012-34. It is a lot to enter repeatedly however, and may be difficult to implement
-- through a POS terminal or similar system in this form. So:

-- ||8- CREATING PROCEDURES|| --

-- To make things even easier, we'll put the above within a procedure

DELIMITER $$
CREATE PROCEDURE checkCustRentals(IN parameter_customer_ID VARCHAR(7))
BEGIN 
SELECT tbl_rentals.rental_ID, 
tbl_rentals.due_date, 
tbl_items.item_ID,
tbl_customers.customer_ID,
tbl_customers.firstname, 
tbl_customers.surname, 
tbl_customers.phone,
tbl_customers.email
FROM tbl_rentals												
INNER JOIN	tbl_items  ON tbl_rentals.item_ID = tbl_items.item_ID
INNER JOIN  tbl_customers ON tbl_rentals.customer_ID = tbl_customers.customer_ID
WHERE tbl_customers.customer_ID = parameter_customer_ID;
END$$
DELIMITER $$

-- Now all we need to do to look up a customer's rentals is call that procedure
CALL checkCustRentals('2365-67');

-- We can also do this for Item ID, to check who has rented a specific Item

DELIMITER $$
CREATE PROCEDURE checkItemRentals(IN parameter_item_ID VARCHAR(8))
BEGIN 
SELECT tbl_rentals.rental_ID, 
tbl_rentals.due_date, 
tbl_items.item_ID,
tbl_customers.customer_ID,
tbl_customers.firstname, 
tbl_customers.surname, 
tbl_customers.phone,
tbl_customers.email
FROM tbl_rentals												
INNER JOIN	tbl_items  ON tbl_rentals.item_ID = tbl_items.item_ID
INNER JOIN  tbl_customers ON tbl_rentals.customer_ID = tbl_customers.customer_ID
WHERE tbl_items.item_ID = parameter_Item_ID;
END$$
DELIMITER $$

-- And same again, we just call that function to check who has rented a specific Item
CALL checkItemRentals('002-0052');

-- Here we create a procedure for simplifying customer data removal requests, which only requires the customer account number

DELIMITER $$
CREATE PROCEDURE custDataRemove(IN Parameter_customer_ID VARCHAR(7))
BEGIN
UPDATE tbl_customers SET firstname = 'DELETED', surname = 'DELETED', email = 'DELETED', phone = 'DELETED'
WHERE tbl_customers.customer_ID = parameter_customer_ID;
END$$
DELIMITER $$


CALL custDataRemove('7670-12');
SELECT * FROM tbl_customers WHERE customer_ID = '7670-12';
-- We can see that customer's data has now been scrambled, replacing anything identifying with "DELETED". 

-- PROCEDURES CREATED ARE:
CALL checkCustRentals(' '); -- For finding data based on customer ID number - customer ID goes inbetween the ' '.
CALL checkItemRentals(' '); -- For finding data based on the item ID number - item ID goes inbetween the ' '.
CALL custDataRemove(' '); -- For anonymising identifying customer data but leaving their ID number intact.