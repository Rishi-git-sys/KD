package edu.portal.service;
import edu.portal.model.ApplicationStatus;
public class ApplicationRules {
 public boolean canTransition(ApplicationStatus from, ApplicationStatus to) { return from==to || (from==ApplicationStatus.APPLIED && (to==ApplicationStatus.SHORTLISTED || to==ApplicationStatus.REJECTED)) || (from==ApplicationStatus.SHORTLISTED && (to==ApplicationStatus.SELECTED || to==ApplicationStatus.REJECTED)); }
 public void validateTransition(ApplicationStatus from,ApplicationStatus to) { if(!canTransition(from,to)) throw new InvalidStatusTransitionException(); }
}
