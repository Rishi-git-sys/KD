package edu.portal.dao;
import edu.portal.model.Student; import edu.portal.util.DBConnection; import java.sql.*; import java.util.*;
public class JdbcStudentDao implements StudentDao {
 private Student map(ResultSet r)throws SQLException{return new Student(r.getInt("student_id"),r.getString("name"),r.getInt("department_id"),r.getString("qualification"),r.getString("skills"),r.getDouble("cgpa"),r.getString("email"),r.getString("phone"));}
 public int create(Student s)throws SQLException{String q="INSERT INTO student(name,department_id,qualification,skills,cgpa,email,phone) VALUES(?,?,?,?,?,?,?)";try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement(q,Statement.RETURN_GENERATED_KEYS)){bind(p,s);p.executeUpdate();try(ResultSet k=p.getGeneratedKeys()){k.next();return k.getInt(1);}}}
 public Optional<Student> findById(int id)throws SQLException{try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement("SELECT * FROM student WHERE student_id=?")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){return r.next()?Optional.of(map(r)):Optional.empty();}}}
 public List<Student> findAll()throws SQLException{List<Student> out=new ArrayList<>();try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement("SELECT * FROM student ORDER BY student_id");ResultSet r=p.executeQuery()){while(r.next())out.add(map(r));}return out;}
 public void update(Student s)throws SQLException{String q="UPDATE student SET name=?,department_id=?,qualification=?,skills=?,cgpa=?,email=?,phone=? WHERE student_id=?";try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement(q)){bind(p,s);p.setInt(8,s.id());p.executeUpdate();}}
 public void delete(int id)throws SQLException{try(Connection c=DBConnection.get();PreparedStatement p=c.prepareStatement("DELETE FROM student WHERE student_id=?")){p.setInt(1,id);p.executeUpdate();}}
 private void bind(PreparedStatement p,Student s)throws SQLException{p.setString(1,s.name());p.setInt(2,s.departmentId());p.setString(3,s.qualification());p.setString(4,s.skills());p.setDouble(5,s.cgpa());p.setString(6,s.email());p.setString(7,s.phone());}
}
