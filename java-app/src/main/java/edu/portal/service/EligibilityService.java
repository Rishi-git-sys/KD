package edu.portal.service;
import edu.portal.model.*; import java.time.LocalDate;
public class EligibilityService {
 public void validate(Student s, Vacancy v) {
  if (!v.open() || v.lastDate().isBefore(LocalDate.now()) || v.openings()<1) throw new NotEligibleException("vacancy is closed, expired, or full");
  if (s.cgpa()<v.minCgpa()) throw new NotEligibleException("CGPA is below the minimum");
  if (!v.allowedDepartments().contains(s.departmentId())) throw new NotEligibleException("department is not allowed");
  if (!s.qualification().equalsIgnoreCase(v.qualification())) throw new NotEligibleException("qualification does not match");
 }
}
