-- Checking if the database already exists, and if does it will backup the database and then delete it.
DROP DATABASE IF EXISTS Bogreden_db;
CREATE DATABASE IF NOT EXISTS Bogreden_db;

-- Creating admin user.
DROP USER IF EXISTS 'Bogreden'@'localhost';
CREATE USER IF NOT EXISTS 'Bogreden'@'localhost' IDENTIFIED BY 'Super123!';
GRANT ALL PRIVILEGES ON Bogreden_db.* TO 'Bogreden'@'localhost';

USE Bogreden_db;

-- Creating logs informations table
CREATE TABLE Logs_Informations(
	Log_ID int NOT NULL AUTO_INCREMENT,
	Log longtext,
    Log_Timestamp timestamp NOT NULL,
    PRIMARY KEY(Log_ID)
);

-- Creating city/zipcode table
CREATE TABLE City_Informations(
	PK_City_ID int NOT NULL AUTO_INCREMENT,
	Zipcode varchar(5) NOT NULL,
	City_name varchar(55) NOT NULL,
    UNIQUE(Zipcode),
    PRIMARY KEY(PK_City_ID)
);

-- Creating index for zipcode
CREATE INDEX IDX_Zipcode
ON City_Informations(Zipcode);

-- Logging everything inserted into the city table.
DELIMITER //
CREATE TRIGGER Log_City_Insert
AFTER INSERT ON City_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT(
    'New city inserted: ', NEW.City_name, 
    ', Zipcode: ', NEW.Zipcode), 
    NOW());
END//
DELIMITER ;

-- Logging all updates made to the city_informations table
DELIMITER //
CREATE TRIGGER Log_City_Update
AFTER UPDATE ON City_Informations FOR EACH ROW
BEGIN
	DECLARE old_city_name varchar(55);
    DECLARE old_zipcode varchar(5);
    
    SET old_city_name = OLD.City_name;
    SET old_zipcode = OLD.Zipcode;
    
	INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
    'City updated: - Old name ,', old_city_name, 
    ' New name - ', NEW.City_name, 
    ' Old zipcode - ', old_zipcode, 
    ' New Zipcode - ', NEW.Zipcode), 
    NOW());
END//
DELIMITER ;

-- Logging everything deleted in the City_Informations table
DELIMITER //
CREATE TRIGGER Log_City_Delete
AFTER DELETE ON City_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'City deleted: City ID - ', OLD.PK_City_ID,
        ', City Name - ', OLD.City_name,
        ', Zipcode - ', OLD.Zipcode
        ), NOW());
END//
DELIMITER ;

-- Creating author table
CREATE TABLE Author_Informations(
	PK_Author_ID int NOT NULL AUTO_INCREMENT,
    Author_FirstName varchar(50) NOT NULL,
    Author_LastName varchar(50) NOT NULL,
    Author_Birthday date NOT NULL,
    FK_Author_Zipcode varchar(5) NOT NULL,
    PRIMARY KEY (PK_Author_ID),
    FOREIGN KEY (FK_Author_Zipcode) REFERENCES City_Informations(Zipcode)
);

-- Creating index for Author ID
CREATE UNIQUE INDEX IDX_Author_ID
ON Author_Informations(PK_Author_ID);

-- Creating index for author name
CREATE INDEX IDX_Author_Name
ON Author_Informations(Author_FirstName, Author_LastName);

-- Logging everything inserted into the author table.
DELIMITER //
CREATE TRIGGER Log_Author_Insert
AFTER INSERT ON Author_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT('
    New author inserted: ', NEW.Author_FirstName, ' ', NEW.Author_LastName, 
    ', Birthday: ', NEW.Author_Birthday), 
    NOW());
END//
DELIMITER ;

-- Logging all updates made to the author_informations table
DELIMITER //
CREATE TRIGGER Log_Author_Update
AFTER UPDATE ON Author_Informations FOR EACH ROW
BEGIN
    DECLARE old_name VARCHAR(100);
    DECLARE new_name VARCHAR(100);
    
    SET old_name = CONCAT(OLD.Author_FirstName, ' ', OLD.Author_LastName);
    SET new_name = CONCAT(NEW.Author_FirstName, ' ', NEW.Author_LastName);
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Author updated: Old name - ', old_name, 
        ', New name - ', new_name, 
        ', Old birthday - ', OLD.Author_Birthday,
        ', New birthday - ', NEW.Author_Birthday,
        ', Old Zipcode - ', OLD.FK_Author_Zipcode, 
        ', New Zipcode - ', NEW.FK_Author_Zipcode
        ), NOW());
