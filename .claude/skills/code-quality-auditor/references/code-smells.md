# Code Smells and Anti-Patterns

This guide identifies common code smells and anti-patterns that indicate poor implementation quality and should be caught during review.

## Error Handling Smells

### Empty Catch Blocks

**Pattern:** Silently swallowing exceptions without logging or handling
```javascript
try {
  riskyOperation();
} catch (error) {
  // Silent failure
}
```

**Why it's bad:** Errors are hidden, making debugging impossible. Production issues go unnoticed until they cause real damage.

**How to fix:** Always log, re-throw, or handle with context:
```javascript
try {
  riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error, context });
  // Or re-throw with context
  throw new Error(`Failed to process: ${error.message}`);
}
```

### console.log for Errors

**Pattern:** Using console.log for error logging
```javascript
try {
  await fetchData();
} catch (error) {
  console.log('Error:', error);
}
```

**Why it's bad:** Console logs are lost in production. Production errors are untracked.

**How to fix:** Use proper logging:
```javascript
try {
  await fetchData();
} catch (error) {
  logger.error('Data fetch failed', { error, timestamp: Date.now() });
}
```

### Catch-All Exception Handlers

**Pattern:** Catching Exception/Error without specificity
```javascript
try {
  risky();
} catch (e) {
  // Too broad
}

// Python version
try:
    risky()
except Exception:
    pass  # Bad: catches everything
```

**Why it's bad:** Masks bugs, makes refactoring dangerous, catches unexpected errors.

**How to fix:** Catch specific exceptions:
```javascript
try {
  riskyOperation();
} catch (NetworkError) {
  handleNetworkFailure();
} catch (ValidationError) {
  handleValidationFailure();
}

# Python
try:
    risky()
except NetworkError:
    handle_network_failure()
except ValueError:
    handle_validation_failure()
```

---

## Implementation Shortcut Smells

### Magic Numbers / Hardcoded Values

**Pattern:** Unexplained numeric literals scattered through code
```javascript
// Magic numbers - what do these mean?
if (user.age > 65) { ... }
const timeout = 5000;
const maxRetries = 3;

// Hardcoded URLs
const apiUrl = 'http://api.example.com/v1/users';

// Hardcoded credentials
const password = 'admin123';
```

**Why it's bad:**
- Unclear intent
- Configuration embedded in code
- Security risk for credentials
- Hard to maintain and test

**How to fix:** Use named constants and configuration:
```javascript
const RETIREMENT_AGE = 65;
const DEFAULT_TIMEOUT_MS = 5000;
const MAX_RETRY_ATTEMPTS = 3;

const API_BASE_URL = process.env.API_URL || 'http://localhost:3000';
const DB_PASSWORD = process.env.DB_PASSWORD; // From env, never hardcoded
```

### Hardcoded Configuration

**Pattern:** Environment-specific values baked into code
```javascript
const dbHost = 'production-db-host.aws.com';
const enableCache = true;
const logLevel = 'error';
const apiTimeout = 30000;
```

**Why it's bad:** Code must change for different environments. Hard to test locally. Security risk.

**How to fix:** Use environment variables or configuration files:
```javascript
const dbHost = process.env.DB_HOST || 'localhost';
const enableCache = process.env.ENABLE_CACHE !== 'false';
const logLevel = process.env.LOG_LEVEL || 'info';
const apiTimeout = parseInt(process.env.API_TIMEOUT || '30000');
```

### Hardcoded Test Data

**Pattern:** Real user data or credentials in production code
```javascript
const testUser = {
  email: 'john.doe@example.com',
  password: 'MyActualPassword123!',
  ssn: '123-45-6789'
};
```

**Why it's bad:**
- Security vulnerability if code goes live
- Privacy violation
- Makes code unusable in different contexts

**How to fix:** Use fixtures or test factories:
```javascript
// test/fixtures/user.js
export const testUser = {
  email: 'test@example.com',
  password: process.env.TEST_USER_PASSWORD || 'testpass123',
  id: '12345'
};
```

---

## Stub and Mock Smells

### Stub Implementations Left in Production

**Pattern:** Placeholder implementations that return dummy data
```javascript
async function fetchUserData(userId) {
  // TODO: Actually implement this
  return {
    id: userId,
    name: 'Test User',
    email: 'test@example.com'
  };
}

// Python version
def calculate_discount(user_type):
    # Will implement later
    return 0.1  # Placeholder
```

**Why it's bad:** Feature doesn't actually work. Tests pass but functionality is fake.

