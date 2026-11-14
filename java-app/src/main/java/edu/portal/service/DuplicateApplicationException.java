package edu.portal.service; public class DuplicateApplicationException extends RuntimeException { public DuplicateApplicationException(){super("You have already applied for this vacancy.");} }
