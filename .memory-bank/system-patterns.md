# System Patterns

## Overview
This document defines the coding patterns, conventions, and architectural patterns used throughout the project.

## Code Style Conventions

### Python (Backend)
```python
# File naming: snake_case.py
# Class naming: PascalCase
# Function/variable naming: snake_case
# Constants: UPPER_SNAKE_CASE

# Example structure
from typing import Optional, List
from pydantic import BaseModel

class UserResponse(BaseModel):
    """User response model with Pydantic validation."""
    id: int
    username: str
    email: str
    is_active: bool = True

async def get_user_by_id(user_id: int) -> Optional[UserResponse]:
    """Fetch user by ID with async pattern."""
    # Implementation
    pass
```

### TypeScript (Frontend)
```typescript
// File naming: PascalCase.tsx for components, camelCase.ts for utilities
// Component naming: PascalCase
// Function/variable naming: camelCase
// Constants: UPPER_SNAKE_CASE
// Types/Interfaces: PascalCase with 'I' or 'T' prefix

// Example structure
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.number(),
  username: z.string(),
  email: z.string().email(),
  isActive: z.boolean().default(true),
});

export type TUser = z.infer<typeof UserSchema>;

export const UserCard: React.FC<{ user: TUser }> = ({ user }) => {
  // Component implementation
};
```

## Architectural Patterns

### API Design Patterns

#### RESTful Endpoints
```
GET    /api/v1/users          # List users
GET    /api/v1/users/{id}     # Get user
POST   /api/v1/users          # Create user
PUT    /api/v1/users/{id}     # Update user
DELETE /api/v1/users/{id}     # Delete user
```

#### Response Format
```json
{
  "data": {},
  "meta": {
    "timestamp": "2025-01-03T00:00:00Z",
    "version": "1.0.0"
  },
  "errors": []
}
```

#### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "meta": {
    "timestamp": "2025-01-03T00:00:00Z",
    "request_id": "uuid"
  }
}
```

### Frontend Patterns

#### Component Structure
```
components/
├── common/          # Shared components
├── features/        # Feature-specific components
├── layouts/         # Layout components
└── ui/             # Pure UI components
```

#### Data Fetching Pattern
```typescript
// Using TanStack Query
export const useUser = (userId: string) => {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};
```

### Database Patterns

#### Repository Pattern
```python
class UserRepository:
    async def get(self, user_id: int) -> Optional[User]:
        pass
    
    async def create(self, user_data: dict) -> User:
        pass
    
    async def update(self, user_id: int, user_data: dict) -> User:
        pass
    
    async def delete(self, user_id: int) -> bool:
        pass
```

#### Migration Naming
```
YYYYMMDD_HHMMSS_description.py
20250103_120000_create_users_table.py
```

### Testing Patterns

#### Test File Naming
```
# Python
test_<module_name>.py
test_user_service.py

# TypeScript
<module_name>.test.ts
<module_name>.spec.ts
UserCard.test.tsx
```

#### Test Structure (AAA Pattern)
```python
def test_user_creation():
    # Arrange
    user_data = {"username": "test", "email": "test@example.com"}
    
    # Act
    user = create_user(user_data)
    
    # Assert
    assert user.username == "test"
    assert user.email == "test@example.com"
```

### Docker Patterns

#### Multi-stage Builds
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### CI/CD Patterns

#### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches
- `hotfix/*`: Emergency fixes
- `release/*`: Release preparation

#### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>

# Types: feat, fix, docs, style, refactor, test, chore
# Example: feat(auth): add JWT refresh token support
```

### Security Patterns

#### Environment Variables
```bash
# .env.example
DATABASE_URL=postgresql://user:pass@localhost/db
JWT_SECRET=your-secret-key
API_KEY=your-api-key
REDIS_URL=redis://localhost:6379
```

#### Authentication Flow
1. User provides credentials
2. Server validates and issues JWT + refresh token
3. Client stores tokens securely
4. Client includes JWT in Authorization header
5. Server validates JWT on each request
6. Client refreshes JWT when expired

### Logging Patterns

#### Log Levels
- `DEBUG`: Detailed information for debugging
- `INFO`: General informational messages
- `WARNING`: Warning messages for potential issues
- `ERROR`: Error messages for failures
- `CRITICAL`: Critical failures requiring immediate attention

#### Log Format
```json
{
  "timestamp": "2025-01-03T00:00:00Z",
  "level": "INFO",
  "message": "User logged in",
  "context": {
    "user_id": "123",
    "ip": "192.168.1.1",
    "user_agent": "Mozilla/5.0"
  },
  "correlation_id": "uuid",
  "service": "api"
}
```

### Performance Patterns

#### Caching Strategy
- **Redis**: Session data, frequently accessed data
- **CDN**: Static assets, images
- **Browser**: HTTP cache headers
- **Application**: In-memory caching for hot data

#### Database Optimization
- Use indexes for frequently queried columns
- Implement pagination for large datasets
- Use connection pooling
- Optimize N+1 queries
- Use read replicas for read-heavy operations

### Monitoring Patterns

#### Health Checks
```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "version": "1.0.0",
        "checks": {
            "database": "ok",
            "redis": "ok",
            "disk_space": "ok"
        }
    }
```

#### Metrics to Track
- Request rate and latency
- Error rate and types
- Database query performance
- Cache hit/miss ratio
- Memory and CPU usage
- Active user sessions

## File Organization

### Backend Structure
```
backend/
├── app/
│   ├── api/           # API endpoints
│   ├── core/          # Core configuration
│   ├── crud/          # CRUD operations
│   ├── db/            # Database config
│   ├── models/        # SQLAlchemy models
│   ├── schemas/       # Pydantic schemas
│   ├── services/      # Business logic
│   └── utils/         # Utilities
├── tests/
├── alembic/           # Database migrations
└── scripts/           # Utility scripts
```

### Frontend Structure
```
frontend/
├── src/
│   ├── app/           # Next.js app directory
│   ├── components/    # React components
│   ├── hooks/         # Custom hooks
│   ├── lib/           # Libraries and utilities
│   ├── services/      # API services
│   ├── store/         # State management
│   ├── styles/        # Global styles
│   └── types/         # TypeScript types
├── public/            # Static assets
└── tests/            # Test files
```

## Code Review Checklist

- [ ] Code follows style conventions
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No sensitive data in code
- [ ] Error handling is implemented
- [ ] Performance implications considered
- [ ] Security best practices followed
- [ ] Accessibility requirements met
- [ ] Internationalization supported
- [ ] Logging is appropriate