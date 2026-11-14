package edu.portal.service;
import edu.portal.dao.ApplicationDao; import edu.portal.model.*; import java.sql.SQLException;
public class ApplicationService { private final ApplicationDao dao; private final EligibilityService eligibility=new EligibilityService(); private final ApplicationRules rules=new ApplicationRules(); public ApplicationService(ApplicationDao dao){this.dao=dao;}
 public void apply(Student s,Vacancy v)throws SQLException { eligibility.validate(s,v); if(dao.exists(s.id(),v.id())) throw new DuplicateApplicationException(); dao.apply(s.id(),v.id()); }
 public void updateStatus(Application application,ApplicationStatus target)throws SQLException { rules.validateTransition(application.status(),target); dao.updateStatus(application.id(),target); }
}
