# Flask Application - Implementation Plan

This document outlines the architectural decisions, design principles, and implementation roadmap for the Webinar Registration Application as specified in the [BRD](./BRD.md) and [PRD](./PRD.md).

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Implementation Roadmap](#implementation-roadmap)
3. [Architectural Overview](#architectural-overview)
4. [Design Principles Applied](#design-principles-applied)
5. [Architectural Patterns](#architectural-patterns)
6. [Phase 1: Architectural Foundation](#phase-1-architectural-foundation)
7. [Phase 2: Walking Skeleton](#phase-2-walking-skeleton)
8. [Directory Structure](#directory-structure)
9. [Future Phases](#future-phases)

---

## Executive Summary

### Project Context

This application implements the Webinar Registration Website requested by the Marketing Department (see [BRD](./BRD.md)). The implementation follows a phased approach, establishing solid architectural foundations before adding business functionality.

### Implementation Philosophy

> **"Architecture First, Features Second"**

Rather than rushing to implement features, we first establish a well-structured three-tier architecture. This approach ensures:

- Clean separation of concerns from the start
- Easy addition of features without refactoring
- Testable code at every stage
- Educational clarity for understanding application structure

### Current Status

| Phase | Status | Description |
|-------|--------|-------------|
| **Phase 1** | ✅ Complete | Architectural Foundation |
| **Phase 2** | ✅ Complete | Walking Skeleton |
| **Phase 3** | ✅ Complete | Full Feature Implementation |
| **Phase 4** | 🔲 Future | Authentication & Security |

---

## Implementation Roadmap

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        IMPLEMENTATION ROADMAP                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 1: ARCHITECTURAL FOUNDATION (Complete)                               │
│  ──────────────────────────────────────────────                             │
│  • Three-tier architecture (Models, Services, Routes)                       │
│  • Application factory pattern                                              │
│  • Blueprint structure                                                      │
│  • Database migrations (Flask-Migrate)                                      │
│  • Test infrastructure                                                      │
│  • Generic Entry model (placeholder)                                        │
│                                                                             │
│                              ↓                                              │
│                                                                             │
│  PHASE 2: WALKING SKELETON (Next)                                           │
│  ────────────────────────────────                                           │
│  • Registration model (Name, Email, Company, Job Title)                     │
│  • Landing page with call-to-action                                         │
│  • Registration form page                                                   │
│  • Thank you page (post-submission)                                         │
│  • Admin dashboard (list attendees, no auth)                                │
│                                                                             │
│                              ↓                                              │
│                                                                             │
│  PHASE 3: FULL FEATURES (Complete)                                          │
│  ───────────────────────────────                                            │
│  • Form validation with WTForms                                             │
│  • Duplicate email prevention                                               │
│  • Webinar information display (FR-001)                                     │
│  • Flash messages & error handling                                          │
│  • Admin sorting, statistics & CSV export                                   │
│  • Custom error pages (400, 404, 500)                                       │
│                                                                             │
│                              ↓                                              │
│                                                                             │
│  PHASE 4: SECURITY & PRODUCTION (Future)                                    │
│  ───────────────────────────────────────                                    │
│  • Admin authentication                                                     │
│  • HTTPS configuration                                                      │
│  • Production deployment                                                    │
│  • Monitoring & health checks                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Descriptions

| Phase | Goal | Validates |
|-------|------|-----------|
| **Phase 1** | Establish architecture before writing business logic | Structure, patterns, testability |
| **Phase 2** | Prove end-to-end flow works with minimal features | User journey, data flow, layers work together |
| **Phase 3** | Implement full PRD requirements | Business requirements satisfaction |
| **Phase 4** | Production-ready security and operations | NFRs (security, availability, monitoring) |

---

## Architectural Overview

### Three-Tier Architecture

The application follows the classic three-tier architecture pattern, separating concerns into distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                        │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   main.py       │  │    api.py       │   Blueprints     │
│  │   (Web Routes)  │  │  (JSON API)     │                  │
│  └────────┬────────┘  └────────┬────────┘                  │
└───────────┼────────────────────┼────────────────────────────┘
            │                    │
            ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              entry_service.py                        │   │
│  │   - create_entry()      - get_all_entries()         │   │
│  │   - get_recent_entries() - get_entry_count()        │   │
│  └──────────────────────────┬──────────────────────────┘   │
└─────────────────────────────┼───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   entry.py                           │   │
│  │   Entry Model (SQLAlchemy ORM)                      │   │
│  │   - id, value, created_at                           │   │
│  └──────────────────────────┬──────────────────────────┘   │
└─────────────────────────────┼───────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │    Database     │
                    │ PostgreSQL/SQLite│
                    └─────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Components |
|-------|----------------|------------|
| **Presentation** | HTTP request/response handling, routing, rendering | Blueprints, Templates |
| **Business Logic** | Domain logic, validation, orchestration | Services |
| **Data** | Persistence, ORM mapping, data integrity | Models |

---

## Design Principles Applied

### SOLID Principles

#### 1. Single Responsibility Principle (SRP)

> *"A class should have only one reason to change."*

**Application:**

| Component | Single Responsibility |
|-----------|----------------------|
| `Entry` model | Data structure and persistence mapping |
| `EntryService` | Business logic for entry operations |
| `main_bp` | Web interface routing |
| `api_bp` | JSON API routing |
| `config.py` | Application configuration |

**Before (violation):**
```python
# app.py - Multiple responsibilities in one file
@app.route('/')
def index():
    if request.method == 'POST':
        entry = Entry(value=request.form.get('value'))  # Data
        db.session.add(entry)                            # Persistence
        db.session.commit()                              # Transaction
    entries = Entry.query.order_by(...).all()            # Query
    return render_template_string(TEMPLATE, ...)         # Presentation
```

**After (SRP applied):**
```python
# routes/main.py - Only handles HTTP concerns
@main_bp.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        EntryService.create_entry(request.form.get('value'))
        return redirect(url_for('main.index'))
    entries = EntryService.get_recent_entries(limit=10)
    return render_template('index.html', entries=entries)

# services/entry_service.py - Only handles business logic
class EntryService:
    @staticmethod
    def create_entry(value):
        entry = Entry(value=value)
        db.session.add(entry)
        db.session.commit()
        return entry
```

#### 2. Open/Closed Principle (OCP)

> *"Software entities should be open for extension but closed for modification."*

**Application:**

- **Blueprint system**: New features (auth, admin) can be added as new blueprints without modifying existing code
- **Configuration classes**: New environments can be added by creating new config classes
- **Service layer**: New business logic can be added without changing routes

**Example - Adding new functionality:**
```python
# To add admin functionality, create new files (extension)
# without modifying existing routes (closed for modification)

# app/routes/admin.py (new file)
admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

# app/routes/__init__.py (minimal change - registration only)
def register_blueprints(app):
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)
    app.register_blueprint(admin_bp)  # Add new blueprint
```

#### 3. Liskov Substitution Principle (LSP)

> *"Objects of a superclass should be replaceable with objects of subclasses."*

**Application:**

- **Configuration classes**: `DevelopmentConfig`, `ProductionConfig`, and `TestingConfig` all inherit from `Config` and can be used interchangeably
- **Database abstraction**: SQLite and PostgreSQL are interchangeable through SQLAlchemy

```python
# Any config subclass can substitute the base Config
class Config:
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):  # Substitutable
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///local.db'

class ProductionConfig(Config):   # Substitutable
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
```

#### 4. Interface Segregation Principle (ISP)

> *"Clients should not be forced to depend on interfaces they do not use."*

**Application:**

- **Separate blueprints**: Web clients use `main_bp`, API clients use `api_bp`
- **Focused services**: `EntryService` only exposes entry-related methods

```python
# API clients only need api_bp endpoints
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/entries')      # JSON response
@api_bp.route('/health')       # JSON response

# Web clients only need main_bp endpoints
main_bp = Blueprint('main', __name__)

@main_bp.route('/')            # HTML response
```

#### 5. Dependency Inversion Principle (DIP)

> *"High-level modules should not depend on low-level modules. Both should depend on abstractions."*

**Application:**

- **Extensions module**: Routes depend on `db` abstraction, not specific database implementation
- **Application factory**: Components depend on Flask app abstraction, not global state

```python
# app/extensions.py - Abstractions
db = SQLAlchemy()      # Abstraction over database
migrate = Migrate()    # Abstraction over migrations

# Services depend on abstraction (db), not concrete implementation
from app.extensions import db

class EntryService:
    @staticmethod
    def create_entry(value):
        entry = Entry(value=value)
        db.session.add(entry)  # Using abstraction
        db.session.commit()
```

### Additional Design Principles

#### DRY (Don't Repeat Yourself)

**Application:**

- **Base template**: Common HTML structure defined once in `base.html`
- **Service methods**: Database operations centralized in services
- **Configuration inheritance**: Shared settings in base `Config` class

```html
<!-- templates/base.html - Defined once -->
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    {% block content %}{% endblock %}
</body>
</html>

<!-- templates/index.html - Reuses base -->
{% extends "base.html" %}
{% block content %}
    <!-- Page-specific content -->
{% endblock %}
```

#### Separation of Concerns (SoC)

**Application:**

| Concern | Location |
|---------|----------|
| Configuration | `config.py` |
| Database schema | `app/models/` |
| Business rules | `app/services/` |
| HTTP handling | `app/routes/` |
| Presentation | `app/templates/` |
| Styling | `app/static/css/` |

#### Convention over Configuration

**Application:**

- Flask's default template folder: `templates/`
- Flask's default static folder: `static/`
- Blueprint URL prefixes follow RESTful conventions
- Test discovery follows pytest conventions (`test_*.py`)

---

## Architectural Patterns

### 1. Application Factory Pattern

**Purpose:** Create application instances with different configurations.

**Benefits:**
- Testing with different configurations
- Multiple application instances
- Delayed extension initialization
- Cleaner circular import handling

```python
# app/__init__.py
def create_app(config_name='development'):
    app = Flask(__name__)
    app.config.from_object(config_map[config_name])

    db.init_app(app)
    migrate.init_app(app, db)

    register_blueprints(app)
    return app
```

**Usage:**
```python
# Production
app = create_app('production')

# Testing
app = create_app('testing')
```

### 2. Blueprint Pattern

**Purpose:** Modular route organization for scalability.

**Benefits:**
- Feature isolation
- Independent development
- URL prefix management
- Reusable components

```python
# app/routes/api.py
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/entries')
def get_entries():
    ...

# app/routes/__init__.py
def register_blueprints(app):
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)
```

### 3. Service Layer Pattern

**Purpose:** Encapsulate business logic separate from presentation.

**Benefits:**
- Testable business logic
- Reusable across different interfaces (web, API, CLI)
- Transaction management
- Domain logic isolation

```python
# app/services/entry_service.py
class EntryService:
    @staticmethod
    def create_entry(value):
        """Business logic for creating an entry."""
        entry = Entry(value=value)
        db.session.add(entry)
        db.session.commit()
        return entry
```

### 4. Repository Pattern (via SQLAlchemy)

**Purpose:** Abstract data access from business logic.

**Implementation:** SQLAlchemy models serve as repositories with query interface.

```python
# Model acts as repository
Entry.query.filter_by(id=1).first()
Entry.query.order_by(Entry.created_at.desc()).all()
```

### 5. Configuration as Code

**Purpose:** Environment-specific settings without code changes.

```python
# config.py
class Config:
    """Base configuration"""
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///local.db'

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
```

---

## Phase 1: Architectural Foundation

> **Status: ✅ COMPLETE**

### Purpose

Phase 1 establishes the architectural foundation before implementing any business features. This approach ensures we understand and validate the application structure before adding complexity.

**Key Principle:** The generic `Entry` model serves as a placeholder to prove the architecture works. It will be replaced by the `Registration` model in Phase 2.

### What Was Built

The monolithic Flask application (`app.py` - 111 lines) was refactored into a well-structured three-tier architecture:

| Aspect | Before | After |
|--------|--------|-------|
| Files | 3 | 21 |
| Architecture | Monolithic | Three-tier |
| Testability | None | 11 automated tests |
| Database migrations | Manual | Flask-Migrate/Alembic |
| Configuration | Hardcoded | Environment-based classes |
| Extensibility | Difficult | Blueprint-ready |

### Implementation Steps (All Completed)

#### Step 1.1: Core Infrastructure

| Task | Status | Files |
|------|--------|-------|
| Configuration module | ✅ | `config.py` |
| Extensions module | ✅ | `app/extensions.py` |
| Application factory | ✅ | `app/__init__.py` |

#### Step 1.2: Data Layer

| Task | Status | Files |
|------|--------|-------|
| Entry model (placeholder) | ✅ | `app/models/entry.py` |
| Model exports | ✅ | `app/models/__init__.py` |

#### Step 1.3: Business Logic Layer

| Task | Status | Files |
|------|--------|-------|
| Entry service | ✅ | `app/services/entry_service.py` |
| Service exports | ✅ | `app/services/__init__.py` |

#### Step 1.4: Presentation Layer

| Task | Status | Files |
|------|--------|-------|
| Main blueprint | ✅ | `app/routes/main.py` |
| API blueprint | ✅ | `app/routes/api.py` |
| Blueprint registration | ✅ | `app/routes/__init__.py` |
| Base template | ✅ | `app/templates/base.html` |
| Index template | ✅ | `app/templates/index.html` |
| CSS styles | ✅ | `app/static/css/style.css` |

#### Step 1.5: Development Infrastructure

| Task | Status | Files |
|------|--------|-------|
| WSGI entry point | ✅ | `wsgi.py` |
| Dependencies | ✅ | `requirements.txt` |
| Flask-Migrate | ✅ | `migrations/` |
| Initial migration | ✅ | `migrations/versions/*.py` |

#### Step 1.6: Quality Assurance

| Task | Status | Files |
|------|--------|-------|
| Test fixtures | ✅ | `tests/conftest.py` |
| Route tests | ✅ | `tests/test_routes.py` |
| Test package | ✅ | `tests/__init__.py` |

**Test Results:** 11 tests passing across 4 test classes

### Phase 1 Deliverables

- ✅ Working three-tier Flask application
- ✅ Application factory pattern
- ✅ Blueprint-based routing
- ✅ Service layer for business logic
- ✅ SQLAlchemy models with migrations
- ✅ Automated test suite
- ✅ Environment-based configuration

---

## Phase 2: Walking Skeleton

> **Status: ✅ COMPLETE**

### Purpose

Phase 2 implements a "walking skeleton" - a minimal end-to-end implementation that proves all layers work together for the real use case. The skeleton is intentionally thin: just enough to demonstrate the complete user journey.

**Walking Skeleton Pattern:** Build the thinnest possible slice of functionality that exercises all architectural layers, from UI to database, proving the architecture supports the intended features.

### User Journey

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Landing   │     │  Register   │     │  Thank You  │     │   Admin     │
│    Page     │ ──→ │    Form     │ ──→ │    Page     │     │  Dashboard  │
│             │     │             │     │             │     │             │
│ [Register]  │     │ Name        │     │ "Success!"  │     │ Attendee    │
│   button    │     │ Email       │     │             │     │ List        │
│             │     │ Company     │     │             │     │             │
│             │     │ Job Title   │     │             │     │             │
│             │     │ [Submit]    │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      GET /            GET/POST              GET                GET
                      /register          /thank-you       /admin/attendees
```

### Scope

**In Scope (Minimal):**
- Registration model with required fields
- Four pages (landing, register, thank-you, admin)
- Form submission stores data in database
- Admin page lists all registrations
- Basic styling (reuse existing CSS)

**Out of Scope (Phase 3+):**
- Form validation beyond HTML5 required
- Duplicate email prevention
- Error messages and user feedback
- Admin authentication
- Webinar information display

### Implementation Steps

#### Step 2.1: Data Layer - Registration Model

**Files to create:**
- `app/models/registration.py`

**Registration Model:**
```python
class Registration(db.Model):
    __tablename__ = 'registrations'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    company = db.Column(db.String(100), nullable=False)
    job_title = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
```

**Migration:** Generate new migration for Registration model.

#### Step 2.2: Business Logic Layer - Registration Service

**Files to create:**
- `app/services/registration_service.py`

**Service Methods:**
```python
class RegistrationService:
    @staticmethod
    def create_registration(name, email, company, job_title):
        """Create a new webinar registration."""
        ...

    @staticmethod
    def get_all_registrations():
        """Get all registrations for admin view."""
        ...

    @staticmethod
    def get_registration_count():
        """Get total count of registrations."""
        ...
```

#### Step 2.3: Presentation Layer - Public Routes

**Files to modify:**
- `app/routes/main.py`

**Routes:**

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Landing page with CTA button |
| `/register` | GET | Display registration form |
| `/register` | POST | Process form submission |
| `/thank-you` | GET | Confirmation page |

#### Step 2.4: Presentation Layer - Admin Blueprint

**Files to create:**
- `app/routes/admin.py`

**Routes:**

| Route | Method | Purpose |
|-------|--------|---------|
| `/admin/attendees` | GET | List all registrations |

**Note:** No authentication in Phase 2. Admin routes are publicly accessible (secured in Phase 4).

#### Step 2.5: Templates

**Files to create:**
- `app/templates/landing.html` - Hero section with CTA
- `app/templates/register.html` - Registration form
- `app/templates/thank_you.html` - Success confirmation
- `app/templates/admin/attendees.html` - Attendee list table

#### Step 2.6: Tests

**Files to update:**
- `tests/test_routes.py` - Add registration flow tests

**Test Cases:**
- Landing page loads
- Registration form displays
- Form submission creates registration
- Thank you page displays after submission
- Admin page lists registrations

### Phase 2 Deliverables

- ✅ Registration model and migration
- ✅ Registration service
- ✅ Landing page with call-to-action
- ✅ Registration form page
- ✅ Thank you page
- ✅ Admin attendees list
- ✅ Updated tests (39 tests passing)

### PRD Requirements Addressed

| PRD Requirement | Phase 2 Coverage |
|-----------------|------------------|
| FR-002: Signup Form | Partial - form works, minimal validation |
| US-002: Register for Webinar | Complete - end-to-end flow |
| US-005: View Registered Invitees | Partial - list view, no sorting |

---

## Directory Structure

```
application/
├── config.py                      # Configuration classes
├── wsgi.py                        # WSGI entry point
├── requirements.txt               # Dependencies
│
├── app/                           # Application package
│   ├── __init__.py               # Application factory
│   ├── extensions.py             # Flask extensions
│   │
│   ├── models/                   # DATA LAYER
│   │   ├── __init__.py          # Model exports
│   │   └── entry.py             # Entry model
│   │
│   ├── services/                 # BUSINESS LOGIC LAYER
│   │   ├── __init__.py          # Service exports
│   │   └── entry_service.py     # Entry operations
│   │
│   ├── routes/                   # PRESENTATION LAYER
│   │   ├── __init__.py          # Blueprint registration
│   │   ├── main.py              # Web routes
│   │   └── api.py               # API routes
│   │
│   ├── templates/               # Jinja2 templates
│   │   ├── base.html           # Base template
│   │   └── index.html          # Index page
│   │
│   └── static/                  # Static assets
│       ├── css/
│       │   └── style.css
│       └── js/
│           └── .gitkeep
│
├── migrations/                   # Database migrations
│   ├── versions/                # Migration scripts
│   ├── alembic.ini
│   └── env.py
│
└── tests/                        # Test suite
    ├── __init__.py
    ├── conftest.py              # Pytest fixtures
    └── test_routes.py           # Route tests
```

---

## Future Phases

### Phase 3: Full Feature Implementation

> **Status: ✅ COMPLETE** (See [PHASE-3-IMPLEMENTATION-GUIDE.md](./PHASE-3-IMPLEMENTATION-GUIDE.md))

Phase 3 completes all functional requirements from the PRD.

**Implementation Steps (All Completed):**
- ✅ 3.0: Setup and Dependencies (WTForms)
- ✅ 3.1: Registration Form with WTForms validation
- ✅ 3.2: Duplicate Email Prevention
- ✅ 3.3: Enhanced Error Styling and Flash Messages
- ✅ 3.4: Webinar Information Page (FR-001)
- ✅ 3.5: Admin Enhancements - Sorting and Statistics
- ✅ 3.6: Data Export - CSV Download
- ✅ 3.7: Custom Error Pages (400, 404, 500)

**Features Delivered:**
- Complete form validation with WTForms (server-side)
- Duplicate email prevention with unique constraint and case-insensitive handling
- User-friendly error messages with field highlighting
- Flash messages for success/error feedback
- Webinar information display (FR-001) with agenda and speakers
- Admin sorting by name/company/date with ascending/descending order
- Registration statistics (total count, unique companies)
- CSV data export functionality
- Custom error pages (400, 404, 500)

**Test Results:** 74 tests passing (39 from Phase 2 + 35 new Phase 3 tests)

**PRD Requirements Addressed:**
- ✅ FR-001: Webinar Information Display
- ✅ FR-003: Data Validation
- ✅ US-003: Receive Form Validation Feedback
- ✅ US-004: Prevent Duplicate Registrations
- ✅ US-005: View Registered Invitees (enhanced with sorting, stats, export)

### Phase 4: Security & Production

> **Status: 🔲 FUTURE**

Phase 4 implements non-functional requirements for production deployment.

**Features:**
- Admin authentication (login required for `/admin/*`)
- User model and auth service
- HTTPS configuration
- Production deployment scripts
- Health monitoring and alerting

**Files to create:**
```
app/models/user.py              # Admin user model
app/services/auth_service.py    # Authentication logic
app/routes/auth.py              # Login/logout routes
app/templates/auth/
    ├── login.html
    └── logout.html
```

**PRD Requirements Addressed:**
- NFR-002: Timely Deployment
- NFR-003: Security
- NFR-004: Availability

---

## Summary

### Design Principles in Practice

This implementation demonstrates how established software engineering principles translate into practical Flask application architecture:

| Principle | Implementation |
|-----------|----------------|
| **SRP** | Each module has one responsibility |
| **OCP** | Blueprint system enables extension without modification |
| **LSP** | Configuration classes are interchangeable |
| **ISP** | Separate blueprints for different client types |
| **DIP** | Dependencies on abstractions (db, app) not concretions |
| **DRY** | Template inheritance, service layer reuse |
| **SoC** | Clear layer separation |

### Architecture Benefits

The phased approach ensures the architecture supports:

- **Feature additions** - Blueprints enable isolated feature development
- **Team collaboration** - Clear module boundaries reduce conflicts
- **Testing** - In-memory database and fixtures enable fast tests
- **Deployment** - Environment-based configuration supports multiple stages
- **Schema evolution** - Flask-Migrate manages database changes

### Relationship to Requirements

| Document | Phase Coverage |
|----------|----------------|
| **BRD** | Phase 2-3 (business features) |
| **PRD Functional** | Phase 2-3 (FR-001 to FR-003) |
| **PRD Non-Functional** | Phase 4 (NFR-001 to NFR-004) |
| **PRD User Stories** | Phase 2-3 (US-001 to US-005) |
