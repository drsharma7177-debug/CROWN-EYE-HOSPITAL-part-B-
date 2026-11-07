-- Requires MySQL account with CREATE USER, CREATE ROLE and GRANT privileges.
USE crownfield_eye_hospital;
CREATE ROLE IF NOT EXISTS 'hospital_admin','doctor_role','receptionist_role','patient_role';
GRANT ALL PRIVILEGES ON crownfield_eye_hospital.* TO 'hospital_admin';
GRANT SELECT ON crownfield_eye_hospital.* TO 'doctor_role';
GRANT INSERT,UPDATE ON crownfield_eye_hospital.diagnosis TO 'doctor_role';
GRANT INSERT,UPDATE ON crownfield_eye_hospital.prescription TO 'doctor_role';
GRANT INSERT,UPDATE ON crownfield_eye_hospital.prescription_item TO 'doctor_role';
GRANT INSERT,UPDATE ON crownfield_eye_hospital.follow_up TO 'doctor_role';
GRANT SELECT,INSERT,UPDATE ON crownfield_eye_hospital.patient TO 'receptionist_role';
GRANT SELECT,INSERT,UPDATE ON crownfield_eye_hospital.appointment TO 'receptionist_role';
GRANT SELECT ON crownfield_eye_hospital.clinic TO 'receptionist_role';
-- Deliberately do NOT grant patient_role SELECT on a shared view of all patients.
-- A production patient portal requires verified identity and patient-specific row filtering.

-- Demonstration only: database login users with example passwords. Change these immediately.
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'ChangeMeAdmin!2026';
CREATE USER IF NOT EXISTS 'doctor_user'@'localhost' IDENTIFIED BY 'ChangeMeDoctor!2026';
CREATE USER IF NOT EXISTS 'reception_user'@'localhost' IDENTIFIED BY 'ChangeMeReception!2026';
CREATE USER IF NOT EXISTS 'patient_user'@'localhost' IDENTIFIED BY 'ChangeMePatient!2026';
GRANT 'hospital_admin' TO 'admin_user'@'localhost';
GRANT 'doctor_role' TO 'doctor_user'@'localhost';
GRANT 'receptionist_role' TO 'reception_user'@'localhost';
GRANT 'patient_role' TO 'patient_user'@'localhost';
SET DEFAULT ROLE ALL TO 'admin_user'@'localhost','doctor_user'@'localhost',
                        'reception_user'@'localhost','patient_user'@'localhost';
SHOW GRANTS FOR 'doctor_user'@'localhost';
SHOW GRANTS FOR 'reception_user'@'localhost';

-- Educational demonstration of hashing, NOT production-grade password storage.
-- Real password authentication should use Argon2id/bcrypt/scrypt with salts.
CREATE TABLE IF NOT EXISTS app_user (
 app_user_id INT AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(50) NOT NULL UNIQUE,
 password_hash CHAR(64) NOT NULL,
 user_type VARCHAR(20) NOT NULL,
 CONSTRAINT chk_app_user_type CHECK (user_type IN ('Administrator','Doctor','Receptionist','Patient'))
);
INSERT INTO app_user(username,password_hash,user_type)
VALUES ('doctor_demo',SHA2('ExamplePassword123!',256),'Doctor')
ON DUPLICATE KEY UPDATE user_type=VALUES(user_type);
SELECT username,password_hash,user_type FROM app_user;
