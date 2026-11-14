package edu.portal.service; public class NotEligibleException extends RuntimeException { public NotEligibleException(String reason){super("Not eligible: "+reason);} }
