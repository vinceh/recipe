# Testing Requirements and Standards

This guide defines what adequate testing looks like and identifies testing anti-patterns.

## Core Testing Principles

### Test Coverage Requirements

**Minimum Coverage Standards:**
- **Critical paths** (auth, payments, data processing): 100% coverage
- **Public APIs**: 80%+ coverage
- **Business logic**: 80%+ coverage
- **Utilities**: 70%+ coverage
- **Overall project**: 70%+ coverage

**Coverage is NOT enough** - 100% coverage with bad tests provides false confidence. Tests must verify actual behavior, not just call functions.

---

## Unit Testing Standards

### What Unit Tests Should Verify

Unit tests should verify a single function or component in isolation:

```javascript
// GOOD: Tests single function behavior
describe('calculateTotal', () => {
  test('sums items correctly', () => {
    const items = [10, 20, 30];
    expect(calculateTotal(items)).toBe(60);
  });

  test('handles empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });

  test('handles negative values', () => {
    const items = [10, -5, 20];
    expect(calculateTotal(items)).toBe(25);
  });
});

// BAD: Tests entire workflow
test('user can sign up and login and update profile', async () => {
  // 200 lines of setup and testing multiple features
  // Hard to debug when fails
});
```

### Unit Test Anti-Patterns

#### 1. Only Happy Path Testing

**Bad:**
```javascript
test('user login', async () => {
  const user = await login('user@example.com', 'password123');
  expect(user.id).toBeDefined();
});
// Missing: wrong password, user not found, network error, rate limiting
```

**Good:**
```javascript
describe('User login', () => {
  test('succeeds with correct credentials', async () => {
    const user = await login('user@example.com', 'correctPassword');
    expect(user.id).toBe(123);
  });

  test('fails with wrong password', async () => {
    await expect(login('user@example.com', 'wrongPassword'))
      .rejects.toThrow('Invalid credentials');
  });

  test('fails when user not found', async () => {
    await expect(login('nonexistent@example.com', 'password'))
      .rejects.toThrow('User not found');
  });

  test('fails with network error', async () => {
    mockAPI.mockRejectedValue(new NetworkError());
    await expect(login('user@example.com', 'password'))
      .rejects.toThrow(NetworkError);
  });
});
```

#### 2. Over-Mocking

**Bad:**
```javascript
// Entire test is mocked - tests nothing real
test('payment succeeds', async () => {
  const mockPaymentGateway = jest.fn().mockResolvedValue({ success: true });
  const mockEmail = jest.fn().mockResolvedValue();
  const mockDB = jest.fn().mockResolvedValue();

  await processPayment(mockPaymentGateway, mockEmail, mockDB);

  expect(mockPaymentGateway).toHaveBeenCalled();
  // Test passes, but we don't know if real payment gateway works!
});
```

**Good:**
```javascript
describe('Payment processing', () => {
  // Unit test with mocks - tests this function's logic
  test('calls payment gateway with correct amount', async () => {
    const mockGateway = jest.fn().mockResolvedValue({ id: 'txn123' });
    await processPayment({ amount: 100 }, mockGateway);
    expect(mockGateway).toHaveBeenCalledWith(100);
  });

  // Integration test - verifies real behavior
  test('processes payment with real gateway (integration)', async () => {
    const result = await processPayment(
      { amount: 100 },
      realPaymentGateway  // Real service or test service
    );
    expect(result.status).toBe('completed');
    expect(result.transactionId).toBeDefined();
  });
});
```

#### 3. Skipped or Disabled Tests

**Bad:**
```javascript
test.skip('validates user email', () => {
  // Why skipped? No comment explaining
  expect(validateEmail('test@example.com')).toBe(true);
});

test.todo('handles database failures');

xit('processes large datasets', () => {
  // Missing implementation without explanation
});
```

**Good:**
```javascript
// If test is temporarily skipped, explain why and create issue
test.skip('validates international phone numbers', () => {
  // TODO: https://github.com/org/repo/issues/123
  // Skipped until phone validation library updated
  expect(validatePhone('+44 20 7946 0958')).toBe(true);
});

// If feature isn't ready, use pending test
test('handles database failures gracefully', async () => {
  // This will fail until database fallback is implemented
  // This test documents the expected behavior
  mockDB.mockRejectedValue(new DatabaseError());
  const result = await getUser(123);
  expect(result).toEqual(FALLBACK_USER_DATA);
});
```

#### 4. Assertion-Only Tests

**Bad:**
```javascript
test('sum function', () => {
  // No setup, no meaningful test
  sum(1, 2);
  expect(3).toBe(3);  // Tautology!
});
```

**Good:**
```javascript
test('adds two positive numbers', () => {
  const result = sum(1, 2);
  expect(result).toBe(3);
});
```

---

## Integration Testing Standards

### When Integration Tests Are Required

**Use integration tests for:**
- Database interactions
- API calls
- File system operations
- External service calls
- Multi-component workflows
- Real authentication flows

### Integration Test Example

