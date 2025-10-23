# Detecting Incomplete Work and Shortcuts

This guide identifies patterns that indicate work is incomplete, deferred, or taken as a shortcut. These are "cheating" indicators that code is not production-ready.

## Explicit Deferral Markers

### TODO/FIXME/HACK Comments

**What to look for:**
```javascript
// TODO: implement user validation
function validateUser(user) {
  return true; // Placeholder
}

// FIXME: This is slow, optimize later
function processItems(items) {
  return items.map(x => x); // Does nothing
}

// HACK: Temporary solution
let globalConfig = {};

// XXX: This will break if...
function calculatePrice(items) {
  return items.length * 100;
}

# Python examples
# TODO: Add proper error handling
def fetch_user(user_id):
    return {'id': user_id, 'name': 'Unknown'}

# HACK: Waiting for API to be ready
def get_weather():
    return {'temperature': 72, 'forecast': 'sunny'}
```

**Severity:** CRITICAL - Indicates deferred implementation

**What to check:**
- Search codebase for: `TODO|FIXME|HACK|XXX|KLUDGE|TEMP|PLACEHOLDER|WILL FIX`
- Verify each marker has corresponding implementation or task ticket
- If in production code: CRITICAL issue

---

### Future Work Indicators

**What to look for:**
```javascript
// Placeholder for future enhancement
function getRecommendations(user) {
  return [];
}

// Will implement in next sprint
async function syncDatabase() {
  // Not implemented yet
}

// Stub - replace with real implementation
function authenticateUser(username, password) {
  return username === 'admin' && password === 'test';
}

// Temporary until we refactor this
const hardcodedConfig = {
  apiUrl: 'http://localhost:3000',
  timeout: 5000
};

# Python
def generate_report():
    """This function will be fully implemented later."""
    return None

def process_payment(amount):
    # Stub implementation - will complete after API is ready
    return {'status': 'pending'}
```

**Severity:** CRITICAL - Indicates unfinished implementation

**What to check:**
- Look for comments with: "will implement", "future", "to be done", "not yet", "temporary", "placeholder"
- Check if functionality is stubbed (returns dummy data, None, empty list)
- Verify against original requirements - is this supposed to be implemented?

---

### Comments Indicating Work in Progress

**What to look for:**
```javascript
// Currently working on optimizing this function
function calculateStats(data) {
  // Unoptimized version here
}

// This is WIP - don't use yet
export function newFeature() {
  // Incomplete implementation
}

// Still debugging this
const userCache = new Map();

// UNDER CONSTRUCTION - DO NOT USE
async function newPaymentSystem() {
  // ...
}

# Python
def process_order():
    # In progress - being refactored
    pass

# Still testing
def validate_email(email):
    return '@' in email  # Too simplistic
```

**Severity:** CRITICAL if in production code; HIGH if in feature branches

**What to check:**
- Comments saying "WIP", "working on", "debugging", "refactoring"
- Functions that are empty or clearly incomplete
- Code marked "under construction" or "do not use"

---

## Incomplete Implementation Patterns

### Stub/Placeholder Returns

**What to look for:**
```javascript
// Returns fake/placeholder data
async function fetchUserProfile(userId) {
  return {
    id: userId,
    name: 'Test User',
    email: 'test@example.com',
    // Real implementation needed here
  };
}

function getAvailablePaymentMethods(user) {
  // TODO: Actually fetch from backend
  return ['credit-card', 'paypal'];
}

// Stub that always succeeds
async function processPayment(amount) {
  console.log('Processing $' + amount);
  return { success: true };
}

# Python
def get_user_permissions(user_id):
    # Placeholder - will connect to DB later
    return ['read', 'write']

def calculate_tax(amount):
    # Stub
    return amount * 0.08  # Wrong rate, hardcoded
```

**Severity:** CRITICAL - Feature doesn't actually work

**What to check:**
- Functions that return hardcoded/fake data instead of computing/fetching
- No actual API calls or database queries
- Comments indicating "implement later"
- Test the actual functionality - does it work or just look right?

---

### Empty Implementations

**What to look for:**
```javascript
// Function does nothing
function validateInput(data) {
  // Not implemented
}

// Returns immediately
function setupCache() {
  return;
}

// No actual logic
function logUserAction(action) {
  // Will implement later
}

async function connectToDatabase() {
  // TODO: actual connection
}

# Python
def apply_business_logic(data):
    return data  # No transformation

def cache_result(key, value):
    # Not implemented yet
    pass

def validate_schema(obj):
    # Placeholder
    return True
```

**Severity:** CRITICAL - Function doesn't do its job

**What to check:**
- Functions with no real code, just comments
- Functions that pass through input unchanged
- Functions that return placeholder values
- Run tests - do they actually test behavior or just call the function?

---

### Hardcoded Validation/Business Logic

**What to look for:**
```javascript
// Hardcoded business logic that should be configurable/dynamic
function checkPermission(user, action) {
  return user.role === 'admin'; // Always requires admin
}

function calculateDiscount(userType) {
  if (userType === 'premium') return 0.2;
  if (userType === 'enterprise') return 0.3;
  // No other logic, new types break
}

function validateOrderAmount(amount) {
  return amount >= 100 && amount <= 5000; // Arbitrary limits
}

# Python
def get_user_limit(user_id):
    return 1000  # Hardcoded instead of fetching from config

def is_admin(user):
    return user['email'].endswith('@company.com')  # Too specific
```

