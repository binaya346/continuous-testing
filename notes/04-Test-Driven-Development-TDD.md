# Test-Driven Development (TDD) Approach

**TDD** is a software development process where requirements are turned into very specific test cases, then the software is improved to pass the new tests.

---

## 1. The TDD Cycle (Red-Green-Refactor)
TDD follows a very strict cycle:

1. **🔴 RED**: Write a small, specific test for a feature that doesn't exist yet. The test *must* fail.
2. **🟢 GREEN**: Write the minimum amount of code required to make the test pass. (Don't worry about clean code yet).
3. **🔵 REFACTOR**: Now that the test passes, clean up the code, remove duplication, and improve performance.

---

## 2. Why use TDD?
| Benefit | Description |
| :--- | :--- |
| **High Quality Code** | Features are only written if they have a corresponding test. |
| **Documentation** | Tests serve as "living documentation" on how the code should work. |
| **Easier Refactoring** | You can change your code with confidence because the tests will catch any breaks. |
| **Reduce Debugging** | You find bugs immediately as they are being written. |

---
=> unit testing (functional testing) => Developer Responsibility

## 3. TDD Example (Java)
### Phase 1: 🔴 Red
```java
@Test
public void testAddition() {
    Calculator calc = new Calculator();
    Assert.assertEquals(5, calc.add(2, 3));
}
// This will fail because the Calculator class or add method doesn't exist.
```

### Phase 2: 🟢 Green
```java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
}
// Now the test passes!
```

### Phase 3: 🔵 Refactor
```java
// If there was any complicated logic, we would clean it up here.
// In this simple example, we might ensure proper naming or comments.
```

---

## 4. TDD vs. Traditional Testing
| Traditional Testing | TDD (Continuous Testing) |
| :--- | :--- |
| First write code, then write tests at the end. | First write tests, then write code to satisfy them. |
| Testing happens in its own phase. | Testing is the process of development. |
| High chance of missing complex edge cases. | High coverage is guaranteed because every line is tested. |

---

## 5. Challenges of TDD
- **Learning Curve**: It takes time to learn how to write effective tests first.
- **Up-front Cost**: Initial development might feel slower.
- **Maintenance**: Changing requirements means changing both tests and code.
