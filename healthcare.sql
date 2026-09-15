CREATE DATABASE health_care;
USE health_care;


-- Create Tables

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    contact VARCHAR(15)
);


CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);


CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);


-- TRIGGER Example

DELIMITER $$

CREATE TRIGGER log_new_record
AFTER INSERT ON medical_records
FOR EACH ROW
BEGIN
    INSERT INTO record_log (record_id, log_time, action)
    VALUES (NEW.record_id, NOW(), 'New record added');
END$$

DELIMITER ;


-- CRUD Operations

-- CREATE (Insert a new patient)

INSERT INTO patients (name, age, gender, contact)
VALUES
('Rohit Sharma', 34, 'M', '9876543210'),
('Anjali Verma', 29, 'F', '8765432109'),
('Vivek Kumar', 42, 'M', '9988776655'),
('Priya Singh', 38, 'F', '9123456780'),
('Salman Khan', 50, 'M', '8555666777');


-- Insert at least 5 records into doctors

INSERT INTO doctors (name, specialization)
VALUES
('Dr. Suresh Mehta', 'Cardiology'),
('Dr. Pooja Rao', 'Gynecology'),
('Dr. Aakash Jain', 'Orthopedics'),
('Dr. Neha Mishra', 'General Medicine'),
('Dr. Aman Gupta', 'Dermatology');


-- Insert at least 5 records into appointments

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, status)
VALUES
(1, 2, '2025-10-28', 'Scheduled'),
(2, 1, '2025-10-30', 'Scheduled'),
(3, 4, '2025-09-15', 'Completed'),
(4, 3, '2025-08-22', 'Cancelled'),
(5, 5, '2025-07-12', 'Scheduled');


-- Insert at least 5 records into medical_records

INSERT INTO medical_records
(patient_id, diagnosis, treatment, record_date)
VALUES
(1, 'Hypertension', 'Medication prescribed', '2025-09-05'),
(2, 'Flu', 'Rest and fluids', '2025-10-01'),
(3, 'Back Pain', 'Physical therapy', '2025-09-16'),
(4, 'Migraine', 'Painkillers and rest', '2025-08-22'),
(5, 'Skin Rash', 'Topical ointment', '2025-07-12');


-- READ (Fetch patient's medical history)

SELECT *
FROM medical_records
WHERE patient_id = 1;


-- UPDATE (Change an appointment status)

UPDATE appointments
SET status = 'Completed'
WHERE appointment_id = 1;


-- DELETE (Remove a patient)

DELETE FROM patients
WHERE patient_id = 1;


-- CURSOR Example

DELIMITER $$

CREATE PROCEDURE notify_overdue_appointments()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE pid INT;
    DECLARE adate DATE;

    DECLARE overdue_cursor CURSOR FOR
        SELECT patient_id, appointment_date
        FROM appointments
        WHERE status = 'Scheduled'
        AND appointment_date < CURDATE();

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = TRUE;

    OPEN overdue_cursor;

    read_loop: LOOP

        FETCH overdue_cursor INTO pid, adate;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO record_log (record_id, log_time, action)
        VALUES (
            pid,
            NOW(),
            CONCAT('Appointment overdue on ', adate)
        );

    END LOOP;

    CLOSE overdue_cursor;

END$$

DELIMITER ;


-- To run the procedure:

CALL notify_overdue_appointments();
