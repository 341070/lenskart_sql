-- Create database (safe even if it already exists)
CREATE DATABASE IF NOT EXISTS lenskart_db;
USE lenskart_db;
-- =========================
-- 1. MASTER TABLES
-- =========================

-- 1.1 Customers
CREATE TABLE customer_kart (
    customer_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    phone             VARCHAR(15) NOT NULL,
    date_of_birth     DATE NULL,
    gender            ENUM('M','F','O') NULL,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 1.2 Addresses (multiple per customer)
CREATE TABLE customer_address (
    address_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT UNSIGNED NOT NULL,
    address_type      ENUM('HOME','OFFICE','OTHER') NOT NULL DEFAULT 'HOME',
    line1             VARCHAR(150) NOT NULL,
    line2             VARCHAR(150) NULL,
    city              VARCHAR(50) NOT NULL,
    state             VARCHAR(50) NOT NULL,
    pincode           VARCHAR(10) NOT NULL,
    country           VARCHAR(50) NOT NULL DEFAULT 'India',
    is_default        TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id)
        REFERENCES customer_kart(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.3 Stores
CREATE TABLE stores (
    store_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_name        VARCHAR(100) NOT NULL,
    city              VARCHAR(50) NOT NULL,
    state             VARCHAR(50) NOT NULL,
    pincode           VARCHAR(10) NOT NULL,
    phone             VARCHAR(15) NULL,
    opened_on         DATE NULL
) ENGINE=InnoDB;

-- 1.4 Staff
CREATE TABLE staff (
    staff_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_id          INT UNSIGNED NOT NULL,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    role              ENUM('OPTOMETRIST','STORE_MANAGER','SALES_ASSOCIATE','TECHNICIAN') NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    phone             VARCHAR(15) NOT NULL,
    date_joined       DATE NOT NULL,
    is_active         TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.5 Product categories
CREATE TABLE product_categories (
    category_id       TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name     VARCHAR(50) NOT NULL UNIQUE,
    description       VARCHAR(200) NULL
) ENGINE=InnoDB;

-- 1.6 Products
CREATE TABLE products (
    product_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id       TINYINT UNSIGNED NOT NULL,
    sku               VARCHAR(30) NOT NULL UNIQUE,
    product_name      VARCHAR(150) NOT NULL,
    brand             VARCHAR(100) NOT NULL,
    frame_type        ENUM('FULL_RIM','HALF_RIM','RIMLESS') NULL,
    lens_type         ENUM('SINGLE_VISION','BIFOCAL','PROGRESSIVE','COMPUTER','CONTACT') NULL,
    color             VARCHAR(50) NULL,
    material          VARCHAR(50) NULL,
    gender_target     ENUM('MEN','WOMEN','UNISEX','KIDS') NOT NULL DEFAULT 'UNISEX',
    price             DECIMAL(10,2) NOT NULL,
    is_active         TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (category_id)
        REFERENCES product_categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.7 Suppliers
CREATE TABLE suppliers (
    supplier_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name     VARCHAR(100) NOT NULL,
    contact_person    VARCHAR(100) NULL,
    phone             VARCHAR(15) NULL,
    email             VARCHAR(100) NULL,
    city              VARCHAR(50) NULL,
    state             VARCHAR(50) NULL
) ENGINE=InnoDB;

-- =========================
-- 2. INVENTORY & PROCUREMENT
-- =========================

-- 2.1 Purchase Orders (from suppliers)
CREATE TABLE purchase_orders (
    po_id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_id       INT UNSIGNED NOT NULL,
    store_id          INT UNSIGNED NOT NULL,
    po_date           DATE NOT NULL,
    status            ENUM('CREATED','ORDERED','RECEIVED','CANCELLED') NOT NULL DEFAULT 'CREATED',
    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.2 Purchase Order Items
CREATE TABLE purchase_order_items (
    po_id             INT UNSIGNED NOT NULL,
    product_id        INT UNSIGNED NOT NULL,
    quantity_ordered  INT UNSIGNED NOT NULL,
    unit_cost         DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (po_id, product_id),
    FOREIGN KEY (po_id)
        REFERENCES purchase_orders(po_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.3 Store-wise Inventory
CREATE TABLE store_inventory (
    store_id          INT UNSIGNED NOT NULL,
    product_id        INT UNSIGNED NOT NULL,
    batch_number      VARCHAR(30) NOT NULL,
    quantity          INT NOT NULL,
    last_updated      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (store_id, product_id, batch_number),
    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 3. APPOINTMENTS & PRESCRIPTIONS
-- =========================

-- 3.1 Eye Test Appointments
CREATE TABLE eye_test_appointments (
    appointment_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT UNSIGNED NOT NULL,
    store_id          INT UNSIGNED NOT NULL,
    staff_id          INT UNSIGNED NOT NULL, -- usually optometrist
    appointment_time  DATETIME NOT NULL,
    status            ENUM('BOOKED','COMPLETED','CANCELLED','NO_SHOW') NOT NULL DEFAULT 'BOOKED',
    booked_channel    ENUM('ONLINE','STORE','CALL_CENTER') NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customer_kart(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.2 Prescriptions
CREATE TABLE prescriptions (
    prescription_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    appointment_id    INT UNSIGNED NOT NULL,
    customer_id       INT UNSIGNED NOT NULL,
    sphere_left       DECIMAL(4,2) NULL,
    sphere_right      DECIMAL(4,2) NULL,
    cylinder_left     DECIMAL(4,2) NULL,
    cylinder_right    DECIMAL(4,2) NULL,
    axis_left         SMALLINT UNSIGNED NULL,
    axis_right        SMALLINT UNSIGNED NULL,
    add_power_left    DECIMAL(4,2) NULL,
    add_power_right   DECIMAL(4,2) NULL,
    pd                DECIMAL(4,1) NULL, -- pupillary distance
    issued_on         DATE NOT NULL,
    valid_till        DATE NULL,
    FOREIGN KEY (appointment_id)
        REFERENCES eye_test_appointments(appointment_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (customer_id)
        REFERENCES customer_kart(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 4. ORDERS & PAYMENTS
-- =========================

-- 4.1 Orders
CREATE TABLE orders (
    order_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT UNSIGNED NOT NULL,
    store_id          INT UNSIGNED NULL, -- null if purely online
    order_date        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            ENUM('PENDING','CONFIRMED','IN_PROGRESS','DISPATCHED','DELIVERED','CANCELLED','RETURNED') NOT NULL DEFAULT 'PENDING',
    total_amount      DECIMAL(10,2) NOT NULL,
    payment_status    ENUM('PENDING','PAID','REFUNDED') NOT NULL DEFAULT 'PENDING',
    channel           ENUM('ONLINE','STORE') NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customer_kart(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4.2 Order Items
CREATE TABLE order_items (
    order_id          INT UNSIGNED NOT NULL,
    product_id        INT UNSIGNED NOT NULL,
    quantity          SMALLINT UNSIGNED NOT NULL,
    unit_price        DECIMAL(10,2) NOT NULL,
    discount_percent  DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    prescription_id   INT UNSIGNED NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(prescription_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4.3 Payments
CREATE TABLE payments (
    payment_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id          INT UNSIGNED NOT NULL,
    payment_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount            DECIMAL(10,2) NOT NULL,
    payment_mode      ENUM('CARD','UPI','NET_BANKING','WALLET','CASH') NOT NULL,
    transaction_ref   VARCHAR(50) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================
-- SAMPLE DATA
-- =========================

-- Product categories
INSERT INTO product_categories (category_name, description) VALUES
('FRAME', 'Spectacle frames'),
('LENS', 'Prescription lenses'),
('CONTACT_LENS', 'Contact lenses'),
('ACCESSORY', 'Cases, cleaners, etc.');

-- Stores
INSERT INTO stores (store_name, city, state, pincode, phone, opened_on) VALUES
('Lenskart Phoenix Mall', 'Pune', 'Maharashtra', '411036', '9123456789', '2020-03-01'),
('Lenskart Connaught Place', 'New Delhi', 'Delhi', '110001', '9876543210', '2019-10-15');

-- Staff
INSERT INTO staff (store_id, first_name, last_name, role, email, phone, date_joined) VALUES
(1, 'Rohit', 'Sharma', 'OPTOMETRIST', 'rohit.optom@lenskart.com', '9000000001', '2021-01-10'),
(1, 'Sneha', 'Patil', 'SALES_ASSOCIATE', 'sneha.sales@lenskart.com', '9000000002', '2022-06-05'),
(2, 'Ankit', 'Verma', 'STORE_MANAGER', 'ankit.manager@lenskart.com', '9000000003', '2020-11-20');

-- Customers  ✅ correct table name: customer_kart
INSERT INTO customer_kart (first_name, last_name, email, phone, date_of_birth, gender) VALUES
('Aryan', 'Kulkarni', 'aryan.k@example.com', '9811111111', '1998-07-15', 'M'),
('Priya', 'Mehta',   'priya.m@example.com', '9822222222', '1995-02-23', 'F');

-- Customer addresses
INSERT INTO customer_address (customer_id, address_type, line1, city, state, pincode, is_default)
VALUES
(1, 'HOME', 'A-101, Koregaon Park', 'Pune', 'Maharashtra', '411001', 1),
(2, 'HOME', 'B-502, Andheri East',  'Mumbai', 'Maharashtra', '400059', 1);

-- Products
INSERT INTO products (category_id, sku, product_name, brand, frame_type, lens_type, color, material, gender_target, price)
VALUES
(1, 'FRM001', 'Classic Full Rim Black', 'Lenskart Air', 'FULL_RIM', NULL, 'Black', 'TR90', 'UNISEX', 1499.00),
(1, 'FRM002', 'Rimless Premium Gold', 'John Jacobs', 'RIMLESS', NULL, 'Gold', 'Metal', 'MEN', 3499.00),
(2, 'LNS001', 'Single Vision Blue Cut', 'Lenskart', NULL, 'SINGLE_VISION', NULL, 'Polycarbonate', 'UNISEX', 2000.00),
(3, 'CNT001', 'Monthly Contact Lens', 'Bausch & Lomb', NULL, 'CONTACT', NULL, 'Hydrogel', 'UNISEX', 1200.00);

-- Suppliers
INSERT INTO suppliers (supplier_name, contact_person, phone, email, city, state) VALUES
('JJ Frames Pvt Ltd', 'Rahul Singh', '9898989898', 'rahul@jjframes.com', 'Gurugram', 'Haryana'),
('BL Lenses India', 'Kavita Rao', '9797979797', 'kavita@bllenses.com', 'Mumbai', 'Maharashtra');

-- Purchase orders
INSERT INTO purchase_orders (supplier_id, store_id, po_date, status) VALUES
(1, 1, '2025-11-01', 'RECEIVED'),
(2, 1, '2025-11-05', 'ORDERED');

-- Purchase order items
INSERT INTO purchase_order_items (po_id, product_id, quantity_ordered, unit_cost) VALUES
(1, 1, 50, 800.00),
(1, 2, 20, 2200.00),
(2, 3, 40, 900.00);

-- Store inventory
INSERT INTO store_inventory (store_id, product_id, batch_number, quantity)
VALUES
(1, 1, 'BATCH-FRM001-01', 45),
(1, 2, 'BATCH-FRM002-01', 18),
(1, 3, 'BATCH-LNS001-01', 40);

-- Eye test appointments
INSERT INTO eye_test_appointments (customer_id, store_id, staff_id, appointment_time, status, booked_channel)
VALUES
(1, 1, 1, '2025-11-10 11:00:00', 'COMPLETED', 'ONLINE'),
(2, 1, 1, '2025-11-12 16:30:00', 'BOOKED', 'STORE');

-- Prescriptions (for completed appointment)
INSERT INTO prescriptions (
    appointment_id, customer_id, sphere_left, sphere_right,
    cylinder_left, cylinder_right, axis_left, axis_right,
    add_power_left, add_power_right, pd, issued_on, valid_till
) VALUES
(1, 1, -1.50, -1.25, -0.50, -0.75, 180, 170, 1.00, 1.00, 63.5, '2025-11-10', '2027-11-10');

-- Orders
INSERT INTO orders (customer_id, store_id, order_date, status, total_amount, payment_status, channel)
VALUES
(1, 1, '2025-11-10 12:00:00', 'DELIVERED', 4999.00, 'PAID', 'STORE'),
(2, NULL, '2025-11-13 10:15:00', 'CONFIRMED', 2699.00, 'PENDING', 'ONLINE');

-- Order items (linking a frame + lens with prescription)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent, prescription_id) VALUES
(1, 1, 1, 1499.00, 10.00, 1),   -- Frame
(1, 3, 1, 3500.00, 0.00, 1),    -- Lenses
(2, 2, 1, 2699.00, 5.00, NULL); -- Sunglasses / frame without RX

-- Payments
INSERT INTO payments (order_id, amount, payment_mode, transaction_ref) VALUES
(1, 4999.00, 'CARD', 'TXN20251110A'),
(2, 2699.00, 'UPI',  'TXN20251113B');

SHOW TABLES;
SELECT * FROM customer_kart;
SELECT * FROM orders;
SELECT * FROM eye_test_appointments;

