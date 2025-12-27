# Guardrail Analysis Patterns

Detailed patterns for analyzing codebase compliance with TarkaFlow guardrails.

## Security Guardrails

### Authentication & Authorization

**Patterns to Check:**
- Middleware/decorator usage for protected routes
- Role-based access control implementation
- Session management patterns
- JWT/token validation

**Code Patterns to Search:**
```
# Auth decorators/middleware
grep -r "@authenticated" --include="*.py"
grep -r "requireAuth" --include="*.ts" --include="*.js"
grep -r "authorize" --include="*.cs"

# Unprotected routes
grep -r "app.get\|app.post" --include="*.ts" | grep -v "auth"
```

**Red Flags:**
- Routes without authentication checks
- Hardcoded credentials
- Disabled security middleware in production paths
- Missing CSRF protection

### Input Validation

**Patterns to Check:**
- Schema validation (Pydantic, Zod, JSON Schema)
- SQL query construction
- User input sanitization
- File upload handling

**Code Patterns to Search:**
```
# SQL injection risks
grep -r "execute.*%s" --include="*.py"
grep -r "f\".*SELECT" --include="*.py"
grep -rE "\$\{.*\}.*query" --include="*.ts"

# Missing validation
grep -r "request.body" --include="*.ts" | grep -v "validate\|schema"
```

**Red Flags:**
- String concatenation in SQL queries
- Missing input sanitization
- File uploads without type/size validation
- Unvalidated redirects

### Secrets Management

**Patterns to Check:**
- Environment variable usage
- Config file handling
- Secret storage patterns

**Code Patterns to Search:**
```
# Hardcoded secrets
grep -rE "(password|secret|api_key|token)\s*=\s*['\"]" --include="*.py" --include="*.ts"
grep -r "Bearer " --include="*.py" --include="*.ts" | grep -v "config\|env"

# .env file patterns
grep -r "dotenv\|load_env" --include="*.py" --include="*.ts"
```

**Red Flags:**
- Hardcoded passwords/API keys
- Secrets in git history
- Unencrypted secret storage
- Secrets logged to console

## Architecture Guardrails

### Layer Boundaries

**Patterns to Check:**
- Clean separation between layers (presentation, business, data)
- Dependency direction (outer layers depend on inner)
- No circular dependencies

**Code Patterns to Search:**
```
# Cross-layer imports
grep -r "from.*repository" --include="*.py" | grep "controller\|route\|api"
grep -r "import.*database" --include="*.ts" | grep "component\|view"
```

**Red Flags:**
- UI components directly accessing database
- Business logic in controllers
- Data access in presentation layer
- Circular imports between modules

### Dependency Management

**Patterns to Check:**
- Dependency injection usage
- Interface/abstraction over implementation
- Third-party library isolation

**Code Patterns to Search:**
```
# Direct instantiation (should use DI)
grep -r "new.*Repository\|new.*Service" --include="*.ts" --include="*.py"

# Interface usage
grep -r "interface\|abstract\|Protocol" --include="*.ts" --include="*.py"
```

**Red Flags:**
- Tight coupling to concrete implementations
- Missing abstractions for external services
- Global state usage
- Singleton anti-patterns

### API Design

**Patterns to Check:**
- RESTful conventions
- Consistent error handling
- Versioning strategy
- Rate limiting

**Code Patterns to Search:**
```
# Inconsistent endpoints
grep -r "router\.\|app\." --include="*.ts" --include="*.py" | grep -E "(get|post|put|delete)"

# Error handling
grep -r "throw\|raise\|Exception" --include="*.ts" --include="*.py"
```

**Red Flags:**
- Inconsistent URL patterns
- Missing error responses
- No API versioning
- Unhandled exceptions

## Business Rule Guardrails

### Domain Logic Placement

**Patterns to Check:**
- Business rules in domain layer
- No business logic in controllers
- Validation in appropriate layer

**Code Patterns to Search:**
```
# Business logic in controllers
grep -r "if.*then\|switch\|when" --include="*controller*.ts" --include="*controller*.py"

# Domain model methods
grep -r "class.*Entity\|class.*Model" --include="*.ts" --include="*.py"
```

**Red Flags:**
- Complex conditionals in API handlers
- Business calculations in UI components
- Validation rules scattered across layers
- Missing domain events

### Audit & Compliance

**Patterns to Check:**
- Action logging
- Data change tracking
- Compliance field handling (PII, GDPR)

**Code Patterns to Search:**
```
# Logging patterns
grep -r "logger\.\|log\.\|console\." --include="*.ts" --include="*.py"

# Audit trails
grep -r "audit\|tracking\|history" --include="*.ts" --include="*.py"
```

**Red Flags:**
- Missing audit logs for sensitive operations
- PII logged without masking
- No data retention policies
- Missing consent tracking

## Violation Severity Classification

### Critical
- Security vulnerabilities exploitable in production
- Data exposure risks
- Authentication bypass possibilities
- Secrets in codebase

### Major
- Significant architecture violations
- Missing required validations
- Incomplete error handling
- Performance anti-patterns

### Minor
- Style/convention violations
- Non-critical missing abstractions
- Documentation gaps
- Minor code organization issues
