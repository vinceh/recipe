# Industry Standards for Production-Ready Code

This guide defines what production-ready, industry-standard code looks like across key dimensions.

## Code Organization and Structure

### Module Organization

**Standard:**
- Clear separation of concerns (one module = one responsibility)
- Logical file/folder structure matching functionality
- Not too deep or too shallow
- Related functionality grouped together

**Good Example:**
```
src/
├── auth/
│   ├── authenticate.ts
│   ├── tokens.ts
│   └── permissions.ts
├── users/
│   ├── create.ts
│   ├── update.ts
│   └── queries.ts
├── shared/
│   ├── validators.ts
│   └── types.ts
└── middleware/
    └── auth-middleware.ts
```

**Bad Example:**
```
src/
├── service1.ts       # What does this do?
├── helpers.ts        # Too generic
├── utils.ts          # Not descriptive
├── data.ts           # Vague
└── big-file.ts       # 5000 lines
```

### Component/Function Size

**Standards:**
- Functions: 20-50 lines (rarely exceed 100)
- Classes/Components: 200-300 lines
- Files: <500 lines (preferably <300)
- If larger, break into smaller pieces

**Why:** Easier to understand, test, modify, reuse

---

## Error Handling Standards

### Explicit Error Handling

**Required for:**
- Network calls (API, database, file I/O)
- User input validation
- External service integrations
- Async operations
- Operations that can fail

**Standard Approach:**

```javascript
// GOOD: Comprehensive error handling
async function fetchUserData(userId) {
  // Validate input
  if (!userId || typeof userId !== 'number') {
    throw new ValidationError('Invalid user ID');
  }

  try {
    const response = await fetch(`/api/users/${userId}`);

    // Check HTTP status
    if (!response.ok) {
      if (response.status === 404) {
        throw new NotFoundError('User not found');
      }
      throw new APIError(`API error: ${response.statusText}`, response.status);
    }

    // Parse and validate response
    const data = await response.json();
    if (!data.id || !data.email) {
      throw new DataError('Invalid response structure');
    }

    return data;

  } catch (error) {
    // Log with context
    logger.error('Failed to fetch user', {
      userId,
      error: error.message,
      timestamp: new Date(),
    });

    // Re-throw or handle appropriately
    if (error instanceof ValidationError) {
      throw error;  // Expected error, propagate
    }

    throw new Error(`Failed to fetch user data: ${error.message}`);
  }
}

// BAD: Insufficient error handling
async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  return response.json();  // No validation, no error handling
}
```

### Error Logging Standards

**Must include:**
- Error message
- Relevant context (IDs, input values, timestamps)
- Error type/stack trace
- Environment information if relevant

**Good logging:**
```javascript
logger.error('Payment processing failed', {
  orderId: order.id,
  amount: order.amount,
  gatewayError: error.message,
  errorCode: error.code,
  timestamp: new Date().toISOString(),
  attemptNumber: retryCount,
});
```

**Bad logging:**
```javascript
console.log('Error');  // No context
console.log(error);    // Stack trace only
logger.error(JSON.stringify(error));  // Not structured
```

### Custom Error Types

**Standard Practice:**
```javascript
// Define custom error types
class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NotFoundError extends Error {
  constructor(message) {
    super(message);
    this.name = 'NotFoundError';
    this.statusCode = 404;
  }
}

// Use in code
if (!data.email) {
  throw new ValidationError('Email is required');
}

if (!user) {
  throw new NotFoundError('User not found');
}
```

---

## Security Standards

### No Hardcoded Secrets

**Required:**
- Use environment variables for all secrets
- Use configuration management systems
- Rotate secrets regularly
- Different secrets per environment

**Bad:**
```javascript
const apiKey = 'sk_live_abc123def456';  // Never hardcode!
const dbPassword = 'admin123';
const jwtSecret = 'super-secret-key';
```

**Good:**
```javascript
const apiKey = process.env.API_KEY;
const dbPassword = process.env.DB_PASSWORD;
const jwtSecret = process.env.JWT_SECRET;

// With defaults (only for test/dev)
const port = process.env.PORT || 3000;
```

### Input Validation

**Required for:**
- All user input
- API parameters
- Database queries (prevent SQL injection)
- File uploads
- URLs and redirects

**Standards:**
```javascript
// GOOD: Comprehensive validation
function createUser(userData) {
  // Validate presence
  if (!userData.email || !userData.password) {
    throw new ValidationError('Email and password required');
  }

  // Validate format
  if (!isValidEmail(userData.email)) {
    throw new ValidationError('Invalid email format');
  }

  // Validate constraints
  if (userData.password.length < 8) {
    throw new ValidationError('Password must be 8+ characters');
  }

  // Sanitize input
  const sanitized = {
    email: userData.email.toLowerCase().trim(),
    password: userData.password,
    name: sanitizeHTML(userData.name),  // Remove XSS vectors
  };

  return sanitized;
}

// BAD: No validation
function createUser(userData) {
  return db.save(userData);  // What if userData is malicious?
}
```

### Secure Authentication

**Standards:**
- Hash passwords (never store plaintext)
- Use HTTPS for auth endpoints
- Implement rate limiting on login
- Use secure session management
- Implement CSRF protection for forms
- Use secure token generation

---

## Documentation Standards

### Code Comments

**Required for:**
- Complex algorithms or business logic
- Non-obvious implementation choices
- Public API/function contracts
- Important edge cases or gotchas

