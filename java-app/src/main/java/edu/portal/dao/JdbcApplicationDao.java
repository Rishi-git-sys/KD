package edu.portal.dao;
import edu.portal.model.ApplicationStatus; import edu.portal.util.DBConnection; import java.sql.*;
public class JdbcApplicationDao implements ApplicationDao {
 public boolean exists(int studentId,int vacancyId)throws SQLException {String q="SELECT 1 FROM application WHERE student_id=? AND vacancy_id=?";try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement(q)){p.setInt(1,studentId);p.setInt(2,vacancyId);return p.executeQuery().next();}}
 public void apply(int studentId,int vacancyId)throws SQLException {try(Connection c=DBConnection.get();CallableStatement p=c.prepareCall("{CALL apply_for_vacancy(?,?)}")){p.setInt(1,studentId);p.setInt(2,vacancyId);p.execute();}}
 public void updateStatus(int applicationId,ApplicationStatus status)throws SQLException {String q="UPDATE application SET status=? WHERE application_id=?";try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement(q)){p.setString(1,status.name());p.setInt(2,applicationId);p.executeUpdate();}}
}
