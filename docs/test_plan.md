# Test Plan

| ID | Description | Input | Expected output | Actual | Result |
|---|---|---|---|---|---|
| T01 | Create student | valid profile | saved | pending DB run | Pending |
| T02 | Read student | known ID | profile | pending | Pending |
| T03 | Update student | valid CGPA | updated | pending | Pending |
| T04 | Delete student | unused ID | removed | pending | Pending |
| T05 | Unique email | duplicate email | DB rejects | pending | Pending |
| T06 | CGPA lower bound | -0.1 | DB rejects | pending | Pending |
| T07 | CGPA upper bound | 10.1 | DB rejects | pending | Pending |
| T08 | Create company | valid input | saved | pending | Pending |
| T09 | Create vacancy | max < min salary | DB rejects | pending | Pending |
| T10 | Open vacancy | valid vacancy | listed | pending | Pending |
| T11 | CGPA eligibility | 6.9 vs 7 | NotEligible | unit test | Pass |
| T12 | Department eligibility | excluded dept | NotEligible | unit test | Pass |
| T13 | Qualification eligibility | mismatch | NotEligible | pending | Pending |
| T14 | Expired vacancy | past date | blocked | DB trigger | Pending |
| T15 | Closed vacancy | CLOSED | blocked | DB trigger | Pending |
| T16 | No openings | zero | blocked | DB trigger | Pending |
| T17 | Duplicate application | same pair | friendly error/unique | pending | Pending |
| T18 | Applied to shortlisted | transition | allowed | unit test | Pass |
| T19 | Applied to selected | transition | rejected | unit test | Pass |
| T20 | Rejected to selected | transition | rejected | pending | Pending |
| T21 | Selected opening update | shortlisted->selected | decremented | trigger | Pending |
| T22 | Audit creation | status change | history row | trigger | Pending |
| T23 | SQL injection | `1 OR 1=1` | harmless parameter | code review | Pass |
| T24 | Vacancy report | request open | formatted data | pending | Pending |
| T25 | Department rate | selections/students | correct percentage | view | Pending |
| T26 | CSV fallback | no DB URL | charts generated | pending | Pending |
