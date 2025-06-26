-- DoriaV2 E-commerce Database Initialization
CREATE DATABASE IF NOT EXISTS doriav2;
USE doriav2;

-- Create user for DoriaV2 application
CREATE USER IF NOT EXISTS 'doriav2_user'@'%' IDENTIFIED BY 'doriav2_password';
GRANT ALL PRIVILEGES ON doriav2.* TO 'doriav2_user'@'%';

-- Create Asterisk database for telephony system
CREATE DATABASE IF NOT EXISTS asterisk;

-- Grant permissions on asterisk database to doriav2_user
GRANT ALL PRIVILEGES ON asterisk.* TO 'doriav2_user'@'%';
FLUSH PRIVILEGES;

-- Create CDR table in asterisk database
USE asterisk;
CREATE TABLE IF NOT EXISTS cdr (
    calldate datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clid varchar(80) NOT NULL DEFAULT '',
    src varchar(80) NOT NULL DEFAULT '',
    dst varchar(80) NOT NULL DEFAULT '',
    dcontext varchar(80) NOT NULL DEFAULT '',
    channel varchar(80) NOT NULL DEFAULT '',
    dstchannel varchar(80) NOT NULL DEFAULT '',
    lastapp varchar(80) NOT NULL DEFAULT '',
    lastdata varchar(80) NOT NULL DEFAULT '',
    duration int(11) NOT NULL DEFAULT 0,
    billsec int(11) NOT NULL DEFAULT 0,
    disposition varchar(45) NOT NULL DEFAULT '',
    amaflags int(11) NOT NULL DEFAULT 0,
    accountcode varchar(20) NOT NULL DEFAULT '',
    uniqueid varchar(32) NOT NULL DEFAULT '',
    userfield varchar(255) NOT NULL DEFAULT '',
    peeraccount varchar(20) NOT NULL DEFAULT '',
    linkedid varchar(32) NOT NULL DEFAULT '',
    sequence int(11) NOT NULL DEFAULT 0,
    INDEX (calldate),
    INDEX (dst),
    INDEX (accountcode)
);

-- Switch back to doriav2 database for the rest of the initialization
USE doriav2;

-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL
);

-- Categories table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id INT NULL,
    image_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    sale_price DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    category_id INT,
    weight DECIMAL(8, 2),
    dimensions VARCHAR(100),
    image_url VARCHAR(255),
    gallery JSON,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Addresses table
CREATE TABLE addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('billing', 'shipping') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    company VARCHAR(100),
    address_line_1 VARCHAR(200) NOT NULL,
    address_line_2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'France',
    phone VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_amount DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    shipping_address JSON,
    billing_address JSON,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order items table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Shopping cart table
CREATE TABLE shopping_cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id)
);

-- Reviews table
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_review (user_id, product_id)
);

-- Admin users table
CREATE TABLE admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'editor') DEFAULT 'editor',
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
-- Categories
INSERT INTO categories (name, description, slug, sort_order) VALUES
('Electronics', 'Electronic devices and accessories', 'electronics', 1),
('Clothing', 'Fashion and apparel', 'clothing', 2),
('Home & Garden', 'Home improvement and garden supplies', 'home-garden', 3),
('Books', 'Books and literature', 'books', 4),
('Sports', 'Sports equipment and accessories', 'sports', 5);

-- Users
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, email_verified) VALUES
('john_doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Doe', '+33123456789', TRUE),
('jane_smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jane', 'Smith', '+33987654321', TRUE),
('bob_wilson', 'bob@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bob', 'Wilson', '+33555666777', FALSE);

