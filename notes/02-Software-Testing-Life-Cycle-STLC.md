# Software Testing Life Cycle (STLC)

The **STLC** is a sequence of specific activities conducted during the testing process to ensure software quality goals are met.

---

## 1. Phases of STLC
The STLC consists of six main phases, each with specific entry and exit criteria:

### A. Requirement Analysis
- **Goal**: Understand what needs to be tested.
- **Activities**: Review Software Requirement Specification (SRS) documents. Identify types of tests (functional vs. non-functional).
- **Outcomes**: List of testable requirements.

### B. Test Planning
- **Goal**: Define the strategy and resources for testing.
- **Activities**: Estimate effort, define scope, select tools, and assign roles.
- **Outcomes**: **Test Plan document**, Risk analysis.

### C. Test Case Development
- **Goal**: Create detailed test steps and data.
- **Activities**: Write test scenarios, scripts (Selenium), and prepare test data.
- **Outcomes**: **Test Cases**, Test Scripts, Test Data.

### D. Test Environment Setup
- **Goal**: Prepare the hardware/software for test execution.
- **Activities**: Install required software (Java, Selenium, Jenkins). Configure servers/containers.
- **Outcomes**: **Ready-to-use Test Environment**.

### E. Test Execution
- **Goal**: Run the tests and report results.
- **Activities**: Execute test cases. Log defects. Re-test once bug fixes are provided.
- **Outcomes**: **Test Execution Report**, Defect Logs.

### F. Test Closure
- **Goal**: Analyze and finalize the testing process.
- **Activities**: Evaluate criteria for completion. Prepare summary reports.
- **Outcomes**: **Test Summary Report**, Best Practices.

---

## 2. STLC vs. SDLC
| SDLC (Software Development) | STLC (Software Testing) |
| :--- | :--- |
| Focus is on *building* the product. | Focus is on *verifying* the product. |
| Steps: Req -> Design -> Code -> Test -> Maintain. | Steps: Req Analysis -> Plan -> Develop -> Execute -> Close. |
| Testing is just one phase of SDLC. | Testing is the entire scope of STLC. |

---

## 3. Why Bother with STLC?
- **Consistency**: Ensures a repeatable process across different projects.
- **Transparency**: Stakeholders know exactly what is being tested and why.
- **Predictability**: Clear entry/exit criteria prevent starting tests on unfinished code.
- **Quality**: Each phase focuses on a specific aspect of software stability.