**How to fix:** Implement the actual functionality or split into subtasks:
```javascript
async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.statusText}`);
  }
  return response.json();
}
```

### Mocking External Services Without Real Tests

**Pattern:** All tests use mocks; no integration tests verify actual behavior
```javascript
test('fetchData returns user', async () => {
  const mockFetch = jest.fn().mockResolvedValue({
    json: () => ({ id: 1, name: 'User' })
  });
  // Test passes but never verifies real API works
});
```

**Why it's bad:** Tests pass against perfect mocks but fail with real services. Integration issues hidden.

**How to fix:** Include integration tests with real or test services:
```javascript
describe('User API', () => {
  // Unit tests with mocks
  it('parses user response', async () => {
    const mockFetch = jest.fn().mockResolvedValue(...);
  });

  // Integration test with real service
  it('fetches user from real API', async () => {
    const user = await fetchUserData(123);
    expect(user).toHaveProperty('id');
    expect(user).toHaveProperty('name');
  });
});
```

---

## Logic Smells

### Inverted Logic

**Pattern:** Using double negatives or inverted boolean logic
```javascript
if (!isDisabled) { ... }
if (!isEmpty && !isCancelled) { ... }

# Python
if not is_not_found:
    process()
```

**Why it's bad:** Hard to understand. Easy to get wrong. Cognitive overload.

**How to fix:** Use positive assertions:
```javascript
if (isEnabled) { ... }
if (hasContent && !isCancelled) { ... }

# Python
if is_found:
    process()
```

### Switch Statements Without Defaults

**Pattern:** Switch with missing default case
```javascript
switch (userRole) {
  case 'admin':
    return adminPanel();
  case 'user':
    return userDashboard();
  // What about other roles?
}
```

**Why it's bad:** Unexpected cases silently fail. No error indication.

**How to fix:** Always include default:
```javascript
switch (userRole) {
  case 'admin':
    return adminPanel();
  case 'user':
    return userDashboard();
  default:
    throw new Error(`Unknown role: ${userRole}`);
}
```

---

## Performance Smells

### N+1 Query Problem

**Pattern:** Looping through items and fetching data for each
```javascript
async function getUsersWithPosts(userIds) {
  const users = [];
  for (const userId of userIds) {
    const user = await db.users.find(userId);           // Query 1
    user.posts = await db.posts.find({ userId });       // Query N
    users.push(user);
  }
  return users; // N+1 queries!
}
```

**Why it's bad:** Massive performance hit. 1000 users = 1001 queries instead of 2.

**How to fix:** Batch queries:
```javascript
async function getUsersWithPosts(userIds) {
  const users = await db.users.find({ id: { $in: userIds } });
  const posts = await db.posts.find({ userId: { $in: userIds } });

  const postsByUserId = groupBy(posts, 'userId');
  return users.map(user => ({
    ...user,
    posts: postsByUserId[user.id] || []
  }));
}
```

### Inefficient Loops

**Pattern:** Unnecessary processing in loops
```javascript
// Recalculating same value in loop
for (const user of users) {
  const config = loadConfig(); // Loaded N times!
  process(user, config);
}

// Array operations in loop
for (const item of items) {
  if (list.includes(item.id)) { // O(N) lookup per iteration!
    process(item);
  }
}
```

**Why it's bad:** Unnecessary CPU usage, slower execution, poor scaling.

**How to fix:** Move outside loop or use efficient data structures:
```javascript
const config = loadConfig(); // Load once
for (const user of users) {
  process(user, config);
}

const idSet = new Set(list.map(x => x.id)); // O(1) lookup
for (const item of items) {
  if (idSet.has(item.id)) {
    process(item);
  }
}
```

---

## Documentation Smells

### Missing or Misleading Comments

**Pattern:** No documentation for complex logic
```javascript
function processData(d, m, a) {
  // What are d, m, a?
  return d.map(x => x * m + a);
}
```

**Why it's bad:** Code intent unclear. Maintainers must reverse-engineer logic.

**How to fix:** Add meaningful comments and clear names:
```javascript
/**
 * Applies linear transformation to dataset
 * @param data Array of values to transform
 * @param multiplier Scale factor
 * @param offset Additive term
 * @returns Transformed values
 */
function transformData(data, multiplier, offset) {
  return data.map(value => value * multiplier + offset);
}
```

### Outdated Comments

**Pattern:** Comments that no longer match code
```javascript
// This is the old algorithm - DO NOT MODIFY
// Performance improved 10x with new approach
const result = newAndFastAlgorithm();

// Cache results for 5 minutes
// Actually caches for 1 hour now
const cache = new Map();
```

**Why it's bad:** Comments mislead. Developers make wrong assumptions.

**How to fix:** Keep comments current or remove if obvious:
```javascript
// Uses optimized algorithm: https://github.com/org/issue/123
const result = fastAlgorithm();

// Cache persists for 1 hour (TTL_MS = 3600000)
const cache = new Map();
```

---

## Quick Detection Checklist

Scan for these patterns when auditing:

- **Error handling**: Empty catch blocks, console.log, catch-all handlers
- **Hardcoding**: Magic numbers, hardcoded URLs, hardcoded credentials
- **Stubs**: Return fake data, TODO implementations, unfinished features
- **Logic**: Double negatives, missing defaults, inverted conditions
- **Performance**: N+1 queries, unnecessary loops, inefficient data structures
- **Tests**: Only mocks, no integration tests, overmocking
- **Documentation**: Missing comments on complex logic, outdated comments
- **Configuration**: Environment settings in code instead of config/env
