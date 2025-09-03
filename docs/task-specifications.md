# Task Specifications

## Phase 1: Foundation

### Task 1: Create repository structure and initialize Git
**Objective**: Establish the base repository with proper directory structure and version control.

**Implementation**:
- Initialize git repository with main branch
- Create comprehensive .gitignore for Python, Node.js, Terraform, and IDEs
- Set up directory structure:
  ```
  ├── backend/
  ├── frontend/
  ├── infrastructure/
  ├── docker/
  ├── .github/
  ├── docs/
  └── .memory-bank/
  ```

**Testing**: 
- Verify git initialization: `git status`
- Confirm .gitignore excludes appropriate files
- Validate directory structure exists

**CI/CD Considerations**:
- Ensure .gitignore includes CI/CD artifacts
- Add .github/workflows directory for future workflows

**Acceptance Criteria**:
- [ ] Git repository initialized
- [ ] .gitignore covers all necessary patterns
- [ ] Directory structure created
- [ ] Initial commit made

---

### Task 2: Set up project documentation structure
**Objective**: Create foundational documentation files with templates.

**Implementation**:
- Create README.md with project overview
- Create CLAUDE.md with AI assistant instructions
- Add LICENSE file (MIT)
- Create docs/ subdirectories:
  - architecture/
  - deployment/
  - api/
  - contributing/

**Testing**:
- Verify all documentation files exist
- Check markdown syntax validity
- Ensure templates have proper structure

**CI/CD Considerations**:
- Add markdown linting to future CI pipeline
- Include documentation generation steps

**Acceptance Criteria**:
- [ ] README.md created with sections
- [ ] CLAUDE.md contains development guidelines
- [ ] LICENSE file added
- [ ] Documentation structure established

---

### Task 3: Initialize Memory Bank with project context
**Objective**: Set up Memory Bank for tracking project context and decisions.

**Implementation**:
- Create .memory-bank/ directory
- Initialize memory bank files:
  - product-context.md
  - active-context.md
  - progress.md
  - decision-log.md
  - system-patterns.md
- Add initial project context

**Testing**:
- Verify Memory Bank initialization
- Check all files are created
- Validate MCP server connectivity

**CI/CD Considerations**:
- Exclude .memory-bank from Docker images
- Include in repository for context sharing

**Acceptance Criteria**:
- [ ] Memory Bank initialized
- [ ] All context files created
- [ ] Initial project context documented
- [ ] MCP server can access Memory Bank

---

## Phase 2: Backend Setup

### Task 4: Create backend directory and initialize Python project with uv
**Objective**: Set up Python project with modern tooling using uv package manager.

**Implementation**:
- Install uv if not present
- Create backend/ directory structure:
  ```
  backend/
  ├── app/
  ├── tests/
  ├── scripts/
  └── pyproject.toml
  ```
- Initialize Python project with uv
- Configure pyproject.toml with project metadata
- Create virtual environment

**Testing**:
- Run `uv venv` successfully
- Verify Python version (3.11+)
- Check pyproject.toml validity

**CI/CD Considerations**:
- Cache uv dependencies in CI
- Use consistent Python version
- Add dependency scanning

**Acceptance Criteria**:
- [ ] backend/ directory created
- [ ] uv project initialized
- [ ] pyproject.toml configured
- [ ] Virtual environment created

---

### Task 5: Install FastAPI core dependencies
**Objective**: Install and configure essential backend dependencies.

**Implementation**:
- Install core packages:
  ```toml
  fastapi = "^0.109.0"
  uvicorn = {extras = ["standard"], version = "^0.27.0"}
  pydantic = "^2.5.0"
  pydantic-settings = "^2.1.0"
  loguru = "^0.7.2"
  python-dotenv = "^1.0.0"
  ```
- Install dev dependencies:
  ```toml
  pytest = "^7.4.0"
  pytest-asyncio = "^0.23.0"
  pytest-cov = "^4.1.0"
  black = "^24.1.0"
  ruff = "^0.2.0"
  mypy = "^1.8.0"
  ```

**Testing**:
- Verify package installation: `uv pip list`
- Check import statements work
- Run basic FastAPI app

**CI/CD Considerations**:
- Lock dependencies with uv
- Add security scanning for dependencies
- Cache installation in CI

**Acceptance Criteria**:
- [ ] All core dependencies installed
- [ ] Dev dependencies installed
- [ ] Import statements work
- [ ] Dependencies locked

---

### Task 6: Create FastAPI application structure
**Objective**: Establish modular, scalable application architecture.

**Implementation**:
Create structure:
```
backend/app/
├── __init__.py
├── main.py
├── core/
│   ├── config.py
│   ├── security.py
│   └── logging.py
├── api/
│   ├── __init__.py
│   ├── deps.py
│   └── v1/
│       ├── __init__.py
│       └── endpoints/
├── models/
│   └── __init__.py
├── schemas/
│   └── __init__.py
├── services/
│   └── __init__.py
└── utils/
    └── __init__.py
```

**Testing**:
- Verify module imports work
- Check circular dependencies
- Run app with `uvicorn app.main:app`

**CI/CD Considerations**:
- Add import sorting checks
- Include structure validation

**Acceptance Criteria**:
- [ ] Complete directory structure created
- [ ] All __init__.py files in place
- [ ] Main FastAPI app instantiated
- [ ] Modular architecture established

---

### Task 7: Implement basic health check endpoint
**Objective**: Create health endpoint for monitoring and connectivity testing.

**Implementation**:
```python
# app/api/v1/endpoints/health.py
from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class HealthResponse(BaseModel):
    status: str
    timestamp: datetime
    version: str
    service: str

@router.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        timestamp=datetime.utcnow(),
        version="0.1.0",
        service="backend"
    )
```

**Testing**:
- GET /health returns 200
- Response matches schema
- Endpoint accessible without auth

**CI/CD Considerations**:
- Use health endpoint in Docker health checks
- Monitor in deployment

**Acceptance Criteria**:
- [ ] Health endpoint implemented
- [ ] Returns proper response
- [ ] Pydantic model validated
- [ ] Accessible at /api/v1/health

---

### Task 8: Set up backend configuration management
**Objective**: Implement environment-based configuration with validation.

**Implementation**:
```python
# app/core/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    app_name: str = "FastAPI Reference"
    environment: str = "development"
    debug: bool = True
    api_v1_prefix: str = "/api/v1"
    backend_cors_origins: list[str] = ["http://localhost:3000"]
    
    database_url: str = "sqlite:///./app.db"
    secret_key: str = "development-secret-key"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings():
    return Settings()
```