```javascript
describe('User API Integration', () => {
  // Separate from unit tests - uses real or test database
  beforeAll(async () => {
    await testDB.connect();
  });

  afterAll(async () => {
    await testDB.disconnect();
  });

  test('creates user in database', async () => {
    const user = await createUser({
      email: 'test@example.com',
      name: 'Test User'
    });

    // Verify in real database
    const saved = await db.users.findById(user.id);
    expect(saved.email).toBe('test@example.com');
  });

  test('handles duplicate email', async () => {
    await createUser({ email: 'duplicate@example.com', name: 'User 1' });

    await expect(
      createUser({ email: 'duplicate@example.com', name: 'User 2' })
    ).rejects.toThrow('Email already exists');
  });
});
```

---

## Test Coverage Anti-Patterns

### Fake Coverage

**Bad:**
```javascript
// 100% coverage but tests nothing real
test('getUserById exists', () => {
  expect(typeof getUserById).toBe('function');
});

test('API endpoint returns 200', () => {
  mockRequest.mockResolvedValue({ status: 200 });
  makeRequest('/api/users/1');
  expect(mockRequest).toHaveBeenCalled();
  // Doesn't test if response is valid!
});
```

**Good:**
```javascript
test('getUserById returns user with correct fields', () => {
  const user = getUserById(123);
  expect(user).toHaveProperty('id', 123);
  expect(user).toHaveProperty('email');
  expect(user).toHaveProperty('name');
  expect(user).not.toHaveProperty('password'); // Ensure sensitive data not exposed
});

test('API endpoint returns valid user data', async () => {
  const response = await fetch('/api/users/1');
  const data = await response.json();

  expect(response.status).toBe(200);
  expect(data).toHaveProperty('id');
  expect(data).toHaveProperty('email');
  expect(typeof data.id).toBe('number');
  expect(typeof data.email).toBe('string');
});
```

---

## Test Quality Indicators

### Red Flags ❌

- Tests only call functions, don't verify behavior
- All tests use mocks, no integration tests
- Skipped/pending tests without explanation
- Tests pass but code doesn't work
- Only happy path tested
- No edge case tests
- Test coverage is high but many tests are weak
- Tests are brittle and break with minor changes
- No test descriptions (unclear what's being tested)
- Test files not organized

### Green Flags ✅

- Clear test names describe what's being tested
- Tests verify behavior, not implementation
- Mix of unit and integration tests
- Edge cases covered
- Error cases tested
- Assertions are specific
- Tests are independent
- Tests are maintainable
- Coverage is adequate and meaningful
- CI/CD enforces tests pass before merge

---

## Critical Features Testing Checklist

For critical paths (authentication, payments, data processing):

### Authentication/Authorization
- [ ] Valid credentials succeed
- [ ] Invalid credentials fail
- [ ] Expired tokens rejected
- [ ] Missing credentials rejected
- [ ] Rate limiting prevents brute force
- [ ] Session timeout works
- [ ] Permissions enforced

### Payment Processing
- [ ] Valid payment processes
- [ ] Insufficient funds fails
- [ ] Invalid card details fail
- [ ] Duplicate charge prevented
- [ ] Refund works correctly
- [ ] Transaction logged
- [ ] Receipt generated
- [ ] Error states handled gracefully

### Data Processing
- [ ] Valid data processed correctly
- [ ] Invalid data rejected with error
- [ ] Empty input handled
- [ ] Large input handled
- [ ] Malformed data rejected
- [ ] Partial failures handled
- [ ] Rollback works on failure

---

## Test Anti-Patterns Checklist

When auditing tests, look for these anti-patterns:

### Missing Tests ❌
- [ ] Functions with no tests
- [ ] Error paths untested
- [ ] Edge cases untested
- [ ] Integration points untested

### Weak Tests ❌
- [ ] Tests that always pass
- [ ] Tests that only check type, not value
- [ ] Tests with generic assertions
- [ ] Tests that don't actually call code being tested

### Brittle Tests ❌
- [ ] Tests that break with refactoring
- [ ] Overly specific assertions
- [ ] Mock-heavy, reality-disconnected
- [ ] Order-dependent tests

### Skipped Tests ❌
- [ ] `test.skip()` without explanation
- [ ] `test.todo()` with no issue reference
- [ ] `xit()` or `xdescribe()` left in
- [ ] Commented-out tests

### Over-Mocking ❌
- [ ] All external dependencies mocked
- [ ] No integration tests
- [ ] Tests passing but code breaks in production
- [ ] Tests isolated from reality

---

## Testing Standards Summary

**Minimum Test Presence:**
- All public functions have tests
- All business logic paths tested
- Error cases tested
- Edge cases tested

**Minimum Test Quality:**
- Tests verify actual behavior, not just call functions
- Mix of unit and integration tests
- Clear test names
- No permanently skipped tests
- Coverage >70% (meaningful coverage)

**Critical Features:**
- 100% unit test coverage
- Integration tests with real services
- Load testing if performance critical
- Security testing for auth/payment features