**Good comments:**
```javascript
/**
 * Processes user orders in batches to avoid memory overload
 * and reduce database load. Batch size is configurable.
 * @param {User} user - User whose orders to process
 * @param {number} batchSize - Orders per batch (default 100)
 * @returns {Promise<ProcessResult>} Result with counts and errors
 */
async function processUserOrders(user, batchSize = 100) {
  // Implementation
}

// This is a workaround for a race condition in the cache layer
// See: https://github.com/org/repo/issues/456
// Remove this guard when cache library is updated to v2.0
if (cacheVersion < 2.0) {
  await cache.invalidate();
}
```

**Bad comments:**
```javascript
// Loop through users
for (const user of users) {

// Increment counter
i++;

// Check if user exists
if (user) {
```

### README and API Documentation

**Required:**
- How to set up and run the project
- How to run tests
- Main modules and their purposes
- Configuration instructions
- Known issues or limitations
- Public API/endpoint documentation

---

## Version Control Standards

### Commit Message Standards

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Good examples:**
```
feat(auth): implement JWT token refresh

Add automatic token refresh mechanism to prevent
session expiration during active use. Includes
new refresh endpoint and background task.

Fixes #123

test(payments): add integration tests for payment processing
```

**Bad examples:**
```
fixed bug
update code
changes
asdfghjkl
```

### PR/Code Review Standards

**Required:**
- Clear description of changes
- Why the change was made (not just what)
- Link to issues/tickets
- Review before merge
- Tests must pass
- Meaningful commit history

---

## Performance Standards

### Performance Budgets

**Typical Standards:**
- Page load: <2s (fast), <5s (acceptable)
- API response: <200ms (fast), <1s (acceptable)
- Database query: <100ms (fast), <1s (acceptable)
- Memory usage: <100MB for typical app
- Bundle size: <200KB gzipped (initial)

### Database Query Standards

**Required:**
- Indexes on frequently searched fields
- Avoid N+1 queries
- Pagination for large datasets
- Query optimization verified
- Connection pooling for performance

**Bad:**
```javascript
// N+1 problem
for (const order of orders) {
  const items = await db.query('SELECT * FROM items WHERE order_id = ?', order.id);
}
```

**Good:**
```javascript
// Batch query
const orders = await db.query('SELECT * FROM orders WHERE user_id = ?', userId);
const items = await db.query('SELECT * FROM items WHERE order_id IN (?)',
  orders.map(o => o.id));
```

---

## Code Style Standards

### Language-Specific Standards

**JavaScript/TypeScript:**
- Use strict mode
- Use const/let (not var)
- Use async/await (not .then())
- Use arrow functions where appropriate
- Use template literals
- Use destructuring

**Python:**
- Follow PEP 8
- Use type hints
- Use context managers (with statements)
- Use list comprehensions appropriately
- Use docstrings

**General:**
- 2-4 space indentation (consistency matters)
- Meaningful variable names
- No abbreviations unless universal
- Consistent naming (camelCase, snake_case, etc.)

### Linting and Formatting

**Standards:**
- ESLint for JavaScript
- Black or Autopep8 for Python
- Prettier for code formatting
- Git hooks to enforce before commit

---

## Production Readiness Checklist

Before code goes to production, verify:

### Functionality ✅
- [ ] All requirements implemented
- [ ] No TODO/FIXME comments
- [ ] No hardcoded values
- [ ] No stub/placeholder code
- [ ] Edge cases handled
- [ ] Error cases handled

### Testing ✅
- [ ] Unit tests written
- [ ] Integration tests written
- [ ] All tests pass
- [ ] No skipped tests
- [ ] Test coverage >70% (meaningful)
- [ ] Critical paths at 100%

### Code Quality ✅
- [ ] Follows code style guide
- [ ] Passes linting
- [ ] No obvious smells or anti-patterns
- [ ] Meaningful variable/function names
- [ ] Reasonable function sizes
- [ ] DRY (Don't Repeat Yourself)

### Security ✅
- [ ] No hardcoded secrets
- [ ] Input validated
- [ ] Output escaped where needed
- [ ] Sensitive operations logged
- [ ] Rate limiting on auth
- [ ] HTTPS enforced

### Performance ✅
- [ ] Meets performance budgets
- [ ] No N+1 queries
- [ ] Appropriate caching
- [ ] Load testing done if needed
- [ ] Memory leaks addressed
- [ ] Reasonable bundle size

### Documentation ✅
- [ ] Complex logic documented
- [ ] Public APIs documented
- [ ] Setup instructions clear
- [ ] Known issues documented
- [ ] Configuration documented
- [ ] Deployment process documented

### Maintainability ✅
- [ ] Clear error messages
- [ ] Proper logging
- [ ] Monitoring/alerts configured
- [ ] Rollback plan exists
- [ ] Code review completed
- [ ] No technical debt TODO list

---

## Reference Standards

**Code Quality Tools:**
- SonarQube, CodeClimate for overall quality
- ESLint, Black for style consistency
- Prettier for formatting
- Dependabot for dependency updates

**Standards Bodies:**
- OWASP for security
- WCAG for accessibility
- ISO/IEC 27001 for security practices

**Industry Guidelines:**
- Code Complete (McConnell)
- Clean Code (Martin)
- Pragmatic Programmer (Hunt & Thomas)