**Testing**:
- Verify env var loading
- Test configuration validation
- Check different environments

**CI/CD Considerations**:
- Use different .env files per environment
- Inject secrets in CI/CD
- Validate configuration on startup

**Acceptance Criteria**:
- [ ] Settings class created
- [ ] Environment variables loaded
- [ ] Configuration validated
- [ ] Cached settings function

---

## Phase 3: Frontend Setup

### Task 9: Create frontend directory and initialize Next.js with TypeScript
**Objective**: Set up modern React frontend with Next.js and TypeScript.

**Implementation**:
```bash
pnpm create next-app@latest frontend --typescript --tailwind --app --src-dir --import-alias "@/*"
```
Configure:
- TypeScript strict mode
- Path aliases
- ESLint and Prettier

**Testing**:
- Run `pnpm dev` successfully
- Build without errors: `pnpm build`
- TypeScript compilation works

**CI/CD Considerations**:
- Cache node_modules
- Add type checking to CI
- Include bundle size checks

**Acceptance Criteria**:
- [ ] Next.js app created
- [ ] TypeScript configured
- [ ] Development server runs
- [ ] Build succeeds

---

### Task 10: Set up pnpm and install frontend core dependencies
**Objective**: Configure pnpm and install essential frontend packages.

**Implementation**:
Install packages:
```json
{
  "dependencies": {
    "zod": "^3.22.0",
    "pino": "^8.17.0",
    "pino-pretty": "^10.3.0",
    "@tanstack/react-query": "^5.17.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "jest": "^29.7.0",
    "@testing-library/react": "^14.1.0",
    "cypress": "^13.6.0"
  }
}
```

**Testing**:
- Verify installations: `pnpm list`
- Check import statements
- Run type checking

**CI/CD Considerations**:
- Use pnpm in CI/CD
- Lock file committed
- Cache pnpm store

**Acceptance Criteria**:
- [ ] pnpm configured
- [ ] Core dependencies installed
- [ ] Dev dependencies installed
- [ ] Lock file created

---

### Task 11: Create frontend project structure
**Objective**: Establish scalable frontend architecture.

**Implementation**:
```
frontend/src/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   └── api/
├── components/
│   ├── ui/
│   └── features/
├── services/
│   ├── api.ts
│   └── types.ts
├── hooks/
├── utils/
├── lib/
└── types/
```

**Testing**:
- Verify imports work
- Check component rendering
- Validate structure

**CI/CD Considerations**:
- Add structure linting
- Include import rules

**Acceptance Criteria**:
- [ ] Directory structure created
- [ ] Base components added
- [ ] Services configured
- [ ] Types defined

---

### Task 12: Build basic layout and home page
**Objective**: Create foundational UI components and layout.

**Implementation**:
- Create RootLayout with navigation
- Build HomePage component
- Add responsive design with Tailwind
- Include dark mode support

**Testing**:
- Visual regression tests
- Responsive design checks
- Accessibility testing

**CI/CD Considerations**:
- Add Lighthouse CI
- Include visual regression

**Acceptance Criteria**:
- [ ] Layout component created
- [ ] Navigation implemented
- [ ] Home page displays
- [ ] Responsive design works

---

### Task 13: Create frontend service to call backend health endpoint
**Objective**: Establish backend connectivity from frontend.

**Implementation**:
```typescript
// services/api.ts
import axios from 'axios';
import { z } from 'zod';

const healthSchema = z.object({
  status: z.string(),
  timestamp: z.string(),
  version: z.string(),
  service: z.string()
});

export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
});

export const checkHealth = async () => {
  const response = await api.get('/api/v1/health');
  return healthSchema.parse(response.data);
};
```

**Testing**:
- Mock API calls in tests
- Test error handling
- Validate schema parsing

**CI/CD Considerations**:
- Environment-specific API URLs
- Add API mocking for tests

**Acceptance Criteria**:
- [ ] API service created
- [ ] Health check works
- [ ] Zod validation implemented
- [ ] Error handling added

---

## Phase 4: Containerization

### Task 14: Create Dockerfile for backend with multi-stage build
**Objective**: Build optimized backend container image.

**Implementation**:
```dockerfile
# docker/Dockerfile.backend
FROM python:3.11-slim as builder
WORKDIR /app
COPY backend/pyproject.toml backend/uv.lock ./
RUN pip install uv && uv pip install --system .

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY backend/app ./app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Testing**:
- Build image successfully
- Run container
- Health check passes

**CI/CD Considerations**:
- Layer caching
- Security scanning
- Size optimization

**Acceptance Criteria**:
- [ ] Dockerfile created
- [ ] Multi-stage build works
- [ ] Image size < 200MB
- [ ] Container runs successfully

---

### Task 15: Create Dockerfile for frontend with multi-stage build
**Objective**: Build optimized frontend container image.

**Implementation**:
```dockerfile
# docker/Dockerfile.frontend
FROM node:20-alpine as builder
WORKDIR /app
COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY frontend/ .
RUN pnpm build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./
RUN npm install -g pnpm && pnpm install --production
CMD ["pnpm", "start"]
```

**Testing**:
- Build image successfully
- Run container
- Access application

**CI/CD Considerations**:
- Next.js standalone mode
- Static asset optimization
- Build caching

**Acceptance Criteria**:
- [ ] Dockerfile created
- [ ] Multi-stage build works
- [ ] Image size optimized
- [ ] Container serves app

---

### Task 16: Set up docker-compose.yml for local development
**Objective**: Configure multi-container development environment.

**Implementation**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/appdb
    volumes:
      - ./backend:/app
    depends_on:
      - db

  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000
    volumes:
      - ./frontend:/app

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=appdb
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Testing**:
- `docker-compose up` works
- Services communicate
- Hot reload works

**CI/CD Considerations**:
- Use docker-compose in CI
- Test container orchestration

**Acceptance Criteria**:
- [ ] docker-compose.yml created
- [ ] All services defined
- [ ] Networking configured
- [ ] Volumes mounted

---

### Task 17: Configure Docker networking and environment variables
**Objective**: Set up proper container communication and configuration.

**Implementation**:
- Create custom network
- Configure service discovery
- Set up .env files:
  - .env.development
  - .env.production
  - .env.test
- Add environment validation

**Testing**:
- Services can communicate
- Environment variables loaded
- Network isolation works

**CI/CD Considerations**:
- Different configs per environment
- Secret injection
- Network security

**Acceptance Criteria**:
- [ ] Custom network created
- [ ] Services communicate
- [ ] Env vars configured
- [ ] Secrets managed

---

### Task 18: Test end-to-end connectivity between containers
**Objective**: Validate full stack communication.

**Implementation**:
- Create integration test script
- Test health endpoint from frontend
- Verify database connectivity
- Check service discovery

**Testing**:
```bash
# Test script
curl http://localhost:8000/api/v1/health
curl http://localhost:3000
docker exec frontend curl http://backend:8000/api/v1/health
```

**CI/CD Considerations**:
- Add to CI pipeline
- Health check validation
- Smoke tests

**Acceptance Criteria**:
- [ ] Frontend accesses backend
- [ ] Backend connects to database
- [ ] Health checks pass
- [ ] No CORS issues

---

## Phase 5: Core Features

### Task 19: Design sample domain model (Todo/Task entity)
**Objective**: Create domain model for demonstration purposes.

**Implementation**:
```python
# backend/app/models/todo.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func

