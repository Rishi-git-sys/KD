package edu.portal.model;
import java.time.LocalDateTime;
public record Application(int id,int studentId,int vacancyId,LocalDateTime applicationDate,ApplicationStatus status) {}
