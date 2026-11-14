package edu.portal.dao;
import edu.portal.model.Student; import java.sql.SQLException; import java.util.List; import java.util.Optional;
public interface StudentDao { int create(Student student) throws SQLException; Optional<Student> findById(int id) throws SQLException; List<Student> findAll() throws SQLException; void update(Student student) throws SQLException; void delete(int id) throws SQLException; }