class Todo(Base):
    __tablename__ = "todos"
    
    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    description = Column(String)
    completed = Column(Boolean, default=False)
    priority = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

**Testing**:
- Model creation works
- Relationships validated
- Migrations run

**CI/CD Considerations**:
- Database migrations in CI
- Schema validation

**Acceptance Criteria**:
- [ ] Domain model designed
- [ ] Database schema created
- [ ] Relationships defined
- [ ] Migrations work

---

### Task 20: Create Pydantic models for request/response validation
**Objective**: Implement strong typing and validation for API.

**Implementation**:
```python
# backend/app/schemas/todo.py
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class TodoBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    completed: bool = False
    priority: int = Field(0, ge=0, le=5)

class TodoCreate(TodoBase):
    pass

class TodoUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    completed: Optional[bool] = None
    priority: Optional[int] = Field(None, ge=0, le=5)

class TodoInDB(TodoBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True

class TodoResponse(TodoInDB):
    pass
```

**Testing**:
- Validation works correctly
- Serialization/deserialization
- Error messages clear

**CI/CD Considerations**:
- Schema generation for docs
- Validation testing

**Acceptance Criteria**:
- [ ] Request models created
- [ ] Response models created
- [ ] Validation rules added
- [ ] Documentation generated

---

### Task 21: Implement CRUD REST endpoints
**Objective**: Create full CRUD operations for Todo entity.

**Implementation**:
```python
# backend/app/api/v1/endpoints/todos.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List

router = APIRouter()

@router.get("/", response_model=List[TodoResponse])
async def get_todos(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    todos = db.query(Todo).offset(skip).limit(limit).all()
    return todos

@router.post("/", response_model=TodoResponse, status_code=201)
async def create_todo(
    todo: TodoCreate,
    db: Session = Depends(get_db)
):
    db_todo = Todo(**todo.dict())
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@router.get("/{todo_id}", response_model=TodoResponse)
async def get_todo(
    todo_id: int,
    db: Session = Depends(get_db)
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@router.patch("/{todo_id}", response_model=TodoResponse)
async def update_todo(
    todo_id: int,
    todo_update: TodoUpdate,
    db: Session = Depends(get_db)
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    update_data = todo_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(todo, field, value)
    
    db.commit()
    db.refresh(todo)
    return todo

@router.delete("/{todo_id}", status_code=204)
async def delete_todo(
    todo_id: int,
    db: Session = Depends(get_db)
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db.delete(todo)
    db.commit()
    return None
```

**Testing**:
- All CRUD operations work
- Error handling correct
- Status codes appropriate

**CI/CD Considerations**:
- API testing in CI
- Performance testing

**Acceptance Criteria**:
- [ ] GET /todos works
- [ ] POST /todos creates
- [ ] GET /todos/{id} retrieves
- [ ] PATCH /todos/{id} updates
- [ ] DELETE /todos/{id} removes

---

### Task 22: Add database integration (SQLAlchemy)
**Objective**: Set up database layer with ORM.

**Implementation**:
```python
# backend/app/core/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import get_settings

settings = get_settings()

engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

**Testing**:
- Database connection works
- Migrations run
- CRUD operations succeed

**CI/CD Considerations**:
- Test database in CI
- Migration automation
- Database seeding

**Acceptance Criteria**:
- [ ] SQLAlchemy configured
- [ ] Database connection works
- [ ] Session management
- [ ] Migrations set up

---

### Task 23: Implement SSE streaming endpoint for real-time updates
**Objective**: Add Server-Sent Events for real-time communication.

**Implementation**:
```python
# backend/app/api/v1/endpoints/stream.py
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
import asyncio
import json

router = APIRouter()

async def event_generator():
    while True:
        # Simulate real-time updates
        data = {
            "event": "todo_update",
            "data": {"message": "Todo updated", "timestamp": datetime.utcnow().isoformat()}
        }
        yield f"data: {json.dumps(data)}\n\n"
        await asyncio.sleep(5)

@router.get("/stream")
async def stream_events():
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream"
    )
```

**Testing**:
- SSE connection established
- Events received
- Connection stays alive

**CI/CD Considerations**:
- Test streaming endpoints
- Load testing

**Acceptance Criteria**:
- [ ] SSE endpoint created
- [ ] Events stream correctly
- [ ] Client can subscribe
- [ ] Connection persistent

---

### Task 24: Create frontend components for CRUD operations
**Objective**: Build React components for Todo management.

**Implementation**:
```typescript
// frontend/src/components/features/TodoList.tsx
import { useQuery, useMutation } from '@tanstack/react-query';
import { getTodos, createTodo, updateTodo, deleteTodo } from '@/services/api';

export function TodoList() {
  const { data: todos, isLoading } = useQuery({
    queryKey: ['todos'],
    queryFn: getTodos
  });

  const createMutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => queryClient.invalidateQueries(['todos'])
  });

  // Component implementation
}
```

**Testing**:
- Component renders
- CRUD operations work
- State management correct

**CI/CD Considerations**:
- Component testing
- Visual regression

**Acceptance Criteria**:
- [ ] Todo list displays
- [ ] Create todo works
- [ ] Update todo works
- [ ] Delete todo works

---

### Task 25: Add Zod schemas for frontend validation
**Objective**: Implement client-side validation matching backend.

**Implementation**:
```typescript
// frontend/src/schemas/todo.ts
import { z } from 'zod';

export const todoSchema = z.object({
  id: z.number(),
  title: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  completed: z.boolean(),
  priority: z.number().min(0).max(5),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime().optional()
});

export const createTodoSchema = todoSchema.omit({
  id: true,
  created_at: true,
  updated_at: true
});

