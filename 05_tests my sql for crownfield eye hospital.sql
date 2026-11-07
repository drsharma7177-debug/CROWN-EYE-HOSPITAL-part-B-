USE crownfield_eye_hospital;
-- Run one statement at a time and capture SQL + Action Output / Result Grid.
-- Tests marked EXPECTED FAILURE should NOT be run in a batch with other tests.

-- Initial checks (read-only)
SHOW TABLES;
DESCRIBE appointment;
DESCRIBE prescription_item;
SELECT COUNT(*) AS appointment_count FROM appointment; -- expected 11
SELECT COUNT(*) AS no_diagnosis_count FROM appointment a
LEFT JOIN diagnosis d ON d.appointment_id=a.appointment_id
WHERE d.diagnosis_id IS NULL; -- expected 1

-- EXPECTED FAILURE: duplicate primary key
-- INSERT INTO patient(patient_id,first_name,last_name,postcode)
-- VALUES ('OP001','Duplicate','Patient','ZZ1 1ZZ');

-- EXPECTED FAILURE: invalid appointment status
-- INSERT INTO appointment(patient_id,clinician_id,clinic_id,appointment_date,appointment_time,status)
-- VALUES ('OP001',1,1,'2026-12-01','09:00:00','Finished');

-- EXPECTED FAILURE: missing patient foreign key
-- INSERT INTO appointment(patient_id,clinician_id,clinic_id,appointment_date,appointment_time)
-- VALUES ('OP999',1,1,'2026-12-01','09:00:00');

-- EXPECTED FAILURE: invalid medicine duration
-- INSERT INTO prescription_item(prescription_id,medicine_id,dose,route,frequency,duration_days)
-- VALUES (2,4,'1 drop','Ocular','Daily',-5);

-- EXPECTED FAILURE: invalid follow-up date for appointment 3
-- INSERT INTO follow_up(appointment_id,due_date,priority,status)
-- VALUES (3,'2020-01-01','Routine','Pending');

-- VALID trigger test: appointment 3 has no follow-up in the original dataset.
-- Run only after recording the invalid insert screenshot. Run once.
-- INSERT INTO follow_up(appointment_id,due_date,priority,status)
-- VALUES (3,'2026-12-14','Routine','Pending');
-- SELECT * FROM follow_up WHERE appointment_id=3;

-- Controlled UPDATE: transaction with rollback, preserving original data.
START TRANSACTION;
UPDATE follow_up SET status='Completed' WHERE follow_up_id=1;
SELECT * FROM follow_up WHERE follow_up_id=1;
ROLLBACK;
SELECT * FROM follow_up WHERE follow_up_id=1;

-- Controlled DELETE: disposable patient, no linked records.
INSERT INTO patient(patient_id,first_name,last_name,postcode)
VALUES ('TEST01','Test','Patient','ZZ1 1ZZ');
SELECT * FROM patient WHERE patient_id='TEST01';
DELETE FROM patient WHERE patient_id='TEST01';
SELECT * FROM patient WHERE patient_id='TEST01';

-- COMMIT demonstration: use a disposable record, not clinical sample data.
INSERT INTO patient(patient_id,first_name,last_name,postcode)
VALUES ('TEST02','Commit','Example','ZZ1 1ZZ');
START TRANSACTION;
UPDATE patient SET postcode='ZZ2 2ZZ' WHERE patient_id='TEST02';
COMMIT;
SELECT * FROM patient WHERE patient_id='TEST02';
DELETE FROM patient WHERE patient_id='TEST02';
