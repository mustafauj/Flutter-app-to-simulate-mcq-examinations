-- Proctorly MySQL Database Schema
-- Complete schema for the Proctorly examination management system
-- Supports SuperAdmin, College Admin, Teachers, and Students

-- Create database
CREATE DATABASE IF NOT EXISTS proctorly_db;
USE proctorly_db;

-- Create custom ENUM types
-- Note: MySQL doesn't have custom types like PostgreSQL, so we'll use ENUM directly in columns

-- Colleges table
CREATE TABLE colleges (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#1976D2',
    secondary_color VARCHAR(7) DEFAULT '#42A5F5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_colleges_code (code),
    INDEX idx_colleges_is_active (is_active)
);

-- Departments table
CREATE TABLE departments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    college_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    INDEX idx_departments_college_id (college_id),
    INDEX idx_departments_is_active (is_active)
);

-- Users table (includes SuperAdmin, College Admin, Teachers, Students)
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('superAdmin', 'admin', 'teacher', 'student') NOT NULL,
    college_id CHAR(36),
    department_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    
    FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    INDEX idx_users_college_id (college_id),
    INDEX idx_users_department_id (department_id),
    INDEX idx_users_role (role),
    INDEX idx_users_email (email),
    INDEX idx_users_is_active (is_active)
);

-- User credentials table (for generated login credentials)
CREATE TABLE user_credentials (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('superAdmin', 'admin', 'teacher', 'student') NOT NULL,
    college_id CHAR(36),
    department_id CHAR(36),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    INDEX idx_user_credentials_username (username),
    INDEX idx_user_credentials_user_id (user_id),
    INDEX idx_user_credentials_is_active (is_active)
);

-- Tests table
CREATE TABLE tests (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL DEFAULT 60,
    college_id CHAR(36) NOT NULL,
    department_id CHAR(36),
    created_by CHAR(36) NOT NULL,
    status ENUM('draft', 'active', 'inactive', 'completed') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    start_time TIMESTAMP NULL,
    end_time TIMESTAMP NULL,
    target_years JSON,
    published_at TIMESTAMP NULL,
    
    FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_tests_college_id (college_id),
    INDEX idx_tests_department_id (department_id),
    INDEX idx_tests_created_by (created_by),
    INDEX idx_tests_status (status),
    INDEX idx_tests_is_active (is_active)
);

-- Questions table
CREATE TABLE questions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    test_id CHAR(36) NOT NULL,
    text TEXT NOT NULL,
    question_type VARCHAR(50) DEFAULT 'multiple_choice',
    points INT DEFAULT 1,
    order_index INT NOT NULL,
    correct_answer_index INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE,
    INDEX idx_questions_test_id (test_id),
    INDEX idx_questions_order (test_id, order_index)
);

-- Answers table (options for multiple choice questions)
CREATE TABLE answers (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    question_id CHAR(36) NOT NULL,
    text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_answers_question_id (question_id),
    INDEX idx_answers_order (question_id, order_index)
);

-- Test results table
CREATE TABLE test_results (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    test_id CHAR(36) NOT NULL,
    student_id CHAR(36) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    total_questions INT NOT NULL,
    correct_answers INT NOT NULL DEFAULT 0,
    time_spent_minutes INT NOT NULL DEFAULT 0,
    answers JSON,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_completed BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_test_results_test_id (test_id),
    INDEX idx_test_results_student_id (student_id),
    INDEX idx_test_results_submitted_at (submitted_at)
);

-- Notifications table
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('test_assigned', 'test_completed', 'result_available', 'system_announcement') NOT NULL,
    data JSON,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user_id (user_id),
    INDEX idx_notifications_is_read (user_id, is_read),
    INDEX idx_notifications_created_at (created_at)
);

-- Test sessions table (for live monitoring)
CREATE TABLE test_sessions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    test_id CHAR(36) NOT NULL,
    student_id CHAR(36) NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_test_sessions_test_id (test_id),
    INDEX idx_test_sessions_student_id (student_id),
    INDEX idx_test_sessions_is_active (is_active),
    INDEX idx_test_sessions_token (session_token)
);