export type Todo = z.infer<typeof todoSchema>;
export type CreateTodo = z.infer<typeof createTodoSchema>;
```

**Testing**:
- Validation works
- Error messages display
- Type inference correct

**CI/CD Considerations**:
- Type checking in CI
- Schema synchronization

**Acceptance Criteria**:
- [ ] Zod schemas created
- [ ] Validation works
- [ ] Types generated
- [ ] Errors handled

---

### Task 26: Build forms with client-side validation
**Objective**: Create user-friendly forms with validation feedback.

**Implementation**:
```typescript
// frontend/src/components/features/TodoForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { createTodoSchema } from '@/schemas/todo';

export function TodoForm({ onSubmit }) {
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm({
    resolver: zodResolver(createTodoSchema)
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {/* Form fields with validation */}
    </form>
  );
}
```

**Testing**:
- Form validation works
- Error messages display
- Submission successful

**CI/CD Considerations**:
- Form testing
- Accessibility checks

**Acceptance Criteria**:
- [ ] Form component created
- [ ] Validation integrated
- [ ] Error display works
- [ ] Form submits correctly

---

### Task 27: Implement SSE client for streaming updates
**Objective**: Connect frontend to backend SSE stream.

**Implementation**:
```typescript
// frontend/src/hooks/useEventStream.ts
import { useEffect, useState } from 'react';

export function useEventStream(url: string) {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    const eventSource = new EventSource(url);

    eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setEvents(prev => [...prev, data]);
    };

    return () => eventSource.close();
  }, [url]);

  return events;
}
```

**Testing**:
- SSE connection works
- Events received
- Cleanup on unmount

**CI/CD Considerations**:
- Mock SSE in tests
- Connection resilience

**Acceptance Criteria**:
- [ ] SSE client created
- [ ] Events received
- [ ] Real-time updates work
- [ ] Connection managed

---

## Phase 6: Testing

### Task 28: Set up pytest with coverage for backend
**Objective**: Configure comprehensive backend testing framework.

**Implementation**:
```toml
# backend/pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["app"]
omit = ["*/tests/*", "*/migrations/*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError"
]
```

**Testing**:
- pytest runs successfully
- Coverage reports generated
- Async tests work

**CI/CD Considerations**:
- Coverage thresholds
- Test reports in CI

**Acceptance Criteria**:
- [ ] pytest configured
- [ ] Coverage setup
- [ ] Test discovery works
- [ ] Reports generated

---

### Task 29: Write unit tests for API endpoints
**Objective**: Test all API endpoints thoroughly.

**Implementation**:
```python
# backend/tests/test_todos.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_todo():
    response = client.post(
        "/api/v1/todos/",
        json={"title": "Test Todo", "description": "Test"}
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Test Todo"

def test_get_todos():
    response = client.get("/api/v1/todos/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

# More tests...
```

**Testing**:
- All endpoints tested
- Edge cases covered
- Error scenarios tested

**CI/CD Considerations**:
- Run on every PR
- Fail fast on errors

**Acceptance Criteria**:
- [ ] All endpoints tested
- [ ] >80% coverage
- [ ] Edge cases covered
- [ ] Tests pass

---

### Task 30: Create integration tests for database operations
**Objective**: Test database layer and transactions.

**Implementation**:
```python
# backend/tests/test_integration.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture
def test_db():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(bind=engine)
    
    yield SessionLocal()
    
    Base.metadata.drop_all(bind=engine)

def test_todo_crud(test_db):
    # Test CRUD operations
    todo = Todo(title="Test")
    test_db.add(todo)
    test_db.commit()
    
    assert todo.id is not None
    # More assertions...
```

**Testing**:
- Database operations work
- Transactions tested
- Rollbacks work

**CI/CD Considerations**:
- Test database setup
- Cleanup after tests

**Acceptance Criteria**:
- [ ] Integration tests created
- [ ] Database tested
- [ ] Transactions validated
- [ ] Tests isolated

---

### Task 31: Configure Jest for frontend unit testing
**Objective**: Set up Jest for React component testing.

**Implementation**:
```javascript
// frontend/jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts'
  ]
};
```

**Testing**:
- Jest runs successfully
- Coverage works
- Module resolution works

**CI/CD Considerations**:
- Run in CI pipeline
- Coverage reports

**Acceptance Criteria**:
- [ ] Jest configured
- [ ] Tests run
- [ ] Coverage works
- [ ] TypeScript support

---

### Task 32: Write component tests with React Testing Library
**Objective**: Test React components thoroughly.

**Implementation**:
```typescript
// frontend/src/components/__tests__/TodoList.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { TodoList } from '../TodoList';

describe('TodoList', () => {
  it('renders todos', async () => {
    render(
      <QueryClientProvider client={new QueryClient()}>
        <TodoList />
      </QueryClientProvider>
    );
    
    expect(await screen.findByText('Todos')).toBeInTheDocument();
  });
  
  // More tests...
});
```

**Testing**:
- Components render
- User interactions work
- State updates correctly

**CI/CD Considerations**:
- Component testing in CI
- Snapshot testing

**Acceptance Criteria**:
- [ ] Component tests written
- [ ] User interactions tested
- [ ] Coverage >80%
- [ ] Tests pass

---

### Task 33: Set up Cypress for E2E testing
**Objective**: Configure end-to-end testing framework.

**Implementation**:
```javascript
// frontend/cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.ts',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}'
  }
});
```

**Testing**:
- Cypress opens
- Tests run
- Screenshots/videos work

**CI/CD Considerations**:
- Headless mode in CI
- Artifact storage

**Acceptance Criteria**:
- [ ] Cypress configured
- [ ] E2E tests run
- [ ] CI integration works
- [ ] Reports generated

---

### Task 34: Create E2E test scenarios
**Objective**: Write comprehensive end-to-end tests.

**Implementation**:
```typescript
// frontend/cypress/e2e/todos.cy.ts
describe('Todo Management', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('creates a new todo', () => {
    cy.get('[data-testid="add-todo"]').click();
    cy.get('[name="title"]').type('New Todo');
    cy.get('[type="submit"]').click();
    cy.contains('New Todo').should('be.visible');
  });

  // More scenarios...
});
```

**Testing**:
- User flows work
- Critical paths tested
- Error scenarios handled

**CI/CD Considerations**:
- Run against staging
- Smoke tests for prod

**Acceptance Criteria**:
- [ ] E2E scenarios written
- [ ] Critical paths tested
- [ ] Tests reliable
- [ ] CI integration works

---

## Phase 7: CI/CD Pipeline

### Task 35: Create GitHub Actions workflow for testing
**Objective**: Automate testing on every push and PR.

**Implementation**:
```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: |
          pip install uv
          cd backend
          uv venv
          uv pip install -e ".[dev]"
          uv run pytest --cov

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: |
          cd frontend
          pnpm install
          pnpm test
          pnpm run test:e2e
