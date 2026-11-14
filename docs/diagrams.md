# Design Diagrams

## Use case
```mermaid
flowchart LR
 Student-->Apply; PlacementCell-->Manage[Manage students, companies and vacancies]; PlacementCell-->Status[Update status]; Analyst-->Reports[Reports and trend analysis]; Apply-->Eligibility[Eligibility and duplicate validation]
```
## Class diagram
```mermaid
classDiagram
 class Student {+id +cgpa +qualification} class Vacancy {+id +minCgpa +lastDate} class ApplicationService {+apply() +updateStatus()} class ApplicationDao {<<interface>> +exists() +apply() +updateStatus()} ApplicationService --> ApplicationDao
```
## Apply sequence
```mermaid
sequenceDiagram
 Student->>Console: apply
 Console->>ApplicationService: apply(student,vacancy)
 ApplicationService->>ApplicationService: validate eligibility
 ApplicationService->>ApplicationDao: exists
 ApplicationService->>Database: CALL apply_for_vacancy
 Database-->>Student: application / friendly error
```
## Activity and DFD
```mermaid
flowchart TD
 A[Student chooses vacancy]-->B{Eligible?}; B--No-->X[Show reason]; B--Yes-->C{Duplicate?}; C--Yes-->Y[Show duplicate message]; C--No-->D[Store application and audit]; D-->E[Placement cell updates status]; E-->F[Reports / Python analysis]
```
Level 0: Student, placement cell and analyst exchange profile, vacancy, application and report data with the Job Portal. Level 1 decomposes the portal into profile management, vacancy management, application validation/status audit, reporting/export and analysis.