**Severity:** MAJOR - Not scalable, breaks with new requirements

**What to check:**
- Hardcoded business rules that should be flexible
- Hardcoded limits, thresholds, or configuration values
- Rules that don't match actual requirements

---

## Missing Implementation Indicators

### Edge Cases Not Handled

**What to look for:**
```javascript
// No null/undefined checks
function getUserName(user) {
  return user.profile.name;  // Crashes if user or profile is null
}

// No empty input handling
function sumArray(arr) {
  return arr.reduce((a, b) => a + b);  // Fails on empty array
}

// No error path
function parseJSON(str) {
  return JSON.parse(str);  // Throws on invalid JSON
}

// Success path only
async function submitForm(data) {
  await api.submit(data);  // No error handling
  return { success: true };
}

# Python
def get_first_item(items):
    return items[0]  # Fails on empty list

def divide(a, b):
    return a / b  # Division by zero not handled

def find_user(users, id):
    for user in users:
        if user['id'] == id:
            return user
    # No handling for not found
```

**Severity:** CRITICAL - Application crashes on edge cases

**What to check:**
- Functions without null/undefined checks
- Functions without empty input handling
- Functions with no error path (only success case)
- Missing validation of inputs
- No handling for not-found scenarios

---

### Incomplete Error Handling

**What to look for:**
```javascript
// Only handles happy path
async function fetchData(url) {
  const response = await fetch(url);
  return response.json();  // What if network fails? What if JSON is invalid?
}

// No specific error handling
try {
  complexOperation();
} catch (e) {
  // Silent failure or generic message
}

// Success case only
function openFile(path) {
  const file = readFileSync(path);
  return file;  // What if file doesn't exist? Permissions?
}

# Python
def save_user(user):
    db.save(user)  # What if DB is down?
    return 'saved'

def fetch_from_api(endpoint):
    response = requests.get(endpoint)
    return response.json()  # No timeout, no error handling
```

**Severity:** CRITICAL - Silent failures, crashes

**What to check:**
- No error handling for external calls (APIs, databases, file I/O)
- Missing timeout handling
- No retry logic for transient failures
- Success path only, no error path

---

### Missing Test Cases

**What to look for:**
```javascript
// Tests only happy path
test('should save user', async () => {
  const result = await saveUser(validUser);
  expect(result).toBe('saved');
});
// Missing:
// - Invalid user
// - Duplicate user
// - Database down
// - Network error

// No error case tests
test('fetch data returns data', async () => {
  mockFetch.mockResolvedValue(data);
  const result = await fetch();
  expect(result).toBe(data);
});
// Missing error scenarios!

// Only unit tests with mocks
// No integration tests to verify real behavior
```

**Severity:** CRITICAL - Real functionality untested

**What to check:**
- Only happy path tested
- No error case tests
- No edge case tests
- Mocks used but no integration tests
- Test success - do they verify actual behavior?

---

### Performance Not Considered

**What to look for:**
```javascript
// No pagination
function getAllUsers() {
  return db.users.find();  // Loads all users into memory
}

// No caching
async function getUserById(id) {
  return api.get(`/users/${id}`);  // Makes request every time
}

// Inefficient queries
const users = db.users.find();
const user = users.find(u => u.id === searchId);  // Loads all to find one

// No rate limiting
async function sendEmails(recipients) {
  for (const email of recipients) {
    await emailService.send(email);  // All at once, might overload
  }
}

# Python
def process_all_orders():
    orders = db.query('SELECT * FROM orders')  # Memory explosion
    for order in orders:
        process(order)

def get_recommendations(user_id):
    users = db.get_all_users()  # O(N) to find one user's recommendations
    return [u for u in users if u['friends'] include user_id]
```

**Severity:** MAJOR - Works but doesn't scale

**What to check:**
- No pagination for large datasets
- No caching where needed
- Inefficient queries (loading all to find subset)
- No batch processing for bulk operations
- No rate limiting for external calls

---

## Detection Checklist

Use this checklist when auditing for incomplete work:

### Deferral Indicators
- [ ] Search for: `TODO|FIXME|HACK|XXX|KLUDGE`
- [ ] Search for: "will implement", "future", "not yet", "placeholder", "temporary"
- [ ] Check for "WIP", "under construction", "in progress" comments
- [ ] Look for functions marked "do not use"

### Implementation Completeness
- [ ] Functions returning hardcoded/fake data instead of real computation
- [ ] Functions that are empty or pass through unchanged
- [ ] Business logic that's hardcoded instead of configurable
- [ ] No edge case handling (null, empty, errors)
- [ ] Success path only, no error handling

### Requirements Verification
- [ ] Does code match original task description?
- [ ] Are all acceptance criteria actually implemented?
- [ ] Are error scenarios from requirements handled?
- [ ] Are performance requirements met?

### Testing Verification
- [ ] Happy path tested?
- [ ] Error cases tested?
- [ ] Edge cases tested?
- [ ] Integration tests present (not just mocks)?
- [ ] Tests actually pass?

---

## What Constitutes "Complete"

Work is complete and production-ready when:

✅ All requirements from task are implemented
✅ No TODO/FIXME comments in code
✅ Functions do actual work, not stubs
✅ Edge cases handled
✅ Error cases handled
✅ Tests exist and pass
✅ No hardcoded values that should be configurable
✅ Performance acceptable for expected scale
✅ Code follows standards and patterns
✅ Security considerations addressed
✅ Documentation clear where needed
