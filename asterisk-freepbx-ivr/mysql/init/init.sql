CREATE DATABASE IF NOT EXISTS freepbx;

USE freepbx;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS extensions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    extension_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS voicemail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    extension_id INT NOT NULL,
    greeting VARCHAR(255),
    email_notification BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (extension_id) REFERENCES extensions(id)
);

INSERT INTO users (username, password, email) VALUES ('admin', 'admin_password', 'admin@example.com');
INSERT INTO extensions (user_id, extension_number) VALUES (1, '1001'), (1, '1002');
INSERT INTO voicemail (extension_id, greeting, email_notification) VALUES (1, 'default_greeting', TRUE), (2, 'default_greeting', FALSE);