END//
DELIMITER ;

-- Logging everything deleted in the Author_Informations table
DELIMITER //
CREATE TRIGGER Log_Author_Delete
AFTER DELETE ON Author_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Author deleted: Author ID - ', OLD.PK_Author_ID,
        ', First Name - ', OLD.Author_FirstName,
        ', Last Name - ', OLD.Author_LastName,
        ', Birthday - ', OLD.Author_Birthday
        ), NOW());
END//
DELIMITER ;

-- Creating book informations table
CREATE TABLE Book_Informations(
	PK_Book_ID int NOT NULL AUTO_INCREMENT,
    Book_Name varchar(100) NOT NULL,
    Book_Pages int NOT NULL,
    Book_Language varchar(30) NOT NULL,
    FK_Book_Author_ID int NOT NULL,
    Book_Publisher varchar(50) NOT NULL,
    Book_Release_Date date NOT NULL,
    Book_Resumé varchar(255) NOT NULL,
    PRIMARY KEY (PK_Book_ID),
	CONSTRAINT FK_Book_Author FOREIGN KEY (FK_Book_Author_ID) REFERENCES Author_Informations(PK_Author_ID)
);

-- Creating index for PK_Book_ID
CREATE UNIQUE INDEX IDX_PK_Book_ID
ON Book_Informations(Pk_Book_ID);

-- Creating index for Book_Language
CREATE INDEX IDX_Book_Language
ON Book_Informations(Book_Language);

-- Creating index for Book_Publisher
CREATE INDEX IDX_Book_Publisher
ON Book_Informations(Book_Publisher);

-- Creating index for Book_Name
CREATE INDEX IDX_Book_Name
ON Book_Informations(Book_Name);

-- Creating index for Book_Release_Date
CREATE INDEX IDX_Book_Release_Date
ON Book_Informations(Book_Release_Date);

-- Creating index for Book_Pages
CREATE INDEX IDX_Book_Pages
ON Book_Informations(Book_Pages);

-- Logging everything inserted into Book_Informations table
DELIMITER //
CREATE TRIGGER Log_Book_Insert
AFTER INSERT ON Book_Informations FOR EACH ROW
BEGIN
    DECLARE author_name VARCHAR(100);
    SELECT CONCAT(Author_FirstName, ' ', Author_LastName) INTO author_name
    FROM Author_Informations
    WHERE PK_Author_ID = NEW.FK_Book_Author_ID;
    
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT(
        'New book inserted: ',
        'Book ID - ', NEW.PK_Book_ID, 
        ', Name - ', NEW.Book_Name,
        ', Author - ', author_name, 
        ', Pages - ', NEW.Book_Pages, 
        ', Language - ', NEW.Book_Language, 
        ', Author ID - ', NEW.FK_Book_Author_ID, 
        ', Publisher - ', NEW.Book_Publisher, 
        ', Release Date - ', NEW.Book_Release_Date, 
        ', Resumé - ', NEW.Book_Resumé
        ), NOW());
END//
DELIMITER ;

-- Logging all updates made to the book_informations table
DELIMITER //
CREATE TRIGGER Log_Book_Update
AFTER UPDATE ON Book_Informations FOR EACH ROW
BEGIN
    DECLARE old_author_name VARCHAR(100);
    DECLARE new_author_name VARCHAR(100);
    
    SET old_author_name = (SELECT CONCAT(Author_FirstName, ' ', Author_LastName) FROM Author_Informations WHERE PK_Author_ID = OLD.FK_Book_Author_ID);
    SET new_author_name = (SELECT CONCAT(Author_FirstName, ' ', Author_LastName) FROM Author_Informations WHERE PK_Author_ID = NEW.FK_Book_Author_ID);
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Book updated: Book ID - ', OLD.PK_Book_ID,
        ', Book Name - ', NEW.Book_Name,
        ', Old Author - ', old_author_name,
        ', New Author - ', new_author_name,
        ', Old Pages - ', OLD.Book_Pages,
        ', New Pages - ', NEW.Book_Pages,
        ', Old Language - ', OLD.Book_Language,
        ', New Language - ', NEW.Book_Language,
        ', Old Publisher - ', OLD.Book_Publisher,
        ', New Publisher - ', NEW.Book_Publisher,
        ', Old Release Date - ', OLD.Book_Release_Date,
        ', New Release Date - ', NEW.Book_Release_Date,
        ', Old Resumé - ', OLD.Book_Resumé,
        ', New Resumé - ', NEW.Book_Resumé
        ), NOW());
