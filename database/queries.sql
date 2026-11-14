USE job_portal;
-- Q1: Open vacancies and their company details.
SELECT c.name,v.job_title,v.location,v.max_salary FROM vacancy v JOIN company c USING(company_id) WHERE v.status='OPEN';
-- Q2: Applications submitted by every student.
SELECT s.name,c.name company,v.job_title,a.status FROM application a JOIN student s USING(student_id) JOIN vacancy v USING(vacancy_id) JOIN company c USING(company_id);
-- Q3: Application counts by vacancy.
SELECT * FROM v_vacancy_application_counts;
-- Q4: Selections by department.
SELECT * FROM v_department_placement_stats;
-- Q5: Company recruitment rollup.
SELECT * FROM v_company_recruitment_summary;
-- Q6: Companies with at least 5 applications (HAVING).
SELECT c.name,COUNT(*) applications FROM application a JOIN vacancy v USING(vacancy_id) JOIN company c USING(company_id) GROUP BY c.company_id HAVING COUNT(*)>=5;
-- Q7: Students whose CGPA exceeds their department average (subquery).
SELECT s.* FROM student s WHERE cgpa>(SELECT AVG(cgpa) FROM student x WHERE x.department_id=s.department_id);
-- Q8: Rank companies by selected candidates (window function).
SELECT name,selections,RANK() OVER(ORDER BY selections DESC) recruitment_rank FROM v_company_recruitment_summary;
-- Q9: Average salary by industry.
SELECT c.industry,ROUND(AVG((v.min_salary+v.max_salary)/2),2) avg_salary FROM vacancy v JOIN company c USING(company_id) GROUP BY c.industry;
-- Q10: Monthly trend.
SELECT DATE_FORMAT(application_date,'%Y-%m') month,COUNT(*) applications FROM application GROUP BY month ORDER BY month;
-- Q11: Vacancies with no applications.
SELECT v.vacancy_id,v.job_title FROM vacancy v LEFT JOIN application a USING(vacancy_id) WHERE a.application_id IS NULL;
-- Q12: Eligible students for vacancy 1.
SELECT s.name,s.cgpa FROM student s JOIN vacancy_department vd ON vd.department_id=s.department_id JOIN vacancy v ON v.vacancy_id=vd.vacancy_id WHERE v.vacancy_id=1 AND s.cgpa>=v.min_cgpa AND s.qualification=v.required_qualification;