-- Products
INSERT INTO products (name, description, short_description, sku, price, sale_price, stock_quantity, category_id, is_active, is_featured) VALUES
('iPhone 14 Pro', 'Latest Apple smartphone with advanced features', 'Apple iPhone 14 Pro 128GB', 'IPHONE-14-PRO-128', 1099.00, 999.00, 50, 1, TRUE, TRUE),
('Samsung Galaxy S23', 'High-end Android smartphone', 'Samsung Galaxy S23 256GB', 'GALAXY-S23-256', 899.00, NULL, 30, 1, TRUE, FALSE),
('Mens Cotton T-Shirt', 'Comfortable cotton t-shirt for men', 'Premium quality cotton t-shirt', 'TSHIRT-MEN-001', 29.99, 24.99, 100, 2, TRUE, FALSE),
('Wireless Headphones', 'Bluetooth wireless headphones with noise cancellation', 'Premium wireless audio experience', 'HEADPHONES-WL-001', 199.99, 179.99, 25, 1, TRUE, TRUE),
('Garden Hose 50ft', 'Durable garden hose for outdoor use', 'Heavy-duty 50-foot garden hose', 'HOSE-50FT-001', 49.99, NULL, 75, 3, TRUE, FALSE);

-- Admin users
INSERT INTO admin_users (username, email, password_hash, role, first_name, last_name) VALUES
('admin', 'admin@doriav2.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'Admin', 'User'),
('manager', 'manager@doriav2.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'manager', 'Manager', 'User');

-- Addresses
INSERT INTO addresses (user_id, type, first_name, last_name, address_line_1, city, postal_code, country, is_default) VALUES
(1, 'shipping', 'John', 'Doe', '123 Main Street', 'Paris', '75001', 'France', TRUE),
(1, 'billing', 'John', 'Doe', '123 Main Street', 'Paris', '75001', 'France', TRUE),
(2, 'shipping', 'Jane', 'Smith', '456 Oak Avenue', 'Lyon', '69001', 'France', TRUE);

-- Shopping cart
INSERT INTO shopping_cart (user_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 4, 2),
(2, 2, 1),
(3, 3, 3);

-- Sample order
INSERT INTO orders (user_id, order_number, status, total_amount, subtotal, tax_amount, shipping_amount, payment_status, payment_method) VALUES
(1, 'ORD-2024-001', 'delivered', 1208.98, 1198.99, 0.00, 9.99, 'paid', 'credit_card');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, product_name, product_sku) VALUES
(1, 1, 1, 999.00, 999.00, 'iPhone 14 Pro', 'IPHONE-14-PRO-128'),
(1, 4, 1, 199.99, 199.99, 'Wireless Headphones', 'HEADPHONES-WL-001');

-- Sample reviews
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_verified_purchase, is_approved) VALUES
(1, 1, 5, 'Excellent phone!', 'Great camera quality and performance. Highly recommended.', TRUE, TRUE),
(4, 1, 4, 'Good sound quality', 'Nice headphones but could be more comfortable for long use.', TRUE, TRUE),
(2, 2, 5, 'Love this phone', 'Android experience is smooth and battery life is amazing.', FALSE, TRUE);

-- ====================================================================
-- ASTERISK & FREEPBX TABLES
-- ====================================================================

-- Create Asterisk database
CREATE DATABASE IF NOT EXISTS asterisk;
USE asterisk;

-- Grant privileges to doriav2_user on asterisk database
GRANT ALL PRIVILEGES ON asterisk.* TO 'doriav2_user'@'%';

-- SIP Users table for Asterisk
CREATE TABLE sipusers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE,
    secret VARCHAR(40),
    context VARCHAR(40) DEFAULT 'default',
    host VARCHAR(40) DEFAULT 'dynamic',
    callerid VARCHAR(80),
    canreinvite VARCHAR(20) DEFAULT 'no',
    dtmfmode VARCHAR(20) DEFAULT 'rfc2833',
    insecure VARCHAR(20),
    nat VARCHAR(20) DEFAULT 'force_rport,comedia',
    qualify VARCHAR(20) DEFAULT 'yes',
    type VARCHAR(20) DEFAULT 'friend',
    port VARCHAR(10) DEFAULT '5060',
    regseconds INT DEFAULT 0,
    ipaddr VARCHAR(45) DEFAULT '',
    regserver VARCHAR(100) DEFAULT '',
    useragent VARCHAR(100) DEFAULT '',
    lastms INT DEFAULT 0,
    defaultuser VARCHAR(40),
    regcontext VARCHAR(40),
    subscribemwi VARCHAR(10) DEFAULT 'no',
    vmexten VARCHAR(20),
    cid_number VARCHAR(40),
    callgroup VARCHAR(40),
    pickupgroup VARCHAR(40),
    language VARCHAR(20),
    disallow VARCHAR(100) DEFAULT 'all',
    allow VARCHAR(100) DEFAULT 'ulaw,alaw,gsm',
    musiconhold VARCHAR(100),
    restrictcid VARCHAR(10) DEFAULT 'no',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Extensions table for dialplan
