# Project Methodology

An incremental Agile-style approach is used: first establish database constraints, then expose those rules through Java services, then consume the clean data in analysis. This is preferable to a strict waterfall handoff because each layer can validate assumptions early, while the short, stable academic scope still benefits from documented requirements and traceability.

## Traceability

| FR | Code module | DB object | Tests |
|---|---|---|---|
| FR1 | DAO/model extension points | student | T01–T07 |
| FR2 | vacancy/company modules | company, vacancy | T08–T10 |
| FR3 | EligibilityService | procedure/insert trigger | T11–T16 |
| FR4 | ApplicationService | unique constraint | T17 |
| FR5 | ApplicationRules | update triggers/history | T18–T22 |
| FR6 | reports/export | views/queries | T24–T25 |
| FR7 | python main.py | database/CSV | T26 |
