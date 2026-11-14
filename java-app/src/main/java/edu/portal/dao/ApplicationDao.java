package edu.portal.dao;
import edu.portal.model.ApplicationStatus; import java.sql.SQLException;
public interface ApplicationDao { boolean exists(int studentId,int vacancyId) throws SQLException; void apply(int studentId,int vacancyId) throws SQLException; void updateStatus(int applicationId,ApplicationStatus status) throws SQLException; }
