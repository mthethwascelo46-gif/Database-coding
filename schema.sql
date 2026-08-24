

-- 1. ROLES ---------------------------------------------------
CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE   -- e.g. 'client', 'staff', 'owner'
);

-- 2. USERS ----------------------------------------------------
-- This is the login table. Every client, staff member and owner
-- gets ONE row here. role_id says which type of user they are.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,        -- store bcrypt hash, never plain text
    role_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- 3. CLIENTS ----------------------------------------------------
-- Extra info specific to clients. Linked back to their login in "users".
CREATE TABLE client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    contact_number VARCHAR(20),
    address VARCHAR(255),
    id_number VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 4. EMPLOYEES (staff) --------------------------------------------
-- Extra info specific to staff members. Linked back to "users".
CREATE TABLE employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    position VARCHAR(100),                  -- e.g. 'Accountant', 'Bookkeeper'
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 5. SERVICES ----------------------------------------------------
-- A service being provided to a client (e.g. "2025 Tax Return").
CREATE TABLE service (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    assigned_employee_id INT,
    service_type VARCHAR(100) NOT NULL,
    status ENUM('Pending','In Progress','Completed','Awaiting Documents','Under Review','Cancelled')
        DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_employee_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);

-- 6. TASKS ---------------------------------------------------------
-- Smaller work items tied to a service, assigned to staff.
CREATE TABLE task (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    assigned_employee_id INT,
    description VARCHAR(255) NOT NULL,
    status ENUM('Pending','In Progress','Completed') DEFAULT 'Pending',
    due_date DATE,
    FOREIGN KEY (service_id) REFERENCES service(service_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_employee_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);

-- 7. DOCUMENTS ------------------------------------------------------
CREATE TABLE document (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    uploaded_by INT NOT NULL,               -- references users.user_id (client or staff)
    file_name VARCHAR(150) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    document_type VARCHAR(100),
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id)
);

-- 8. NOTIFICATIONS -----------------------------------------------------
CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    type VARCHAR(50),                       -- e.g. 'Deadline Reminder', 'Document Request'
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 9. INVOICES -----------------------------------------------------------
-- Just records, no calculation logic (per your scope-out).
CREATE TABLE invoice (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    service_id INT,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('Unpaid','Paid','Overdue') DEFAULT 'Unpaid',
    date_issued DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES service(service_id) ON DELETE SET NULL
);

-- 10. ACTIVITY LOG (audit trail) -----------------------------------------
CREATE TABLE activity_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =========================================================
-- Optional starter data for role table (run once)
-- =========================================================
INSERT INTO role (role_name) VALUES ('client'), ('staff'), ('owner');