```

**Testing**:
- Workflow triggers correctly
- Tests run successfully
- Failures reported

**CI/CD Considerations**:
- Parallel job execution
- Caching dependencies
- Fast feedback

**Acceptance Criteria**:
- [ ] Workflow created
- [ ] Tests run on PR
- [ ] Coverage reported
- [ ] Status checks work

---

### Task 36: Add workflow for building and pushing Docker images
**Objective**: Automate container image builds and registry push.

**Implementation**:
```yaml
# .github/workflows/build.yml
name: Build and Push

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: docker/setup-buildx-action@v2
      
      - uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - uses: docker/build-push-action@v4
        with:
          context: .
          file: docker/Dockerfile.backend
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/backend:latest
            ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

**Testing**:
- Images build successfully
- Push to registry works
- Tags applied correctly

**CI/CD Considerations**:
- Multi-arch builds
- Security scanning
- Image signing

**Acceptance Criteria**:
- [ ] Build workflow created
- [ ] Images pushed to registry
- [ ] Caching works
- [ ] Security scanning added

---

### Task 37: Set up Act for local CI/CD testing
**Objective**: Enable local testing of GitHub Actions workflows.

**Implementation**:
```bash
# Install act
brew install act  # or appropriate for your OS

# Create .actrc
echo "-P ubuntu-latest=catthehacker/ubuntu:act-latest" > .actrc

# Test workflows locally
act -j test
act -j build
```

**Testing**:
- Act runs workflows
- Local execution matches CI
- Secrets work locally

**CI/CD Considerations**:
- Document act usage
- Maintain parity with CI

**Acceptance Criteria**:
- [ ] Act installed
- [ ] Workflows run locally
- [ ] Documentation added
- [ ] Secrets configured

---

### Task 38: Implement semantic versioning with auto-tagging
**Objective**: Automate version management and tagging.

**Implementation**:
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - uses: paulhatch/semantic-version@v5
        id: version
        with:
          tag_prefix: "v"
          major_pattern: "(MAJOR)"
          minor_pattern: "(MINOR)"
          
      - name: Create Release
        uses: actions/create-release@v1
        with:
          tag_name: ${{ steps.version.outputs.version_tag }}
          release_name: Release ${{ steps.version.outputs.version }}
          body: Auto-generated release
```

**Testing**:
- Version bumps correctly
- Tags created
- Releases published

**CI/CD Considerations**:
- Protect main branch
- Enforce conventional commits

**Acceptance Criteria**:
- [ ] Semantic versioning works
- [ ] Auto-tagging implemented
- [ ] Releases created
- [ ] Changelog generated

---

### Task 39: Create automated release workflow with changelog
**Objective**: Generate releases with comprehensive changelogs.

**Implementation**:
```yaml
# .github/workflows/changelog.yml
name: Changelog

on:
  release:
    types: [published]

jobs:
  changelog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate Changelog
        uses: heinrichreimer/github-changelog-generator-action@v2.3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Update Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: CHANGELOG.md
```

**Testing**:
- Changelog generated
- Release notes updated
- Format correct

**CI/CD Considerations**:
- Conventional commit format
- Automated categorization

**Acceptance Criteria**:
- [ ] Changelog automation
- [ ] Release notes updated
- [ ] Categories work
- [ ] Links included

---

### Task 40: Set up branch protection and PR requirements
**Objective**: Enforce code quality and review standards.

**Implementation**:
- Configure branch protection for main:
  - Require PR reviews (1+)
  - Dismiss stale reviews
  - Require status checks
  - Require branches up to date
  - Include administrators
- Set up CODEOWNERS file
- Configure auto-merge for dependabot

**Testing**:
- Direct pushes blocked
- PR requirements enforced
- Status checks required

**CI/CD Considerations**:
- Status check enforcement
- Auto-merge for bots

**Acceptance Criteria**:
- [ ] Branch protection enabled
- [ ] Review requirements set
- [ ] Status checks required
- [ ] CODEOWNERS configured

---

## Phase 8: Infrastructure

### Task 41: Create base Terraform module structure
**Objective**: Establish reusable Terraform modules.

**Implementation**:
```hcl
# infrastructure/modules/app/main.tf
variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

module "networking" {
  source = "./networking"
  # Configuration
}

module "compute" {
  source = "./compute"
  # Configuration
}

module "database" {
  source = "./database"
  # Configuration
}
```

**Testing**:
- Terraform init works
- Plan executes
- Validation passes

**CI/CD Considerations**:
- Terraform fmt check
- Plan on PR
- Apply on merge

**Acceptance Criteria**:
- [ ] Module structure created
- [ ] Variables defined
- [ ] Outputs configured
- [ ] Documentation added

---

### Task 42: Implement AWS infrastructure (ECS/EKS, RDS, ALB)
**Objective**: Create AWS deployment configuration.

**Implementation**:
```hcl
# infrastructure/aws/main.tf
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # VPC configuration
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  # ECS cluster configuration
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"
  # RDS configuration
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  # Load balancer configuration
}
```

**Testing**:
- Infrastructure deploys
- Services accessible
- Database connects

**CI/CD Considerations**:
- Cost estimation
- Drift detection
- State management

**Acceptance Criteria**:
- [ ] AWS modules created
- [ ] ECS/EKS configured
- [ ] RDS deployed
- [ ] ALB working

---

### Task 43: Create GCP infrastructure (Cloud Run/GKE, Cloud SQL)
**Objective**: Implement GCP deployment configuration.

**Implementation**:
```hcl
# infrastructure/gcp/main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "backend" {
  name     = "${var.app_name}-backend"
  location = var.region

  template {
    spec {
      containers {
        image = var.backend_image
      }
    }
  }
}