-- System settings table
CREATE TABLE system_settings (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_system_settings_key (setting_key)
);

-- Audit log table
CREATE TABLE audit_logs (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id CHAR(36),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_logs_user_id (user_id),
    INDEX idx_audit_logs_action (action),
    INDEX idx_audit_logs_created_at (created_at)
);

-- Insert initial SuperAdmin user
INSERT INTO users (id, name, email, role, college_id, department_id, is_active) 
VALUES (
    UUID(),
    'Super Admin',
    'superadmin@proctorly.com',
    'superAdmin',
    NULL,
    NULL,
    TRUE
);

-- Insert SuperAdmin credentials
INSERT INTO user_credentials (user_id, username, password_hash, role, college_id, department_id)
SELECT 
    u.id,
    'superadmin',
    SHA2('superadmin123', 256),
    'superAdmin',
    NULL,
    NULL
FROM users u 
WHERE u.email = 'superadmin@proctorly.com';

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('app_name', 'Proctorly', 'Application name'),
('app_version', '1.0.0', 'Application version'),
('max_test_duration', '180', 'Maximum test duration in minutes'),
('min_test_duration', '5', 'Minimum test duration in minutes'),
('max_questions_per_test', '100', 'Maximum questions per test'),
('min_questions_per_test', '1', 'Minimum questions per test'),
('session_timeout', '30', 'Session timeout in minutes'),
('password_min_length', '8', 'Minimum password length'),
('enable_notifications', 'true', 'Enable system notifications'),
('maintenance_mode', 'false', 'Maintenance mode status');

-- Create views for easier data access

-- View for active tests with question count
CREATE VIEW active_tests_view AS
SELECT 
    t.*,
    COUNT(q.id) as question_count,
    u.name as created_by_name
FROM tests t
LEFT JOIN questions q ON t.id = q.test_id
LEFT JOIN users u ON t.created_by = u.id
WHERE t.is_active = TRUE
GROUP BY t.id, u.name;

-- View for test results with student info
CREATE VIEW test_results_view AS
SELECT 
    tr.*,
    t.title as test_title,
    u.name as student_name,
    u.email as student_email
FROM test_results tr
JOIN tests t ON tr.test_id = t.id
JOIN users u ON tr.student_id = u.id;

-- View for user statistics
CREATE VIEW user_stats_view AS
SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    c.name as college_name,
    d.name as department_name,
    COUNT(tr.id) as tests_taken,
    AVG(tr.score) as average_score,
    MAX(tr.score) as best_score
FROM users u
LEFT JOIN colleges c ON u.college_id = c.id
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN test_results tr ON u.id = tr.student_id
GROUP BY u.id, u.name, u.email, u.role, c.name, d.name;

-- Create stored procedures for common operations

DELIMITER //

-- Procedure to create a new college with admin
CREATE PROCEDURE CreateCollegeWithAdmin(
    IN college_name VARCHAR(255),
    IN college_code VARCHAR(50),
    IN college_description TEXT,
    IN admin_name VARCHAR(255),
    IN admin_email VARCHAR(255),
    IN admin_phone VARCHAR(20)
)
BEGIN
    DECLARE new_college_id CHAR(36);
    DECLARE new_admin_id CHAR(36);
    DECLARE new_credentials_id CHAR(36);
    DECLARE username_text VARCHAR(100);
    DECLARE password_text VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Create college
    INSERT INTO colleges (id, name, code, description)
    VALUES (UUID(), college_name, college_code, college_description);
    
    SET new_college_id = LAST_INSERT_ID();
    
    -- Create admin user
    INSERT INTO users (id, name, email, phone, role, college_id, department_id)
    VALUES (UUID(), admin_name, admin_email, admin_phone, 'admin', new_college_id, NULL);
    
    SET new_admin_id = LAST_INSERT_ID();
    
    -- Generate credentials
    SET username_text = CONCAT('admin_', UNIX_TIMESTAMP(), '_', FLOOR(RAND() * 10000));
    SET password_text = CONCAT('admin', FLOOR(RAND() * 10000));
    
    INSERT INTO user_credentials (id, user_id, username, password_hash, role, college_id, department_id)
    VALUES (UUID(), new_admin_id, username_text, SHA2(password_text, 256), 'admin', new_college_id, NULL);
    
    SET new_credentials_id = LAST_INSERT_ID();
    
    COMMIT;
    
    -- Return result
    SELECT 
        new_college_id as college_id,
        new_admin_id as admin_id,
        new_credentials_id as credentials_id,
        username_text as username,
        password_text as password,
        TRUE as success;
