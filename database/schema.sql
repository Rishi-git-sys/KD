-- MySQL 8.0 schema for Online Job Portal and Employment Trend Analysis System
CREATE DATABASE IF NOT EXISTS job_portal;
USE job_portal;

CREATE TABLE department (
 department_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(80) NOT NULL UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE student (
 student_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL, department_id INT NOT NULL,
 qualification VARCHAR(80) NOT NULL, skills VARCHAR(500) NOT NULL, cgpa DECIMAL(3,2) NOT NULL CHECK(cgpa BETWEEN 0 AND 10),
 email VARCHAR(160) NOT NULL UNIQUE, phone VARCHAR(20) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_student_department FOREIGN KEY(department_id) REFERENCES department(department_id), INDEX idx_student_department(department_id)
);
CREATE TABLE company (
 company_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(140) NOT NULL UNIQUE, industry VARCHAR(100) NOT NULL,
 location VARCHAR(100) NOT NULL, contact VARCHAR(160) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE vacancy (
 vacancy_id INT AUTO_INCREMENT PRIMARY KEY, company_id INT NOT NULL, job_title VARCHAR(140) NOT NULL,
 min_cgpa DECIMAL(3,2) NOT NULL CHECK(min_cgpa BETWEEN 0 AND 10), required_qualification VARCHAR(80) NOT NULL,
 location VARCHAR(100) NOT NULL, min_salary DECIMAL(12,2) NOT NULL CHECK(min_salary >= 0), max_salary DECIMAL(12,2) NOT NULL,
 openings INT NOT NULL CHECK(openings >= 0), last_date DATE NOT NULL, status ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT chk_salary CHECK(max_salary >= min_salary), CONSTRAINT fk_vacancy_company FOREIGN KEY(company_id) REFERENCES company(company_id),
 INDEX idx_vacancy_status_date(status,last_date), INDEX idx_vacancy_company(company_id)
);
CREATE TABLE vacancy_department (
 vacancy_id INT NOT NULL, department_id INT NOT NULL, PRIMARY KEY(vacancy_id,department_id),
 FOREIGN KEY(vacancy_id) REFERENCES vacancy(vacancy_id) ON DELETE CASCADE, FOREIGN KEY(department_id) REFERENCES department(department_id)
);
CREATE TABLE application (
 application_id INT AUTO_INCREMENT PRIMARY KEY, student_id INT NOT NULL, vacancy_id INT NOT NULL,
 application_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, status ENUM('APPLIED','SHORTLISTED','SELECTED','REJECTED') NOT NULL DEFAULT 'APPLIED',
 decision_date DATETIME NULL, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT uq_application_student_vacancy UNIQUE(student_id,vacancy_id), CONSTRAINT fk_application_student FOREIGN KEY(student_id) REFERENCES student(student_id),
 CONSTRAINT fk_application_vacancy FOREIGN KEY(vacancy_id) REFERENCES vacancy(vacancy_id), INDEX idx_application_status(status), INDEX idx_application_date(application_date)
);
CREATE TABLE application_status_history (
 history_id BIGINT AUTO_INCREMENT PRIMARY KEY, application_id INT NOT NULL, old_status ENUM('APPLIED','SHORTLISTED','SELECTED','REJECTED') NULL,
 new_status ENUM('APPLIED','SHORTLISTED','SELECTED','REJECTED') NOT NULL, changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(application_id) REFERENCES application(application_id) ON DELETE CASCADE, INDEX idx_history_application(application_id)
);

DELIMITER //
CREATE TRIGGER trg_application_before_insert BEFORE INSERT ON application FOR EACH ROW
BEGIN
 DECLARE valid_vacancy INT DEFAULT 0;
 SELECT COUNT(*) INTO valid_vacancy FROM vacancy WHERE vacancy_id=NEW.vacancy_id AND status='OPEN' AND last_date >= DATE(NEW.application_date) AND openings > 0;
 IF valid_vacancy=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vacancy is closed, expired, or has no openings'; END IF;
END//
CREATE TRIGGER trg_application_after_insert AFTER INSERT ON application FOR EACH ROW
BEGIN INSERT INTO application_status_history(application_id,old_status,new_status) VALUES(NEW.application_id,NULL,NEW.status); END//
CREATE TRIGGER trg_application_before_update BEFORE UPDATE ON application FOR EACH ROW
BEGIN
 IF NOT ((OLD.status='APPLIED' AND NEW.status IN ('SHORTLISTED','REJECTED')) OR (OLD.status='SHORTLISTED' AND NEW.status IN ('SELECTED','REJECTED')) OR OLD.status=NEW.status) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid application status transition';
 END IF;
 IF NEW.status IN ('SELECTED','REJECTED') AND NEW.decision_date IS NULL THEN SET NEW.decision_date=NOW(); END IF;
END//
CREATE TRIGGER trg_application_after_update AFTER UPDATE ON application FOR EACH ROW
BEGIN
 IF OLD.status <> NEW.status THEN
  INSERT INTO application_status_history(application_id,old_status,new_status) VALUES(NEW.application_id,OLD.status,NEW.status);
  IF NEW.status='SELECTED' THEN UPDATE vacancy SET openings=GREATEST(openings-1,0) WHERE vacancy_id=NEW.vacancy_id; END IF;
 END IF;
END//
CREATE PROCEDURE apply_for_vacancy(IN p_student_id INT, IN p_vacancy_id INT)
BEGIN
 DECLARE eligible INT DEFAULT 0; DECLARE duplicate_count INT DEFAULT 0;
 START TRANSACTION;
 SELECT COUNT(*) INTO duplicate_count FROM application WHERE student_id=p_student_id AND vacancy_id=p_vacancy_id;
 IF duplicate_count>0 THEN ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate application'; END IF;
 SELECT COUNT(*) INTO eligible FROM student s JOIN vacancy v ON v.vacancy_id=p_vacancy_id JOIN vacancy_department vd ON vd.vacancy_id=v.vacancy_id
 WHERE s.student_id=p_student_id AND s.cgpa>=v.min_cgpa AND s.department_id=vd.department_id AND s.qualification=v.required_qualification AND v.status='OPEN' AND v.last_date>=CURDATE() AND v.openings>0;
 IF eligible=0 THEN ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Student is not eligible'; END IF;
 INSERT INTO application(student_id,vacancy_id) VALUES(p_student_id,p_vacancy_id); COMMIT;
END//
DELIMITER ;

CREATE OR REPLACE VIEW v_vacancy_application_counts AS
SELECT v.vacancy_id,c.name company,v.job_title,v.status,v.openings,COUNT(a.application_id) applications,SUM(a.status='SELECTED') selections
FROM vacancy v JOIN company c ON c.company_id=v.company_id LEFT JOIN application a ON a.vacancy_id=v.vacancy_id GROUP BY v.vacancy_id;
CREATE OR REPLACE VIEW v_company_recruitment_summary AS
SELECT c.company_id,c.name,c.industry,COUNT(DISTINCT v.vacancy_id) vacancies,COUNT(a.application_id) applications,SUM(a.status='SELECTED') selections
FROM company c LEFT JOIN vacancy v ON v.company_id=c.company_id LEFT JOIN application a ON a.vacancy_id=v.vacancy_id GROUP BY c.company_id;
CREATE OR REPLACE VIEW v_department_placement_stats AS
SELECT d.department_id,d.name department,COUNT(DISTINCT s.student_id) students,COUNT(a.application_id) applications,
 COUNT(DISTINCT CASE WHEN a.status='SELECTED' THEN s.student_id END) placed_students,
 ROUND(100*COUNT(DISTINCT CASE WHEN a.status='SELECTED' THEN s.student_id END)/NULLIF(COUNT(DISTINCT s.student_id),0),2) placement_percentage
FROM department d LEFT JOIN student s ON s.department_id=d.department_id LEFT JOIN application a ON a.student_id=s.student_id GROUP BY d.department_id;