resource "google_sql_database_instance" "main" {
  name             = "${var.app_name}-db"
  database_version = "POSTGRES_14"
  region           = var.region
  # Configuration
}
```

**Testing**:
- GCP resources created
- Cloud Run deploys
- Database accessible

**CI/CD Considerations**:
- Service account setup
- IAM policies
- Secret management

**Acceptance Criteria**:
- [ ] GCP modules created
- [ ] Cloud Run working
- [ ] Cloud SQL configured
- [ ] Networking set up

---

### Task 44: Add Digital Ocean Kubernetes configuration
**Objective**: Configure DO Kubernetes deployment.

**Implementation**:
```hcl
# infrastructure/digitalocean/main.tf
provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "main" {
  name    = "${var.app_name}-cluster"
  region  = var.region
  version = var.kubernetes_version

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "${var.app_name}-db"
  engine     = "pg"
  version    = "14"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
}
```

**Testing**:
- Cluster provisions
- Apps deploy
- Database connects

**CI/CD Considerations**:
- DO CLI integration
- Cluster autoscaling

**Acceptance Criteria**:
- [ ] DO cluster created
- [ ] Database provisioned
- [ ] Apps deployed
- [ ] Ingress configured

---

### Task 45: Create OVH cloud configuration
**Objective**: Set up OVH cloud infrastructure.

**Implementation**:
```hcl
# infrastructure/ovh/main.tf
provider "ovh" {
  endpoint = var.ovh_endpoint
}

resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.service_name
  name         = "${var.app_name}-cluster"
  region       = var.region
}

resource "ovh_cloud_project_database" "postgres" {
  service_name = var.service_name
  engine       = "postgresql"
  version      = "14"
  plan         = "essential"
  # Configuration
}
```

**Testing**:
- OVH resources created
- Kubernetes works
- Database accessible

**CI/CD Considerations**:
- OVH API keys
- Resource limits

**Acceptance Criteria**:
- [ ] OVH infrastructure defined
- [ ] Kubernetes cluster works
- [ ] Database configured
- [ ] Networking set up

---

### Task 46: Set up Docker Swarm deployment configuration
**Objective**: Configure Docker Swarm orchestration.

**Implementation**:
```yaml
# infrastructure/swarm/docker-stack.yml
version: '3.8'

services:
  backend:
    image: ${BACKEND_IMAGE}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    networks:
      - app-network

  frontend:
    image: ${FRONTEND_IMAGE}
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - app-network

networks:
  app-network:
    driver: overlay
```

**Testing**:
- Stack deploys
- Services scale
- Updates work

**CI/CD Considerations**:
- Rolling updates
- Health checks
- Secret management

**Acceptance Criteria**:
- [ ] Swarm stack created
- [ ] Services configured
- [ ] Scaling works
- [ ] Networks set up

---

### Task 47: Create Kubernetes manifests (deployments, services, ingress)
**Objective**: Define Kubernetes resources for deployment.

**Implementation**:
```yaml
# infrastructure/k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 80
```

**Testing**:
- Manifests apply
- Pods running
- Services accessible

**CI/CD Considerations**:
- GitOps deployment
- Manifest validation

**Acceptance Criteria**:
- [ ] Deployments created
- [ ] Services configured
- [ ] Ingress working
- [ ] ConfigMaps/Secrets set

---

### Task 48: Configure Traefik for load balancing and routing
**Objective**: Set up Traefik as ingress controller and load balancer.

**Implementation**:
```yaml
# infrastructure/traefik/values.yaml
deployment:
  enabled: true
  replicas: 3

service:
  type: LoadBalancer

ports:
  web:
    port: 80
  websecure:
    port: 443

ingressRoute:
  dashboard:
    enabled: true

providers:
  kubernetesCRD:
    enabled: true
  kubernetesIngress:
    enabled: true

ssl:
  enabled: true
  enforced: true

metrics:
  prometheus:
    enabled: true
```

**Testing**:
- Traefik deploys
- Routing works
- SSL termination
- Metrics exposed

**CI/CD Considerations**:
- Certificate management
- Auto-scaling

**Acceptance Criteria**:
- [ ] Traefik installed
- [ ] Routes configured
- [ ] SSL working
- [ ] Dashboard accessible

---

### Task 49: Set up Helm charts for Kubernetes deployment
**Objective**: Create Helm charts for application deployment.

**Implementation**:
```yaml
# helm/app/Chart.yaml
apiVersion: v2
name: fullstack-app
description: FastAPI + Next.js Reference App
type: application
version: 0.1.0
appVersion: "1.0.0"

# helm/app/values.yaml
backend:
  image:
    repository: backend
    tag: latest
  replicas: 3
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

frontend:
  image:
    repository: frontend
    tag: latest
  replicas: 3

postgresql:
  enabled: true
  auth:
    database: appdb

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: api.example.com
      paths:
        - path: /
          pathType: Prefix
```

**Testing**:
- Helm install works
- Values override correctly
- Upgrades work

**CI/CD Considerations**:
- Chart versioning
- Dependency management
- Release management

**Acceptance Criteria**:
- [ ] Helm chart created
- [ ] Templates work
- [ ] Values configurable
- [ ] Dependencies managed

---

## Phase 9: Observability

### Task 50: Integrate Loguru in backend with structured logging
**Objective**: Implement comprehensive logging in backend.

**Implementation**:
```python
# backend/app/core/logging.py
from loguru import logger
import sys
import json

def setup_logging(level: str = "INFO"):
    logger.remove()
    logger.add(
        sys.stdout,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {name}:{function}:{line} | {message}",
        level=level,
        serialize=True
    )
    
    # Add file logging
    logger.add(
        "logs/app.log",
        rotation="500 MB",
        retention="10 days",
        level="DEBUG"
    )
    
    return logger

# Usage in endpoints
@router.post("/todos")
async def create_todo(todo: TodoCreate):
    logger.info(f"Creating todo: {todo.title}")
    # Implementation
    logger.success(f"Todo created with id: {db_todo.id}")
```

**Testing**:
- Logs generated correctly
- Structured format works
- Rotation works

**CI/CD Considerations**:
- Log aggregation
- Volume management

**Acceptance Criteria**:
- [ ] Loguru integrated
- [ ] Structured logging
- [ ] File rotation works
- [ ] Context preserved

---

### Task 51: Set up Pino in frontend with structured logging
**Objective**: Implement structured logging in frontend.

**Implementation**:
```typescript
// frontend/src/lib/logger.ts
import pino from 'pino';

const logger = pino({
  browser: {
    transmit: {
      level: 'info',
      send: function (level, logEvent) {
        if (process.env.NODE_ENV === 'production') {
          // Send to logging service
          fetch('/api/logs', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(logEvent)
          });
        }
      }
    }
  },
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug'
});

export default logger;

// Usage
logger.info({ userId: user.id }, 'User logged in');
```

**Testing**:
- Browser logging works
- Server-side logging
- Log levels correct

**CI/CD Considerations**:
- Log shipping
- Privacy compliance

**Acceptance Criteria**:
- [ ] Pino integrated
- [ ] Browser logging works
- [ ] Server logging works
- [ ] Structured format

---

### Task 52: Implement OpenTelemetry tracing
**Objective**: Add distributed tracing across services.

**Implementation**:
```python
# backend/app/core/tracing.py
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

