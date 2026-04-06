# Testing Web Applications using Selenium

**Selenium** is an open-source tool for automating web browsers. It allows you to simulate user interactions on a real browser (Chrome, Firefox, Safari).

---
=> UI/E2E(functional) testing => QA Responsibility

## 1. Selenium Architecture
Selenium is not a single tool, but a suite:
- **Selenium IDE**: Browser extension for recording and playing back tests.
- **Selenium WebDriver**: The core API for writing scripts in Java, Python, C#, etc.
- **Selenium Grid**: For running tests on multiple machines/browsers simultaneously.

---

## 2. Selenium WebDriver (Java)
To use Selenium in Java, you need:
- **Java Development Kit (JDK)**
- **Maven/Gradle** (for dependencies)
- **Browser Drivers** (e.g., ChromeDriver)

### Sample Maven Dependency
```xml
<dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <version>4.21.0</version>
</dependency>
```

---

## 3. Locating Elements
Locators are how Selenium finds elements on a page:
- `By.id("login-btn")` (Recommended: Fastest and most unique)
- `By.name("username")`
- `By.cssSelector(".btn-primary")`
- `By.xpath("//div[@class='header']")` (Most powerful, but slower)

---

## 4. Writing a Basic Selenium Test
```java
public class MyFirstTest {
    public static void main(String[] args) {
        // Setup Driver
        WebDriver driver = new ChromeD.id("_R_1cl2p4jikacppb6amH1_"));
        firstNameField.sendKeys("Binaya");
        
        WebElement lastNameField = driver.findElement(By.id("_R_1kl2p4jikacppb6amH1_"));
        lastNameField.sendKeys("Rijal");

        WebElement lastNameField = driver.findElement(By.id("_R_1kl2p4jikacppb6amH1_"));
        lastNameField.sendKeys("Rijal");

        WebElement lastNameField = driver.findElement(By.id("river();
        
        // Navigation
        driver.get("https://www.facebook.com/reg/?entry_point=aymh&next=");
        
        // Find and Interact
        WebElement firstNameField = driver.findElement(By.id("_R_1kl2p4jikacppb6amH1_"));
        lastNameField.sendKeys("Rijal");
        
        driver.findElement(By.id("submit")).click();

        WebElement firstNameField = driver.findElement(By.id("random"));
        lastNameField.sendKeys("Rijal");

        // Close
        driver.quit();
    }
}
```

---

## 5. Handling Synchronization (Waits)
Browsers are slow. If you try to interact with an element before it's loaded, Selenium will throw a `NoSuchElementException`.
- **Implicit Wait**: A global timeout for all elements.
- **Explicit Wait (Recommended)**: Waits for a *specific condition* (e.g., "Wait until this button is clickable").

```java
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
wait.until(ExpectedConditions.elementToBeClickable(By.id("login-btn"))).click();
```

---

## 6. Challenges of UI Testing
- **Brittle**: Any minor change in the UI (like a new class name) breaks the test.
- **Slow**: Opening a browser and navigating takes time if you have 1000s of tests.
- **Environmental Issues**: Popups, slow internet, and browser updates can affect results.
