USE crownfield_eye_hospital;
SELECT * FROM appointment;

USE crownfield_eye_hospital;

CREATE TABLE IF NOT EXISTS app_user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash CHAR(64) NOT NULL,
    user_role VARCHAR(30) NOT NULL
);

INSERT INTO app_user
    (username, password_hash, user_role)
VALUES
    (
        'receptionist01',
        SHA2('Crownfield@2026!', 256),
        'receptionist_role'
    );
    UPDATE app_user
SET password_hash = SHA2('Crownfield@2026!', 256),
    user_role = 'receptionist_role'
WHERE username = 'receptionist01';
SELECT
    username,
    password_hash,
    user_role
FROM app_user
WHERE username = 'receptionist01';

USE crownfield_eye_hospital;

SELECT
    c.clinician_id,
    CONCAT(c.first_name, ' ', c.last_name) AS clinician_name,
    COUNT(a.appointment_id) AS total_appointments
FROM clinician c
LEFT JOIN appointment a
    ON c.clinician_id = a.clinician_id
GROUP BY c.clinician_id, c.first_name, c.last_name
HAVING COUNT(a.appointment_id) > (
    SELECT AVG(appointment_count)
    FROM (
        SELECT
            c2.clinician_id,
            COUNT(a2.appointment_id) AS appointment_count
        FROM clinician c2
        LEFT JOIN appointment a2
            ON c2.clinician_id = a2.clinician_id
        GROUP BY c2.clinician_id
    ) AS clinician_counts
)
ORDER BY total_appointments DESC;


USE crownfield_eye_hospital;

DROP TRIGGER IF EXISTS trg_validate_followup_date;

DELIMITER $$

CREATE TRIGGER trg_validate_followup_date
BEFORE INSERT ON follow_up
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;

    SELECT appointment_date
    INTO v_appointment_date
    FROM appointment
    WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Follow-up date cannot be before appointment date';
    END IF;
END $$

DELIMITER ;
SELECT appointment_id, appointment_date
FROM appointment
WHERE appointment_id = 3;