END//
DELIMITER ;

-- Logging everything deleted in Book_Informations table
DELIMITER //
CREATE TRIGGER Log_Book_Delete
AFTER DELETE ON Book_Informations FOR EACH ROW
BEGIN
    DECLARE author_name VARCHAR(100);
    
    SELECT CONCAT(Author_FirstName, ' ', Author_LastName) INTO author_name
    FROM Author_Informations
    WHERE PK_Author_ID = OLD.FK_Book_Author_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Book deleted: Book ID - ', OLD.PK_Book_ID,
        ', Book Name - ', OLD.Book_Name,
        ', Author - ', author_name,
        ', Pages - ', OLD.Book_Pages,
        ', Language - ', OLD.Book_Language,
        ', Publisher - ', OLD.Book_Publisher,
        ', Release Date - ', OLD.Book_Release_Date,
        ', Resumé - ', OLD.Book_Resumé
        ), NOW());
END//
DELIMITER ;

-- Creating price informations table
CREATE TABLE Price_Informations(
	PK_Price_ID int NOT NULL AUTO_INCREMENT,
    Price decimal(8, 2) NOT NULL, 
    FK_Price_Book_ID int NOT NULL,
    Price_Sale int NOT NULL,
    PRIMARY KEY (PK_Price_ID),
    CONSTRAINT FK_Price_Book FOREIGN KEY (FK_Price_Book_ID) REFERENCES Book_Informations(PK_Book_ID)
);

-- Creating index for PK_Price_ID
CREATE INDEX IDX_PK_Price_ID
ON Price_Informations(PK_Price_ID);

-- Creating index for Price
CREATE INDEX IDX_Price
ON Price_Informations(Price);

-- Creating index for FK_Price_Book_ID
CREATE INDEX IDX_FK_Price_Book_ID
ON Price_Informations(FK_Price_Book_ID);

-- Creating index for Price_Sale
CREATE INDEX IDX_Price_Sale
ON Price_Informations(Price_Sale);

DELIMITER //
CREATE TRIGGER Log_Price_Insert
AFTER INSERT ON Price_Informations FOR EACH ROW
BEGIN
    DECLARE book_name VARCHAR(100);
    SELECT Book_Name INTO book_name
    FROM Book_Informations
    WHERE PK_Book_ID = NEW.FK_Price_Book_ID;
    
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT(
        'New price inserted: ',
        'Price ID - ', NEW.PK_Price_ID, 
        ', Price - ', NEW.Price,
        ', Book - ', book_name, 
        ', Sale Price - ', NEW.Price_Sale
        ), NOW());
END//
DELIMITER ;
-- Logging every update made to the price_informations table
DELIMITER //
CREATE TRIGGER Log_Price_Update
AFTER UPDATE ON Price_Informations FOR EACH ROW
BEGIN
    DECLARE book_name VARCHAR(100);
    
    SET book_name = (SELECT Book_Name FROM Book_Informations WHERE PK_Book_ID = NEW.FK_Price_Book_ID);
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Price updated: Price ID - ', OLD.PK_Price_ID,
        ', Book - ', book_name,
        ', Old Price - ', OLD.Price,
        ', New Price - ', NEW.Price,
        ', Old Sale Price - ', OLD.Price_Sale,
        ', New Sale Price - ', NEW.Price_Sale
        ), NOW());
END//
DELIMITER ;

