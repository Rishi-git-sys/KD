package edu.portal.web;
import jakarta.validation.constraints.*;
public class StudentForm { public Integer studentId; @NotBlank public String name; @NotNull public Integer departmentId; @NotBlank public String qualification; @NotBlank public String skills; @DecimalMin("0.0") @DecimalMax("10.0") public Double cgpa; @Email @NotBlank public String email; @NotBlank public String phone; }