END //

-- Procedure to create a new user with credentials
CREATE PROCEDURE CreateUserWithCredentials(
    IN user_name VARCHAR(255),
    IN user_email VARCHAR(255),
    IN user_phone VARCHAR(20),
    IN user_role ENUM('superAdmin', 'admin', 'teacher', 'student'),
    IN user_college_id CHAR(36),
    IN user_department_id CHAR(36)
)
BEGIN
    DECLARE new_user_id CHAR(36);
    DECLARE new_credentials_id CHAR(36);
    DECLARE username_text VARCHAR(100);
    DECLARE password_text VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Create user
    INSERT INTO users (id, name, email, phone, role, college_id, department_id)
    VALUES (UUID(), user_name, user_email, user_phone, user_role, user_college_id, user_department_id);
    
    SET new_user_id = LAST_INSERT_ID();
    
    -- Generate username and password
    SET username_text = CONCAT(user_role, '_', UNIX_TIMESTAMP(), '_', FLOOR(RAND() * 10000));
    SET password_text = CONCAT(user_role, FLOOR(RAND() * 10000));
    
    -- Create credentials
    INSERT INTO user_credentials (id, user_id, username, password_hash, role, college_id, department_id)
    VALUES (UUID(), new_user_id, username_text, SHA2(password_text, 256), user_role, user_college_id, user_department_id);
    
    SET new_credentials_id = LAST_INSERT_ID();
    
    COMMIT;
    
    -- Return result
    SELECT 
        new_user_id as user_id,
        new_credentials_id as credentials_id,
        username_text as username,
        password_text as password,
        TRUE as success;
END //

-- Procedure to get user credentials
CREATE PROCEDURE GetUserCredentials(IN username_param VARCHAR(100))
BEGIN
    SELECT 
        uc.user_id,
        uc.username,
        uc.password_hash,
        uc.role,
        uc.college_id,
        uc.department_id,
        u.name as user_name,
        u.email as user_email
    FROM user_credentials uc
    JOIN users u ON uc.user_id = u.id
    WHERE uc.username = username_param
    AND uc.is_active = TRUE
    AND u.is_active = TRUE;
END //

-- Procedure to get dashboard statistics
CREATE PROCEDURE GetDashboardStats(IN user_id_param CHAR(36))
BEGIN
    DECLARE user_role_val ENUM('superAdmin', 'admin', 'teacher', 'student');
    DECLARE user_college_id CHAR(36);
    DECLARE user_department_id CHAR(36);
    
    -- Get user info
    SELECT role, college_id, department_id 
    INTO user_role_val, user_college_id, user_department_id
    FROM users 
    WHERE id = user_id_param;
    
    CASE user_role_val
        WHEN 'superAdmin' THEN
            SELECT 
                (SELECT COUNT(*) FROM colleges WHERE is_active = TRUE) as colleges_count,
                (SELECT COUNT(*) FROM users WHERE is_active = TRUE) as users_count,
                (SELECT COUNT(*) FROM tests WHERE is_active = TRUE) as tests_count,
                (SELECT COUNT(*) FROM tests WHERE is_active = TRUE AND status = 'active') as active_tests_count;
                
        WHEN 'admin' THEN
            SELECT 
                (SELECT COUNT(*) FROM departments WHERE college_id = user_college_id AND is_active = TRUE) as departments_count,
                (SELECT COUNT(*) FROM users WHERE college_id = user_college_id AND is_active = TRUE) as users_count,
                (SELECT COUNT(*) FROM users WHERE college_id = user_college_id AND role = 'teacher' AND is_active = TRUE) as teachers_count,
                (SELECT COUNT(*) FROM users WHERE college_id = user_college_id AND role = 'student' AND is_active = TRUE) as students_count,
                (SELECT COUNT(*) FROM tests WHERE college_id = user_college_id AND is_active = TRUE) as tests_count;
                
        WHEN 'teacher' THEN
            SELECT 
                (SELECT COUNT(*) FROM tests WHERE created_by = user_id_param AND is_active = TRUE) as my_tests_count,
                (SELECT COUNT(*) FROM users WHERE department_id = user_department_id AND role = 'student' AND is_active = TRUE) as students_count,
                (SELECT COUNT(*) FROM tests WHERE created_by = user_id_param AND is_active = TRUE AND status = 'active') as active_tests_count;
                
        WHEN 'student' THEN
            SELECT 
                (SELECT COUNT(*) FROM tests WHERE department_id = user_department_id AND is_active = TRUE AND status = 'active') as available_tests_count,
                (SELECT COUNT(*) FROM test_results WHERE student_id = user_id_param) as tests_taken_count,
                (SELECT AVG(score) FROM test_results WHERE student_id = user_id_param) as average_score,
                (SELECT MAX(score) FROM test_results WHERE student_id = user_id_param) as best_score;
    END CASE;