-- Logging every deleted price
DELIMITER //
CREATE TRIGGER Log_Price_Delete
AFTER DELETE ON Price_Informations FOR EACH ROW
BEGIN
    DECLARE book_name VARCHAR(100);
    
    SELECT Book_Name INTO book_name
    FROM Book_Informations
    WHERE PK_Book_ID = OLD.FK_Price_Book_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Price information deleted: Price ID - ', OLD.PK_Price_ID,
        ', Book - ', book_name,
        ', Price - ', OLD.Price,
        ', Sale Price - ', OLD.Price_Sale
        ), NOW());
END//
DELIMITER ;

-- Creating customer informations table
CREATE TABLE Customer_Informations(
	PK_Customer_ID int NOT NULL AUTO_INCREMENT,
    Customer_First_Name varchar(50) NOT NULL,
    Customer_Last_Name varchar(50) NOT NULL,
    Customer_Email varchar(150) NOT NULL,
    Customer_UserName varchar(55) NOT NULL,
    Customer_Password varchar(55) NOT NULL,
    UNIQUE(Customer_UserName),
    UNIQUE(Customer_Email),
    PRIMARY KEY (PK_Customer_ID)
);

-- Creating index for PK_Customer_ID
CREATE INDEX IDX_PK_Customer_ID
ON Customer_Informations(PK_Customer_ID);

-- Creating index for Customer_Email
CREATE INDEX IDX_Customer_Email
ON Customer_Informations(Customer_Email);

-- Creating index for Customer_Username
CREATE INDEX IDX_Customer_Username
ON Customer_Informations(Customer_Username);

-- Logging everything inserted into Customer_Informations table
DELIMITER //
CREATE TRIGGER Log_Customer_Insert
AFTER INSERT ON Customer_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT(
        'New customer inserted: ',
        'Customer ID - ', NEW.PK_Customer_ID, 
        ', First Name - ', NEW.Customer_First_Name,
        ', Last Name - ', NEW.Customer_Last_Name,
        ', Email - ', NEW.Customer_Email,
        ', Username - ', NEW.Customer_UserName,
        ', Password - ', NEW.Customer_Password
        ), NOW());
END//
DELIMITER ;

-- Logging every update made to the customer_informations table
DELIMITER //
CREATE TRIGGER Log_Customer_Update
AFTER UPDATE ON Customer_Informations FOR EACH ROW
BEGIN
    DECLARE old_customer_name VARCHAR(100);
    DECLARE new_customer_name VARCHAR(100);
    
    SET old_customer_name = CONCAT(OLD.Customer_First_Name, ' ', OLD.Customer_Last_Name);
    SET new_customer_name = CONCAT(NEW.Customer_First_Name, ' ', NEW.Customer_Last_Name);
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Customer updated: Customer ID - ', OLD.PK_Customer_ID,
        ', Old Name - ', old_customer_name,
        ', New Name - ', new_customer_name,
        ', Old Email - ', OLD.Customer_Email,
        ', New Email - ', NEW.Customer_Email,
        ', Old Username - ', OLD.Customer_UserName,
        ', New Username - ', NEW.Customer_UserName,
        ', Old Password - ', OLD.Customer_Password,
        ', New Password - ', NEW.Customer_Password
        ), NOW());
END//
DELIMITER ;

-- Logging every deleted customer
DELIMITER //
CREATE TRIGGER Log_Customer_Delete
AFTER DELETE ON Customer_Informations FOR EACH ROW
BEGIN
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Customer deleted: Customer ID - ', OLD.PK_Customer_ID,
        ', First Name - ', OLD.Customer_First_Name,
        ', Last Name - ', OLD.Customer_Last_Name,
        ', Email - ', OLD.Customer_Email,
        ', Username - ', OLD.Customer_UserName,
        ', Password - ', OLD.Customer_Password
        ), NOW());
END//
DELIMITER ;

-- Creating Address informations table
CREATE TABLE Address_Informations(
	PK_Address_ID int NOT NULL AUTO_INCREMENT,
    FK_Address_Zipcode varchar(5) NOT NULL,
    FK_Customer_ID int NOT NULL,
    Address varchar(255) NOT NULL,
    PRIMARY KEY (PK_Address_ID),
	FOREIGN KEY (FK_Address_Zipcode) REFERENCES City_Informations(Zipcode),
	FOREIGN KEY (FK_Customer_ID) REFERENCES Customer_Informations(PK_Customer_ID)
);