CREATE TABLE extensions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    context VARCHAR(40) NOT NULL DEFAULT 'default',
    exten VARCHAR(40) NOT NULL,
    priority INT NOT NULL,
    app VARCHAR(40) NOT NULL,
    appdata VARCHAR(256),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY context_exten_priority (context, exten, priority)
);

-- Call Detail Records
CREATE TABLE cdr (
    id INT AUTO_INCREMENT PRIMARY KEY,
    calldate DATETIME NOT NULL,
    clid VARCHAR(80) NOT NULL DEFAULT '',
    src VARCHAR(80) NOT NULL DEFAULT '',
    dst VARCHAR(80) NOT NULL DEFAULT '',
    dcontext VARCHAR(80) NOT NULL DEFAULT '',
    channel VARCHAR(80) NOT NULL DEFAULT '',
    dstchannel VARCHAR(80) NOT NULL DEFAULT '',
    lastapp VARCHAR(80) NOT NULL DEFAULT '',
    lastdata VARCHAR(80) NOT NULL DEFAULT '',
    duration INT NOT NULL DEFAULT 0,
    billsec INT NOT NULL DEFAULT 0,
    disposition VARCHAR(45) NOT NULL DEFAULT '',
    amaflags INT NOT NULL DEFAULT 0,
    accountcode VARCHAR(20) NOT NULL DEFAULT '',
    uniqueid VARCHAR(150) NOT NULL DEFAULT '',
    userfield VARCHAR(255) NOT NULL DEFAULT '',
    answer DATETIME,
    end DATETIME,
    INDEX calldate_idx (calldate),
    INDEX src_idx (src),
    INDEX dst_idx (dst)
);

-- Queue members table
CREATE TABLE queue_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    queue_name VARCHAR(128) NOT NULL,
    interface VARCHAR(128) NOT NULL,
    membername VARCHAR(40),
    state_interface VARCHAR(128),
    penalty INT DEFAULT 0,
    paused INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY queue_interface (queue_name, interface)
);

-- Voicemail users
CREATE TABLE voicemail_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(11) NOT NULL,
    context VARCHAR(50) NOT NULL DEFAULT 'default',
    mailbox VARCHAR(11) NOT NULL,
    password VARCHAR(4) NOT NULL DEFAULT '0000',
    fullname VARCHAR(150),
    email VARCHAR(50),
    pager VARCHAR(50),
    tz VARCHAR(10) DEFAULT 'central',
    attach VARCHAR(4) DEFAULT 'yes',
    saycid VARCHAR(4) DEFAULT 'yes',
    dialout VARCHAR(10),
    callback VARCHAR(10),
    review VARCHAR(4) DEFAULT 'no',
    operator VARCHAR(4) DEFAULT 'no',
    envelope VARCHAR(4) DEFAULT 'no',
    sayduration VARCHAR(4) DEFAULT 'no',
    saydurationm INT DEFAULT 1,
    sendvoicemail VARCHAR(4) DEFAULT 'no',
    delete_vmail VARCHAR(4) DEFAULT 'no',
    nextaftercmd VARCHAR(4) DEFAULT 'yes',
    forcename VARCHAR(4) DEFAULT 'no',
    forcegreetings VARCHAR(4) DEFAULT 'no',
    hidefromdir VARCHAR(4) DEFAULT 'yes',
    stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, context, mailbox)
);

-- Sample SIP users for testing
INSERT INTO sipusers (name, secret, context, callerid, allow) VALUES
('1001', 'test123', 'internal', 'User 1001 <1001>', 'ulaw,alaw,gsm,g729'),
('1002', 'test123', 'internal', 'User 1002 <1002>', 'ulaw,alaw,gsm,g729'),
('1003', 'test123', 'internal', 'User 1003 <1003>', 'ulaw,alaw,gsm,g729');