def setup_tracing(app):
    trace.set_tracer_provider(TracerProvider())
    tracer = trace.get_tracer(__name__)
    
    otlp_exporter = OTLPSpanExporter(
        endpoint="http://otel-collector:4317",
        insecure=True
    )
    
    span_processor = BatchSpanProcessor(otlp_exporter)
    trace.get_tracer_provider().add_span_processor(span_processor)
    
    FastAPIInstrumentor.instrument_app(app)
    
    return tracer
```

**Testing**:
- Traces generated
- Spans connected
- Context propagated

**CI/CD Considerations**:
- Collector deployment
- Sampling strategy

**Acceptance Criteria**:
- [ ] OTEL configured
- [ ] Traces generated
- [ ] Context propagation
- [ ] Collector working

---

### Task 53: Add Prometheus metrics endpoints
**Objective**: Expose application metrics for monitoring.

**Implementation**:
```python
# backend/app/core/metrics.py
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import Response

request_count = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])
request_duration = Histogram('app_request_duration_seconds', 'Request duration')

@router.get("/metrics")
async def metrics():
    return Response(
        content=generate_latest(),
        media_type="text/plain"
    )

# Middleware for metrics
@app.middleware("http")
async def track_metrics(request, call_next):
    with request_duration.time():
        response = await call_next(request)
    request_count.labels(
        method=request.method,
        endpoint=request.url.path
    ).inc()
    return response
```

**Testing**:
- Metrics exposed
- Counters increment
- Histograms work

**CI/CD Considerations**:
- Scraping configuration
- Alert rules

**Acceptance Criteria**:
- [ ] Metrics endpoint created
- [ ] Custom metrics added
- [ ] Prometheus format
- [ ] Scraping works

---

### Task 54: Create health check and readiness endpoints
**Objective**: Implement proper health monitoring endpoints.

**Implementation**:
```python
# backend/app/api/v1/endpoints/health.py
from fastapi import APIRouter, status
from sqlalchemy import text

router = APIRouter()

@router.get("/health/live")
async def liveness():
    """Kubernetes liveness probe"""
    return {"status": "alive"}

@router.get("/health/ready")
async def readiness(db: Session = Depends(get_db)):
    """Kubernetes readiness probe"""
    try:
        # Check database
        db.execute(text("SELECT 1"))
        
        # Check external services
        # ...
        
        return {"status": "ready"}
    except Exception as e:
        logger.error(f"Readiness check failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Service not ready"
        )

@router.get("/health/startup")
async def startup():
    """Kubernetes startup probe"""
    # Check initialization
    if not app.state.initialized:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Service starting"
        )
    return {"status": "started"}
```

**Testing**:
- Probes return correctly
- Failure scenarios work
- K8s integration works

**CI/CD Considerations**:
- Probe configuration
- Timeout settings

**Acceptance Criteria**:
- [ ] Liveness probe works
- [ ] Readiness probe works
- [ ] Startup probe works
- [ ] K8s configured

---

### Task 55: Configure centralized log aggregation
**Objective**: Set up log collection and aggregation system.

**Implementation**:
```yaml
# infrastructure/logging/fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      <parse>
        @type json
      </parse>
    </source>
    
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    
    <match **>
      @type elasticsearch
      host elasticsearch.elastic-system
      port 9200
      logstash_format true
      logstash_prefix kubernetes
    </match>
```

**Testing**:
- Logs collected
- Aggregation works
- Search functional

**CI/CD Considerations**:
- Log retention
- Storage management

**Acceptance Criteria**:
- [ ] Log collector deployed
- [ ] Aggregation working
- [ ] Search interface available
- [ ] Retention configured

---

## Phase 10: Security & Configuration

### Task 56: Set up GitHub Secrets for sensitive configuration
**Objective**: Configure secure secret management in GitHub.

**Implementation**:
- Create repository secrets:
  - DATABASE_URL
  - JWT_SECRET_KEY
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - DOCKER_REGISTRY_TOKEN
- Create environment secrets:
  - Production
  - Staging
  - Development
- Document secret rotation process

**Testing**:
- Secrets accessible in workflows
- Environment isolation works
- Rotation process documented

**CI/CD Considerations**:
- Secret scanning
- Rotation automation

**Acceptance Criteria**:
- [ ] Repository secrets created
- [ ] Environment secrets set
- [ ] Documentation complete
- [ ] Access controls configured

---

### Task 57: Implement secret injection in CI/CD pipelines
**Objective**: Securely inject secrets into build and deployment processes.

**Implementation**:
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to ECS
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          JWT_SECRET_KEY: ${{ secrets.JWT_SECRET_KEY }}
        run: |
          # Deployment script with secrets
```

**Testing**:
- Secrets injected correctly
- No secrets in logs
- Environment isolation

**CI/CD Considerations**:
- Secret masking
- Audit logging

**Acceptance Criteria**:
- [ ] Secret injection works
- [ ] No secret leaks
- [ ] Environment-specific
- [ ] Audit trail exists

---

### Task 58: Create environment-specific configuration management
**Objective**: Implement configuration management across environments.

**Implementation**:
```python
# backend/app/core/config.py
from pydantic import BaseSettings, validator
from typing import Optional
import os

class Settings(BaseSettings):
    environment: str = os.getenv("ENVIRONMENT", "development")
    
    # Database
    database_url: str
    database_pool_size: int = 5
    
    # Security
    secret_key: str
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # External Services
    redis_url: Optional[str] = None
    elasticsearch_url: Optional[str] = None
    
    @validator("database_url")
    def validate_database_url(cls, v, values):
        env = values.get("environment")
        if env == "production" and "sqlite" in v:
            raise ValueError("SQLite not allowed in production")
        return v
    
    class Config:
        env_file = f".env.{os.getenv('ENVIRONMENT', 'development')}"
```

**Testing**:
- Environment configs load
- Validation works
- Overrides function

**CI/CD Considerations**:
- Config validation in CI
- Environment promotion

**Acceptance Criteria**:
- [ ] Multi-env config works
- [ ] Validation implemented
- [ ] Override capability
- [ ] Documentation complete

---

## Phase 11: Documentation & Polish

### Task 59: Write comprehensive README with quick start guide
**Objective**: Create user-friendly documentation for the project.

