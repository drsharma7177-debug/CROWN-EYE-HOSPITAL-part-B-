USE crownfield_eye_hospital;
-- Q5 Stored procedure: list appointments for a selected patient.
DROP PROCEDURE IF EXISTS get_patient_appointments;
DELIMITER $$
CREATE PROCEDURE get_patient_appointments(IN p_patient_id VARCHAR(10))
BEGIN
 SELECT a.appointment_id,a.patient_id,a.appointment_date,a.appointment_time,
        CONCAT(c.first_name,' ',c.last_name) AS clinician_name,
        cl.clinic_name,a.status
 FROM appointment a
 JOIN clinician c ON c.clinician_id=a.clinician_id
 JOIN clinic cl ON cl.clinic_id=a.clinic_id
 WHERE a.patient_id=p_patient_id
 ORDER BY a.appointment_date,a.appointment_time;
END $$
DELIMITER ;
CALL get_patient_appointments('OP001');

-- Q6 Trigger: prevent follow-up due date earlier than appointment date.
DROP TRIGGER IF EXISTS trg_validate_followup_date;
DROP TRIGGER IF EXISTS trg_validate_followup_update;
DELIMITER $$
CREATE TRIGGER trg_validate_followup_date
BEFORE INSERT ON follow_up FOR EACH ROW
BEGIN
 DECLARE v_appointment_date DATE;
 SELECT appointment_date INTO v_appointment_date
 FROM appointment WHERE appointment_id=NEW.appointment_id;
 IF NEW.due_date < v_appointment_date THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Follow-up date cannot be before appointment date';
 END IF;
END $$
CREATE TRIGGER trg_validate_followup_update
BEFORE UPDATE ON follow_up FOR EACH ROW
BEGIN
 DECLARE v_appointment_date DATE;
 SELECT appointment_date INTO v_appointment_date
 FROM appointment WHERE appointment_id=NEW.appointment_id;
 IF NEW.due_date < v_appointment_date THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Follow-up date cannot be before appointment date';
 END IF;
END $$
DELIMITER ;
SHOW TRIGGERS;
-- Run trigger tests individually from 05_tests.sql after capturing the initial screenshots.