-- Making index for PK_Address_ID
CREATE INDEX IDX_PK_Address_ID
ON Address_Informations(PK_Address_ID);

-- Logging everything inserted into address informations table
DELIMITER //
CREATE TRIGGER Log_Address_Insert
AFTER INSERT ON Address_Informations FOR EACH ROW
BEGIN
    DECLARE customer_name VARCHAR(100);
    
    SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) INTO customer_name
    FROM Customer_Informations
    WHERE PK_Customer_ID = NEW.FK_Customer_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'New address inserted for customer: ', customer_name,
        ', Address: ', NEW.Address
        ), NOW());
END//
DELIMITER ;

-- Logging everything updated in the address informations table
DELIMITER //
CREATE TRIGGER Log_Address_Update
AFTER UPDATE ON Address_Informations FOR EACH ROW
BEGIN
    DECLARE customer_name VARCHAR(100);
    
    SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) INTO customer_name
    FROM Customer_Informations
    WHERE PK_Customer_ID = NEW.FK_Customer_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Address updated for customer: ', customer_name,
        ', Old Address: ', OLD.Address,
        ', New Address: ', NEW.Address
        ), NOW());
END//
DELIMITER ;

-- Logging every deleted value in the address informations table
DELIMITER //
CREATE TRIGGER Log_Address_Delete
AFTER DELETE ON Address_Informations FOR EACH ROW
BEGIN
    DECLARE customer_name VARCHAR(100);
    
    SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) INTO customer_name
    FROM Customer_Informations
    WHERE PK_Customer_ID = OLD.FK_Customer_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Address deleted for customer: ', customer_name,
        ', Deleted Address: ', OLD.Address
        ), NOW());
END//
DELIMITER ;

-- Creating order informations table
CREATE TABLE Order_Informations(
	Order_ID int NOT NULL AUTO_INCREMENT,
    FK_Order_Book_ID int NOT NULL,
    FK_Order_Customer_ID int NOT NULL,
    PRIMARY KEY (Order_ID),
    FOREIGN KEY (FK_Order_Book_ID) REFERENCES Book_Informations(PK_Book_ID),
    FOREIGN KEY (FK_Order_Customer_ID) REFERENCES Customer_Informations(PK_Customer_ID)
);

-- Creating index for Order_ID
CREATE INDEX IDX_Order_ID
ON Order_Informations(Order_ID);

-- Creating index for FK_Order_Customer_ID
CREATE INDEX IDX_FK_Order_Customer_ID
ON Order_Informations(FK_Order_Customer_ID);

-- Logging everything inserted into Order_Informations table
DELIMITER //
CREATE TRIGGER Log_Order_Insert
AFTER INSERT ON Order_Informations FOR EACH ROW
BEGIN
    DECLARE book_name VARCHAR(100);
    DECLARE customer_name VARCHAR(100);
    
    SELECT Book_Name INTO book_name
    FROM Book_Informations
    WHERE PK_Book_ID = NEW.FK_Order_Book_ID;
    
    SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) INTO customer_name
    FROM Customer_Informations
    WHERE PK_Customer_ID = NEW.FK_Order_Customer_ID;
    
    INSERT INTO Logs_Informations (Log, Log_Timestamp)
    VALUES (CONCAT(
        'New order inserted: ',
        'Order ID - ', NEW.Order_ID, 
        ', Book - ', book_name,
        ', Customer - ', customer_name
        ), NOW());
END//
DELIMITER ;

-- Logging all updates made to the order_informations table
DELIMITER //
CREATE TRIGGER Log_Order_Update
AFTER UPDATE ON Order_Informations FOR EACH ROW
BEGIN
    DECLARE old_book_name VARCHAR(100);
    DECLARE new_book_name VARCHAR(100);
    DECLARE customer_name VARCHAR(100);
    
    SET old_book_name = (SELECT Book_Name FROM Book_Informations WHERE PK_Book_ID = OLD.FK_Order_Book_ID);
    SET new_book_name = (SELECT Book_Name FROM Book_Informations WHERE PK_Book_ID = NEW.FK_Order_Book_ID);
    SET customer_name = (SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) FROM Customer_Informations WHERE PK_Customer_ID = NEW.FK_Order_Customer_ID);
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Order updated: Order ID - ', OLD.Order_ID,
        ', Old Book - ', old_book_name,
        ', New Book - ', new_book_name,
        ', Customer - ', customer_name
        ), NOW());
