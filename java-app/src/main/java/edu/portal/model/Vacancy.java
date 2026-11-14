package edu.portal.model;
import java.time.LocalDate; import java.util.Set;
public record Vacancy(int id,int companyId,String title,double minCgpa,String qualification,Set<Integer> allowedDepartments,String location,double minSalary,double maxSalary,int openings,LocalDate lastDate,boolean open) {}