-- Sample extensions
INSERT INTO extensions (context, exten, priority, app, appdata) VALUES
('internal', '1001', 1, 'Dial', 'SIP/1001,30'),
('internal', '1002', 1, 'Dial', 'SIP/1002,30'),
('internal', '1003', 1, 'Dial', 'SIP/1003,30'),
('internal', '*97', 1, 'VoiceMailMain', '${CALLERID(num)}@default'),
('internal', '100', 1, 'Answer', ''),
('internal', '100', 2, 'Wait', '1'),
('internal', '100', 3, 'Playback', 'demo-congrats'),
('internal', '100', 4, 'Hangup', '');

-- Sample voicemail users
INSERT INTO voicemail_users (customer_id, context, mailbox, password, fullname, email) VALUES
('1', 'default', '1001', '1001', 'User 1001', 'user1001@doriav2.local'),
('2', 'default', '1002', '1002', 'User 1002', 'user1002@doriav2.local'),
('3', 'default', '1003', '1003', 'User 1003', 'user1003@doriav2.local');

-- Switch back to main database
USE doriav2;

FLUSH PRIVILEGES;

-- ========================================
-- FREEPBX / ASTERISK VOIP TABLES
-- ========================================

-- Create asterisk database for FreePBX
CREATE DATABASE IF NOT EXISTS asterisk;
USE asterisk;

-- Grant privileges on asterisk database
GRANT ALL PRIVILEGES ON asterisk.* TO 'doriav2_user'@'%';

-- FreePBX Core Tables
CREATE TABLE IF NOT EXISTS freepbx_settings (
    keyword VARCHAR(255) NOT NULL PRIMARY KEY,
    value TEXT,
    name VARCHAR(255),
    level INT DEFAULT 0,
    description TEXT,
    type VARCHAR(255) DEFAULT 'text'
);

-- SIP Buddies table for Asterisk Realtime
CREATE TABLE IF NOT EXISTS sip_buddies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE,
    host VARCHAR(40) DEFAULT 'dynamic',
    nat VARCHAR(40) DEFAULT 'force_rport,comedia',
    type VARCHAR(10) DEFAULT 'friend',
    accountcode VARCHAR(40),
    amaflags VARCHAR(40),
    callgroup VARCHAR(40),
    callerid VARCHAR(40),
    canreinvite VARCHAR(40) DEFAULT 'no',
    context VARCHAR(40) DEFAULT 'internal',
    defaultip VARCHAR(40),
    dtmfmode VARCHAR(10) DEFAULT 'rfc2833',
    fromuser VARCHAR(40),
    fromdomain VARCHAR(40),
    insecure VARCHAR(40),
    language VARCHAR(10),
    mailbox VARCHAR(40),
    md5secret VARCHAR(40),
    deny VARCHAR(40),
    permit VARCHAR(40),
    mask VARCHAR(40),
    pickupgroup VARCHAR(40),
    port VARCHAR(10) DEFAULT '5060',
    qualify VARCHAR(10) DEFAULT 'yes',
    restrictcid VARCHAR(10),
    rtptimeout VARCHAR(10),
    rtpholdtimeout VARCHAR(10),
    secret VARCHAR(40),
    setvar VARCHAR(200),
    disallow VARCHAR(40) DEFAULT 'all',
    allow VARCHAR(40) DEFAULT 'ulaw,alaw,gsm',
    musiconhold VARCHAR(40),
    regseconds INT DEFAULT 0,
    ipaddr VARCHAR(40) DEFAULT '0.0.0.0',
    regexten VARCHAR(40),
    cancallforward VARCHAR(10) DEFAULT 'yes',
    fullcontact VARCHAR(200),
    useragent VARCHAR(200),
    lastms INT DEFAULT 0
);

-- Extensions table for dialplan
CREATE TABLE IF NOT EXISTS extensions_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    context VARCHAR(40) NOT NULL,
    exten VARCHAR(40) NOT NULL,
    priority INT NOT NULL,
    app VARCHAR(40) NOT NULL,
    appdata VARCHAR(256),
    INDEX (context, exten, priority)
);

