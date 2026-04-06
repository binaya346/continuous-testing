# Continuous Testing Cheatsheet

## 1. Core Testing Concepts
| Term | Description |
| :--- | :--- |
| **Unit Test** | Tests a single "unit" of code (function/method) in isolation. |
| **Integration Test** | Tests how different modules or services work together. |
| **Regression Test** | Re-testing to ensure new changes didn't break existing features. |
| **Smoke Test** | Quick check of critical functionality (does the app even start?). |
| **Sanity Test** | Narrow, deep check of a specific bug fix or change. |
| **TDD** | Test-Driven Development (Write test -> Fail -> Write code -> Pass). |

---

## 2. Selenium WebDriver Commands (Java)
### Setup & Navigation
```java
// Initialize Driver
WebDriver driver = new ChromeDriver();

// Navigate to URL
driver.get("https://google.com");

// Maximize Window
driver.manage().window().maximize();

// Close Browser
driver.quit(); // Closes all windows and sessions
driver.close(); // Closes current window
```

### Locators
| Locator | Example |
| :--- | :--- |
| `By.id()` | `driver.findElement(By.id("login-btn"))` |
| `By.name()` | `driver.findElement(By.name("username"))` |
| `By.className()` | `driver.findElement(By.className("nav-link"))` |
| `By.cssSelector()` | `driver.findElement(By.cssSelector(".btn-primary"))` |
| `By.xpath()` | `driver.findElement(By.xpath("//input[@type='text']"))` |

### Interactions
```java
// Click
element.click();

// Typing
element.sendKeys("my-secret-password");

// Clearing Text
element.clear();

// Getting Text
String text = element.getText();
```

---

## 3. SonarQube Quality Metrics
| Metric | Description |
| :--- | :--- |
| **Bugs** | Code that is demonstrably wrong or likely to lead to errors. |
| **Vulnerabilities** | Code that can be exploited by an attacker. |
| **Code Smells** | Maintainability issues (confusing code, dead code, etc.). |
| **Debt** | Estimated time to fix all Code Smells. |
| **Coverage** | Percentage of code lines executed during unit tests. |
| **Duplications** | Identical blocks of code found in multiple places. |

---

## 4. GitHub Actions (Testing & Scanning)
```yaml
# Sample Test Workflow
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run Tests
        run: mvn test
```
