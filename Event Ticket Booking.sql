drop database if exists ticket_booking_management;
create database ticket_booking management;
create database ticket_booking_management;
USE ticket_booking_management;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);
CREATE TABLE venues (
    venue_id INT PRIMARY KEY AUTO_INCREMENT,
    venue_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    capacity INT
);
CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    venue_id INT,
    category VARCHAR(50),
    FOREIGN KEY (venue_id) REFERENCES venues(venue_id)
);
CREATE TABLE ticket_types (
    ticket_type_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    ticket_type VARCHAR(50),
    price DECIMAL(10,2),
    available_seats INT,
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    ticket_type_id INT,
    booking_date DATE,
    quantity INT,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(ticket_type_id)
);
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
show tables;

INSERT INTO customers (name, email, phone) VALUES
('Yasaswini', 'yashu@gmail.com', '9490403918'),
('Ramya', 'rama@gmail.com', '9121386593'),
('Rahul', 'rahul@gmail.com', '868036357'),
('Raju', 'raju@gmail.com', '9676357576'),
('Akhil', 'akhii@gmail.com', '8555972100');

SELECT * FROM customers;

INSERT INTO venues (venue_name, city, capacity) VALUES
('Sagarnagar beach', 'Visakhapatnam', 5000),
('Ramoji film city', 'Hyderabad', 3000),
('Forum Mall', 'Bangalore', 8000);

SELECT * FROM venues;

INSERT INTO events
(event_name, event_date, venue_id, category) VALUES
('Music Concerts', '2026-11-15', 1, 'Music'),
('Gen AI Conference', '2026-12-05', 2, 'Technology'),
('Comedy Night', '2026-11-25', 3, 'Comedy'),
('Kabaddi Match', '2026-12-20', 4, 'Sports');

SELECT * FROM events;

INSERT INTO ticket_types
(event_id, ticket_type, price, available_seats) VALUES
(1, 'VIP', 2000, 100),
(1, 'Regular', 600, 50),
(2, 'Premium', 1000, 200),
(2, 'Regular', 700, 50),
(3, 'VIP', 1200, 100),
(3, 'Regular', 500, 300),
(4, 'Premium', 2500, 200),
(4, 'Regular', 1000, 1000);

SELECT * FROM ticket_types;

INSERT INTO bookings
(customer_id, ticket_type_id, booking_date, quantity, total_amount, status) VALUES
(1, 2, '2026-10-11', 2, 4000, 'Confirmed'),
(2, 3, '2026-10-11', 3, 2400, 'Confirmed'),
(3, 4, '2026-10-13', 2, 3000, 'Pending'),
(4, 5, '2026-10-12', 4, 2000, 'Confirmed'),
(5, 6, '2026-10-13', 2, 5000, 'Pending');

SELECT * FROM bookings;

INSERT INTO payments
(booking_id, payment_date, amount, payment_method, payment_status) VALUES
(1, '2026-10-11', 4000, 'UPI', 'Paid'),
(2, '2026-10-11', 2400, 'Card', 'Paid'),
(3, '2026-10-12', 2500, 'UPI', 'Paid'),
(4, '2026-10-12', 2000, 'Cash', 'Paid'),
(5, '2026-10-13', 5900, 'Card', 'Pending');

SELECT * FROM payments;

-- display customer details along with their booking details
SELECT
    c.customer_id,
    c.name,
    b.booking_id,
    b.quantity,
    b.total_amount,
    b.status
FROM customers c
JOIN bookings b
ON c.customer_id = b.customer_id;

-- Inner join: Display customers who have bookings
SELECT
    c.name AS customer_name,
    b.booking_id,
    b.total_amount,
    b.status
FROM customers c
INNER JOIN bookings b
ON c.customer_id = b.customer_id;

-- Right join: Display all bookings and matching customer details
SELECT
    c.name AS customer_name,
    b.booking_id,
    b.quantity,
    b.total_amount,
    b.status
FROM customers c
RIGHT JOIN bookings b
ON c.customer_id = b.customer_id;

-- Cross join: Display every possible customer and event combination
SELECT
    c.name AS customer_name,
    e.event_name
FROM customers c
CROSS JOIN events e;

-- -- Display confirmed bookings
SELECT *
FROM bookings
WHERE status = 'Confirmed';

-- Find total booking amount
SELECT SUM(total_amount) AS total_amount
FROM bookings;

-- Display bookings from highest to lowest amount
SELECT *
FROM bookings
ORDER BY total_amount DESC;

-- Count bookings for each customer
SELECT customer_id, COUNT(*) AS booking_count
FROM bookings
GROUP BY customer_id;

--  Create a view for confirmed bookings
CREATE VIEW confirmed_bookings AS
SELECT
    b.booking_id,
    c.name AS customer_name,
    b.quantity,
    b.total_amount,
    b.status
FROM bookings b
JOIN customers c
ON b.customer_id = c.customer_id
WHERE b.status = 'Confirmed';

--  Display confirmed bookings
SELECT *FROM confirmed_bookings;

--  Create a procedure to display all bookings
DELIMITER //

CREATE PROCEDURE show_bookings()
BEGIN
    SELECT *
    FROM bookings;
END //

DELIMITER ;

CALL show_bookings();

--  Create a procedure to find bookings by customer
DELIMITER //

CREATE PROCEDURE customer_bookings(IN cid INT)
BEGIN
    SELECT *
    FROM bookings
    WHERE customer_id = cid;
END //

DELIMITER ;

CALL customer_bookings(1);

--  Create a trigger to reduce available seats after booking
DELIMITER //

CREATE TRIGGER reduce_available_seats
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    UPDATE ticket_types
    SET available_seats = available_seats - NEW.quantity
    WHERE ticket_type_id = NEW.ticket_type_id;
END //

DELIMITER ;

SHOW TRIGGERS;

--  Start a transaction
START TRANSACTION;
UPDATE bookings
SET status = 'Confirmed'
WHERE booking_id = 3;
COMMIT;


START TRANSACTION;
UPDATE bookings
SET status = 'Cancelled'
WHERE booking_id = 3;
ROLLBACK;

-- 3. Start a transaction
START TRANSACTION;

-- First update
UPDATE bookings
SET status = 'Confirmed'
WHERE booking_id = 3;

-- Create a savepoint

SAVEPOINT booking_update;
UPDATE bookings
SET total_amount = 3500
WHERE booking_id = 3;
ROLLBACK TO booking_update;
COMMIT;