-- Voicemail users table
CREATE TABLE IF NOT EXISTS voicemail_users (
    customer_id VARCHAR(40) NOT NULL,
    context VARCHAR(40) NOT NULL DEFAULT 'default',
    mailbox VARCHAR(40) NOT NULL,
    password VARCHAR(40) NOT NULL,
    fullname VARCHAR(80),
    email VARCHAR(80),
    pager VARCHAR(80),
    tz VARCHAR(40) DEFAULT 'central',
    attach VARCHAR(10) DEFAULT 'yes',
    saycid VARCHAR(10) DEFAULT 'yes',
    dialout VARCHAR(40),
    callback VARCHAR(40),
    review VARCHAR(10) DEFAULT 'no',
    operator VARCHAR(10) DEFAULT 'no',
    envelope VARCHAR(10) DEFAULT 'no',
    sayduration VARCHAR(10) DEFAULT 'no',
    saydurationm INT DEFAULT 1,
    sendvoicemail VARCHAR(10) DEFAULT 'no',
    delete VARCHAR(10) DEFAULT 'no',
    nextaftercmd VARCHAR(10) DEFAULT 'yes',
    forcename VARCHAR(10) DEFAULT 'no',
    forcegreetings VARCHAR(10) DEFAULT 'no',
    hidefromdir VARCHAR(10) DEFAULT 'yes',
    stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (context, mailbox)
);

-- CDR table for call detail records
CREATE TABLE IF NOT EXISTS cdr (
    calldate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    clid VARCHAR(80) NOT NULL DEFAULT '',
    src VARCHAR(80) NOT NULL DEFAULT '',
    dst VARCHAR(80) NOT NULL DEFAULT '',
    dcontext VARCHAR(80) NOT NULL DEFAULT '',
    channel VARCHAR(80) NOT NULL DEFAULT '',
    dstchannel VARCHAR(80) NOT NULL DEFAULT '',
    lastapp VARCHAR(80) NOT NULL DEFAULT '',
    lastdata VARCHAR(80) NOT NULL DEFAULT '',
    duration INT NOT NULL DEFAULT 0,
    billsec INT NOT NULL DEFAULT 0,
    disposition VARCHAR(45) NOT NULL DEFAULT '',
    amaflags INT NOT NULL DEFAULT 0,
    accountcode VARCHAR(20) NOT NULL DEFAULT '',
    uniqueid VARCHAR(32) NOT NULL DEFAULT '',
    userfield VARCHAR(255) NOT NULL DEFAULT '',
    answer TIMESTAMP NULL,
    start TIMESTAMP NULL,
    end TIMESTAMP NULL,
    INDEX (calldate),
    INDEX (dst),
    INDEX (src),
    INDEX (uniqueid)
);

-- Sample SIP users for testing
INSERT INTO sip_buddies (name, secret, context, callerid, allow) VALUES
('1001', 'test123', 'internal', 'User 1001 <1001>', 'ulaw,alaw,gsm,g729'),
('1002', 'test123', 'internal', 'User 1002 <1002>', 'ulaw,alaw,gsm,g729'),
('1003', 'test123', 'internal', 'User 1003 <1003>', 'ulaw,alaw,gsm,g729');

-- Sample extensions
INSERT INTO extensions_table (context, exten, priority, app, appdata) VALUES
('internal', '1001', 1, 'Dial', 'SIP/1001,30'),
('internal', '1002', 1, 'Dial', 'SIP/1002,30'),
('internal', '1003', 1, 'Dial', 'SIP/1003,30'),
('internal', '*97', 1, 'VoiceMailMain', '${CALLERID(num)}@default'),
('internal', '100', 1, 'Answer', ''),
('internal', '100', 2, 'Wait', '1'),
('internal', '100', 3, 'Playback', 'demo-congrats'),
('internal', '100', 4, 'Hangup', '');

-- Sample voicemail users
INSERT INTO voicemail_users (customer_id, context, mailbox, password, fullname, email) VALUES
('1', 'default', '1001', '1001', 'User 1001', 'user1001@doriav2.local'),
('2', 'default', '1002', '1002', 'User 1002', 'user1002@doriav2.local'),
('3', 'default', '1003', '1003', 'User 1003', 'user1003@doriav2.local');

-- Switch back to main database
USE doriav2;

FLUSH PRIVILEGES;