**Implementation**:
```markdown
# FastAPI + Next.js Reference Implementation

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ & pnpm
- Python 3.11+ & uv
- Make (optional)

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/org/repo.git
   cd repo
   ```

2. Start services:
   ```bash
   docker-compose up
   ```

3. Access applications:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8000
   - API Docs: http://localhost:8000/docs

### Development Commands

Backend:
- `cd backend && uv run dev` - Start development server
- `cd backend && uv run test` - Run tests
- `cd backend && uv run lint` - Lint code

Frontend:
- `cd frontend && pnpm dev` - Start development server
- `cd frontend && pnpm test` - Run tests
- `cd frontend && pnpm build` - Build for production

[More sections...]
```

**Testing**:
- Instructions work
- Commands accurate
- Links valid

**CI/CD Considerations**:
- README validation
- Link checking

**Acceptance Criteria**:
- [ ] README comprehensive
- [ ] Quick start works
- [ ] All sections complete
- [ ] Examples provided

---

### Task 60: Document API with OpenAPI/Swagger
**Objective**: Generate comprehensive API documentation.

**Implementation**:
```python
# backend/app/main.py
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi

app = FastAPI(
    title="FastAPI Reference API",
    description="Reference implementation of FastAPI backend",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="FastAPI Reference API",
        version="1.0.0",
        description="Comprehensive API documentation",
        routes=app.routes,
    )
    
    # Add security schemes
    openapi_schema["components"]["securitySchemes"] = {
        "Bearer": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi
```

**Testing**:
- Swagger UI works
- ReDoc works
- Schema valid

**CI/CD Considerations**:
- Schema generation
- Version management

**Acceptance Criteria**:
- [ ] OpenAPI spec generated
- [ ] Swagger UI available
- [ ] ReDoc available
- [ ] Examples included

---

### Task 61: Create architecture decision records (ADRs)
**Objective**: Document key architectural decisions.

**Implementation**:
```markdown
# docs/adr/001-use-fastapi.md

# ADR-001: Use FastAPI for Backend

## Status
Accepted

## Context
We need to choose a Python web framework for our backend API.

## Decision
We will use FastAPI for the backend implementation.

## Consequences
### Positive
- Automatic API documentation
- Type hints and validation
- High performance
- Modern async support

### Negative
- Relatively new framework
- Smaller ecosystem than Django/Flask

[More ADRs...]
```

**Testing**:
- ADRs complete
- Format consistent
- Decisions justified

**CI/CD Considerations**:
- ADR template
- Review process

**Acceptance Criteria**:
- [ ] ADR template created
- [ ] Key decisions documented
- [ ] Format consistent
- [ ] Index maintained

---

### Task 62: Add contribution guidelines and code of conduct
**Objective**: Create community guidelines for contributions.

**Implementation**:
```markdown
# CONTRIBUTING.md

## How to Contribute

### Reporting Issues
1. Check existing issues
2. Create detailed bug report
3. Include reproduction steps

### Pull Requests
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit PR with description

### Development Setup
[Instructions...]

### Code Style
- Python: Black, isort, mypy
- TypeScript: Prettier, ESLint
- Commits: Conventional Commits

# CODE_OF_CONDUCT.md
[Contributor Covenant]
```

**Testing**:
- Guidelines clear
- Process works
- Templates used

**CI/CD Considerations**:
- PR template enforcement
- Automated checks

**Acceptance Criteria**:
- [ ] CONTRIBUTING.md created
- [ ] CODE_OF_CONDUCT.md added
- [ ] Guidelines clear
- [ ] Process documented

---

### Task 63: Create GitHub issue and PR templates
**Objective**: Standardize issue and PR submissions.

**Implementation**:
```markdown
# .github/ISSUE_TEMPLATE/bug_report.md
name: Bug Report
about: Create a report to help us improve

**Describe the bug**
A clear description of the bug.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g. Ubuntu 22.04]
- Browser: [e.g. Chrome 120]
- Version: [e.g. 1.0.0]

# .github/pull_request_template.md
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

**Testing**:
- Templates appear
- Fields relevant
- Process smooth

**CI/CD Considerations**:
- Template validation
- Auto-labeling

**Acceptance Criteria**:
- [ ] Issue templates created
- [ ] PR template created
- [ ] Templates appear in GitHub
- [ ] Labels configured

---

### Task 64: Write deployment and operations guide
**Objective**: Document deployment and operational procedures.

**Implementation**:
```markdown
# docs/deployment/README.md

## Deployment Guide

### Prerequisites
- Kubernetes cluster
- Helm 3+
- kubectl configured

### Production Deployment

1. **Configure Secrets**
   ```bash
   kubectl create secret generic app-secrets \
     --from-literal=database-url=$DATABASE_URL \
     --from-literal=jwt-secret=$JWT_SECRET
   ```

2. **Deploy with Helm**
   ```bash
   helm install app ./helm/app \
     --values ./helm/app/values.production.yaml \
     --namespace production
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods -n production
   kubectl get ingress -n production
   ```

### Monitoring
- Grafana: https://grafana.example.com
- Prometheus: https://prometheus.example.com
- Logs: https://kibana.example.com

### Troubleshooting
[Common issues and solutions]

### Rollback Procedure
[Step-by-step rollback]

### Scaling
[Horizontal and vertical scaling]
```

**Testing**:
- Instructions accurate
- Commands work
- Procedures tested

**CI/CD Considerations**:
- Runbook automation
- Disaster recovery

**Acceptance Criteria**:
- [ ] Deployment guide complete
- [ ] Operations procedures documented
- [ ] Troubleshooting guide added
- [ ] Monitoring documented

---

### Task 65: Final testing and validation of complete system
**Objective**: Comprehensive validation of the entire system.

**Implementation**:
- End-to-end testing checklist:
  - [ ] All services start
  - [ ] Database migrations run
  - [ ] API endpoints work
  - [ ] Frontend loads
  - [ ] Authentication works
  - [ ] CRUD operations succeed
  - [ ] SSE streaming works
  - [ ] Docker builds succeed
  - [ ] Kubernetes deployment works
  - [ ] CI/CD pipelines pass
  - [ ] Monitoring active
  - [ ] Logs aggregated
  - [ ] Documentation complete

**Testing**:
- Full system test
- Performance validation
- Security scan
- Accessibility check

**CI/CD Considerations**:
- Smoke tests
- Performance benchmarks
- Security scanning

**Acceptance Criteria**:
- [ ] All features working
- [ ] Tests passing (>80% coverage)
- [ ] Documentation complete
- [ ] Production ready
- [ ] Reference quality achieved