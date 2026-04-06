# Different Types of Testing

Testing is categorized into two main groups: **Functional Testing** (testing *what* the application does) and **Non-Functional Testing** (testing *how* the application performs).

---

## 1. Functional Testing
These tests verify that each function of the software application operates in conformance with the requirements.

### A. Unit Testing
- **Goal**: Verify each unit of code (module, function, method) in isolation.
- **Tools**: JUnit, NUnit, PyTest.
- **Key**: Only one small thing should be tested at a time.

### B. Integration Testing
- **Goal**: Verify that different modules or services interact correctly.
- **Example**: Does the "Login" page correctly communicate with the "Database"?
- **Techniques**: Top-down, Bottom-up, Big Bang.

### C. System Testing
- **Goal**: Verify the entire integrated software system to ensure it meets requirements.
- **Key**: This is "Black Box" testing where the internal code isn't examined.

### D. Acceptance Testing
- **Goal**: Verify if the system is ready for the end-user.
- **UMT (User Acceptance Testing)**: Real users testing the software.

---

## 2. Non-Functional Testing
These tests verify aspects like performance, security, and usability.

### A. Performance Testing
- **Load Testing**: How does the system behave under "normal" load?
- **Stress Testing**: When does the system break?
- **Scalability Testing**: Does it scale up/down correctly?

### B. Security Testing
- **Goal**: Identify vulnerabilities, threats, and risks.
- **Tools**: SonarQube (SAST), OWASP ZAP (DAST).

### C. Usability Testing
- **Goal**: Determine if the application is easy to use and intuitive for the user.

---

## 3. The Automation Pyramid (Revisited)
To maintain a high velocity, follow this structure for test types:
1. **Unit Tests (Most)**: Fast, cheap, reliable.
2. **Integration/API Tests**: Tests service logic.
3. **UI/Selenium Tests (Least)**: Slow, brittle, expensive.

---

## 4. Retesting vs. Regression Testing
- **Retesting**: You fix a bug, and you test that specific bug again to ensure it's gone.
- **Regression Testing**: You fix a bug, and you test the *entire system* to ensure your fix didn't break something else.
