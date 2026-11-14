# Software Requirements Specification

## Introduction and scope
The system supports a college placement cell by recording students, recruiters, vacancies and recruitment outcomes, then analysing multi-year outcomes.

## Functional requirements
FR1–FR7 are implemented exactly as listed in the project README verification matrix: CRUD data management, eligibility-aware applications, duplicate prevention, status audit, reports and Python analysis.

## Web interface extension
Placement officers can access a Bootstrap/Thymeleaf dashboard, CRUD screens, reports, chart gallery and REST API. The browser layer is a presentation/client layer above the existing MySQL rules; invalid applications continue to be rejected by the stored procedure and constraints.

## Non-functional requirements
MySQL 8 integrity enforcement, Java 17 portability, prepared statements, configurable credentials, usable console menus, CSV fallback, reproducible seed data and maintainable layered code.

## Assumptions, constraints and users
Students are B.Tech candidates in the seed dataset; a vacancy permits one or more departments. The placement cell controls status changes. MySQL 8, Java 17 and Python 3.10+ are required. Users are students/job-seekers, placement officers and analysts.
