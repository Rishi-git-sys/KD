package edu.portal.web; import jakarta.validation.constraints.*;
public class CompanyForm { public Integer companyId; @NotBlank public String name; @NotBlank public String industry; @NotBlank public String location; @Email @NotBlank public String contact; }
