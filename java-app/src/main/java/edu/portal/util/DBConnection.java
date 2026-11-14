package edu.portal.util;
import java.io.*; import java.sql.*; import java.util.*;
public final class DBConnection { private DBConnection(){} public static Connection get() throws SQLException { Properties p=new Properties(); try(InputStream in=DBConnection.class.getClassLoader().getResourceAsStream("db.properties")){ if(in==null) throw new SQLException("db.properties missing"); p.load(in); } catch(IOException e){throw new SQLException("Cannot read database configuration",e);} return DriverManager.getConnection(p.getProperty("db.url"),p.getProperty("db.user"),p.getProperty("db.password")); } }
