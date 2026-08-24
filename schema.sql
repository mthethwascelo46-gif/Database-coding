-- ============================================================
-- NEXSUS BUSINESS SOLUTIONS - WORKFLOW MANAGEMENT SYSTEM
-- Database Schema (MySQL / phpMyAdmin / XAMPP)
-- ============================================================
-- Run this whole file top to bottom in phpMyAdmin's SQL tab.
-- Tables are ordered so "parent" tables (no foreign keys) are
-- created before "child" tables that reference them - MySQL
-- errors if a foreign key points to a table that doesn't exist yet.
-- ============================================================

CREATE DATABASE nexsus_wms;
USE nexsus_wms;  -- all commands below now apply to this database


-- ============================================================
-- 1. USERS (login + role-based access)
-- ============================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,       -- UNIQUE stops duplicate accounts
    password VARCHAR(255) NOT NULL,           -- stores a HASHED password, never plain text
    role ENUM('admin', 'accountant', 'staff') NOT NULL DEFAULT 'staff', -- locks role to fixed list
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- auto-updates on edit
);


-- ============================================================
-- 2. CLIENTS (customer management)
-- ============================================================
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- ============================================================
-- 3. SERVICE_TYPES (lookup table, e.g. Payroll Run, Tax Filing)
-- ============================================================
-- Lookup table so "Payroll Run" is stored once here and
-- referenced by id everywhere else, instead of retyped as free
-- text on every task (avoids typos/inconsistent data).
CREATE TABLE service_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);


-- ============================================================
-- 4. TASKS (workflow / task management)
-- ============================================================
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    assigned_to INT NOT NULL,
    service_type_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'overdue') DEFAULT 'pending', -- for dashboard charts
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    due_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,      -- deleting a client deletes their tasks too
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE RESTRICT,     -- blocks deleting a user who still has tasks
    FOREIGN KEY (service_type_id) REFERENCES service_types(id)
);


-- ============================================================
-- 5. DOCUMENTS (document management)
-- ============================================================
CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    uploaded_by INT NOT NULL,
    file_name VARCHAR(150) NOT NULL,
    file_path VARCHAR(255) NOT NULL,   -- stores file location on disk/storage, not the file itself
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,   -- doc is meaningless without its task
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);


-- ============================================================
-- 6. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    task_id INT,   -- nullable: some notifications aren't tied to a specific task
    message VARCHAR(255) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL   -- keep notification history even if task is deleted
);


-- ============================================================
-- 7. REPORTS
-- ============================================================
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    generated_by INT NOT NULL,
    client_id INT,   -- nullable: some reports are company-wide, not client-specific
    report_type VARCHAR(100) NOT NULL,
    generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (generated_by) REFERENCES users(id),
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL   -- keep historical report even if client is removed
);