END //

-- Procedure to clean up old test sessions
CREATE PROCEDURE CleanupOldTestSessions()
BEGIN
    DELETE FROM test_sessions 
    WHERE last_activity < DATE_SUB(NOW(), INTERVAL 24 HOUR)
    AND is_active = FALSE;
END //

DELIMITER ;

-- Create triggers for audit logging

DELIMITER //

-- Trigger for user table changes
CREATE TRIGGER users_audit_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (id, user_id, action, table_name, record_id, new_values, created_at)
    VALUES (UUID(), NEW.id, 'INSERT', 'users', NEW.id, JSON_OBJECT('name', NEW.name, 'email', NEW.email, 'role', NEW.role), NOW());
END //

CREATE TRIGGER users_audit_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (id, user_id, action, table_name, record_id, old_values, new_values, created_at)
    VALUES (UUID(), NEW.id, 'UPDATE', 'users', NEW.id, 
        JSON_OBJECT('name', OLD.name, 'email', OLD.email, 'role', OLD.role),
        JSON_OBJECT('name', NEW.name, 'email', NEW.email, 'role', NEW.role),
        NOW());
END //

CREATE TRIGGER users_audit_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (id, user_id, action, table_name, record_id, old_values, created_at)
    VALUES (UUID(), OLD.id, 'DELETE', 'users', OLD.id, JSON_OBJECT('name', OLD.name, 'email', OLD.email, 'role', OLD.role), NOW());
END //

DELIMITER ;

-- Create indexes for better performance
CREATE INDEX idx_colleges_created_at ON colleges(created_at);
CREATE INDEX idx_departments_created_at ON departments(created_at);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_tests_created_at ON tests(created_at);
CREATE INDEX idx_questions_created_at ON questions(created_at);
CREATE INDEX idx_test_results_created_at ON test_results(created_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Grant permissions (adjust as needed for your MySQL user)
-- GRANT ALL PRIVILEGES ON proctorly_db.* TO 'proctorly_user'@'localhost';
-- FLUSH PRIVILEGES;

-- Sample data insertion (optional)
-- You can uncomment and modify these as needed

/*
-- Insert sample college
INSERT INTO colleges (name, code, description) VALUES 
('Sample University', 'SU001', 'A sample university for testing');

-- Insert sample department
INSERT INTO departments (name, description, college_id) 
SELECT 'Computer Science', 'Computer Science Department', id FROM colleges WHERE code = 'SU001';

-- Insert sample users
CALL CreateUserWithCredentials('John Teacher', 'john.teacher@sample.edu', '1234567890', 'teacher', 
    (SELECT id FROM colleges WHERE code = 'SU001'), 
    (SELECT id FROM departments WHERE name = 'Computer Science'));

CALL CreateUserWithCredentials('Jane Student', 'jane.student@sample.edu', '0987654321', 'student', 
    (SELECT id FROM colleges WHERE code = 'SU001'), 
    (SELECT id FROM departments WHERE name = 'Computer Science'));
*/

-- End of schema
