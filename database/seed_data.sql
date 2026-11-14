USE job_portal;
INSERT INTO department(name) VALUES ('Computer Science'),('Information Technology'),('Electronics'),('Mechanical'),('Civil'),('Business Administration');
INSERT INTO company(name,industry,location,contact) VALUES
('Infosys','IT Services','Bengaluru','talent@infosys.example'),('TCS','IT Services','Mumbai','jobs@tcs.example'),('Wipro','IT Services','Hyderabad','jobs@wipro.example'),('Accenture','Consulting','Pune','jobs@accenture.example'),('Deloitte','Consulting','Gurugram','jobs@deloitte.example'),('Amazon','E-commerce','Bengaluru','jobs@amazon.example'),('Flipkart','E-commerce','Bengaluru','jobs@flipkart.example'),('L&T','Engineering','Mumbai','jobs@lnt.example'),('Siemens','Manufacturing','Pune','jobs@siemens.example'),('HCLTech','IT Services','Noida','jobs@hcl.example');
-- Generates 100 students with reproducible department, skill and CGPA variation.
INSERT INTO student(name,department_id,qualification,skills,cgpa,email,phone)
SELECT CONCAT('Student ',n),((n-1)%6)+1,'B.Tech',ELT(((n-1)%5)+1,'Java, SQL, Python','Python, Pandas, SQL','C++, CAD, AutoCAD','JavaScript, React, SQL','Excel, Power BI, SQL'),ROUND(6.0+(n%39)/10,2),CONCAT('student',n,'@college.example'),CONCAT('90000',LPAD(n,5,'0'))
FROM (SELECT a.n+b.n*10+1 n FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b) x;
INSERT INTO vacancy(company_id,job_title,min_cgpa,required_qualification,location,min_salary,max_salary,openings,last_date,status,created_at)
SELECT ((n-1)%10)+1,ELT(((n-1)%5)+1,'Software Engineer','Data Analyst','Graduate Engineer Trainee','Business Analyst','QA Engineer'),6.0+(n%10)/10,'B.Tech',ELT(((n-1)%5)+1,'Bengaluru','Pune','Hyderabad','Mumbai','Noida'),350000+n*12000,500000+n*15000,10+(n%15),DATE_ADD('2029-12-31',INTERVAL n DAY),'OPEN',DATE_ADD('2024-01-01',INTERVAL n*12 DAY)
FROM (SELECT a.n+b.n*10+1 n FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) b) x;
INSERT INTO vacancy_department(vacancy_id,department_id) SELECT vacancy_id,((vacancy_id-1)%6)+1 FROM vacancy;
INSERT INTO vacancy_department(vacancy_id,department_id) SELECT vacancy_id,((vacancy_id)%6)+1 FROM vacancy;
-- 320 unique applications. Temporarily dates are historical; imported seed bypasses operational expiry rule.
DROP TRIGGER IF EXISTS trg_application_before_insert;
INSERT INTO application(student_id,vacancy_id,application_date,status,decision_date)
SELECT (MOD(FLOOR((n-1)/40)*13+((n-1)%40),100))+1,((n-1)%40)+1,DATE_ADD('2024-01-15',INTERVAL n*3 DAY),ELT((n%10)+1,'APPLIED','APPLIED','APPLIED','APPLIED','SHORTLISTED','SHORTLISTED','SHORTLISTED','SELECTED','SELECTED','REJECTED'),CASE WHEN n%10 IN (8,9,10) THEN DATE_ADD('2024-01-15',INTERVAL n*3+12 DAY) END
FROM (SELECT a.n+b.n*10+c.n*100+1 n FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) c) x WHERE n<=360;
DELIMITER //
CREATE TRIGGER trg_application_before_insert BEFORE INSERT ON application FOR EACH ROW BEGIN DECLARE valid_vacancy INT DEFAULT 0; SELECT COUNT(*) INTO valid_vacancy FROM vacancy WHERE vacancy_id=NEW.vacancy_id AND status='OPEN' AND last_date>=DATE(NEW.application_date) AND openings>0; IF valid_vacancy=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vacancy is closed, expired, or has no openings'; END IF; END//
DELIMITER ;