END//
DELIMITER ;

-- Logging all deleted orders in the order_informations table
DELIMITER //
CREATE TRIGGER Log_Order_Delete
AFTER DELETE ON Order_Informations FOR EACH ROW
BEGIN
    DECLARE book_name VARCHAR(100);
    DECLARE customer_name VARCHAR(100);
    
    SELECT Book_Name INTO book_name
    FROM Book_Informations
    WHERE PK_Book_ID = OLD.FK_Order_Book_ID;
    
    SELECT CONCAT(Customer_First_Name, ' ', Customer_Last_Name) INTO customer_name
    FROM Customer_Informations
    WHERE PK_Customer_ID = OLD.FK_Order_Customer_ID;
    
    INSERT INTO Logs_Informations(Log, Log_Timestamp)
    VALUES(CONCAT(
        'Order deleted: Order ID - ', OLD.Order_ID,
        ', Book - ', book_name,
        ', Customer - ', customer_name
        ), NOW());
END//
DELIMITER ;

-- Create procedure to select all authors
DELIMITER //
CREATE PROCEDURE GetAllAuthorNames()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		-- Error handling (exceptions)
		SHOW ERRORS;
	END;
    SELECT CONCAT(Author_FirstName, ' ', Author_LastName) AS Full_Name
    FROM Author_Informations;
END//
DELIMITER ;

-- Create procedure to select all book names
DELIMITER //
CREATE PROCEDURE GetAllBooks()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		-- Error handling (exceptions)
		SHOW ERRORS;
	END;
    SELECT * FROM Book_Informations;
END//

DELIMITER ;
DELETE FROM City_Informations;
-- IKKE EN RIGTIGT KOMMENTAR I MIN KODE!! DETTE ER BLOT DEN PATH DU BURDE ÆNDRE SÅ DEN INDSÆTTER MIN CSV FIL.
LOAD DATA INFILE 'C:\\Users\\zbc23rope\\Desktop\\Aflevering\\cities.csv'
INTO TABLE City_Informations
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Zipcode, City_name);

-- Testing if a username and password already exists in the database

DELIMITER //
CREATE PROCEDURE CustomerLogin(
    IN p_username VARCHAR(55),
    IN p_password VARCHAR(55),
    OUT p_exists BOOLEAN
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Error handling (exceptions)
        SHOW ERRORS;
    END;
    
    SET @query = 'SELECT EXISTS(SELECT 1 FROM Customer_Informations WHERE Customer_UserName = ? AND Customer_Password = ?)';
    PREPARE stmt FROM @query;
    EXECUTE stmt USING @p_username, @p_password;
    DEALLOCATE PREPARE stmt;
    
    SELECT @p_exists INTO p_exists;
END //
DELIMITER ;
-- Inserting test data

INSERT INTO Author_Informations (Author_FirstName, Author_LastName, Author_Birthday, FK_Author_Zipcode) 
VALUES 
('John', 'Doe', '1985-07-15', '4100');

INSERT INTO Book_Informations (Book_Name, Book_Pages, Book_Language, FK_Book_Author_ID, Book_Publisher, Book_Release_Date, Book_Resumé) 
VALUES 
('The Great Gatsby', 180, 'English', 1, 'Scribner', '1925-04-10', 'The Great Gatsby is a novel by American writer F. Scott Fitzgerald.');

INSERT INTO Price_Informations (Price, FK_Price_Book_ID, Price_Sale)
VALUES 
(15.99, 1, 0);

INSERT INTO Customer_Informations (Customer_First_Name, Customer_Last_Name, Customer_Email, Customer_UserName, Customer_Password) 
VALUES 
('Alice', 'Smith', 'alice@example.com', 'alice_smith', 'password123');

INSERT INTO Address_Informations (FK_Address_Zipcode, FK_Customer_ID, Address) 
VALUES 
('4800', 1, 'Egebjeg Stationsvej 2');

INSERT INTO Order_Informations (FK_Order_Book_ID, FK_Order_Customer_ID) 
VALUES 
(1, 1);

SELECT * FROM Logs_Informations