# News Flash - Three-Tier Architecture Curriculum

## Overview

This curriculum guides students through building a complete Flask application using three-tier architecture. Each layer is completed fully before moving to the next, demonstrating clean separation of concerns.

## Learning Objectives

By the end of this curriculum, students will be able to:

1. Explain the purpose of each layer in three-tier architecture
2. Create a Flask application using the application factory pattern
3. Use Jinja2 template inheritance for consistent layouts
4. Implement form handling and user feedback
5. Create validation services in the business layer
6. Use SQLAlchemy models and the repository pattern for persistence
7. Connect all three layers in a complete request flow

## Milestones Overview

| Milestone | Steps | Focus |
|-----------|-------|-------|
| 1. Presentation Layer | 1-9 | Templates, routes, forms, user feedback |
| 2. Business Layer | 10-11 | Validation, business rules, services |
| 3. Data Layer | 12-15 | Models, migrations, repositories |

---

## Step 1: Hello World Script → Flask App

**Exercise:** "From Script to Web Application"

### Goal
Understand the transition from Python script to web application.

### Instructions

1. Create a simple Python script:
   ```python
   # application/hello.py
   print("Hello World")
   ```

2. Run it:
   ```bash
   cd application
   python hello.py
   ```

3. Convert to minimal Flask app:
   ```python
   # application/hello.py
   from flask import Flask

   app = Flask(__name__)

   @app.route("/")
   def hello():
       return "Hello World"
   ```

4. Run as Flask app:
   ```bash
   flask --app hello run
   ```

5. Visit http://localhost:5000

### Verification
Browser shows "Hello World" text.

---

## Step 2: Three-Tier Folder Structure

**Exercise:** "Creating the Three-Tier Project Structure"

### Goal
Establish the complete folder skeleton with all three layers visible.

### Instructions

1. Delete `hello.py` (we'll rebuild properly)

2. Create the folder structure:
   ```
   application/
   ├── app/
   │   ├── __init__.py
   │   ├── config.py
   │   ├── presentation/
   │   │   ├── __init__.py
   │   │   ├── routes/
   │   │   │   └── __init__.py
   │   │   └── templates/
   │   ├── business/
   │   │   ├── __init__.py
   │   │   └── services/
   │   │       └── __init__.py
   │   └── data/
   │       ├── __init__.py
   │       ├── models/
   │       │   └── __init__.py
   │       └── repositories/
   │           └── __init__.py
   ├── requirements.txt
   ├── .env.example
   ├── .gitignore
   └── tests/
       └── __init__.py
   ```

3. Create `requirements.txt`:
   ```
   flask>=3.0.0
   python-dotenv>=1.0.0
   ```

4. Create `.env.example`:
   ```
   FLASK_APP=app
   FLASK_DEBUG=1
   SECRET_KEY=dev-secret-key-change-in-production
   ```

5. Create `.gitignore`:
   ```
   __pycache__/
   *.py[cod]
   .env
   .venv/
   venv/
   *.db
   .DS_Store
   ```

### Verification
Directory structure exists. All `__init__.py` files are empty (for now).

---

## Step 3: Application Factory & Configuration

**Exercise:** "The Application Factory Pattern"

### Goal
Implement Flask's application factory for testability and configuration.

### Instructions

1. Update `app/__init__.py`:
   ```python
   from flask import Flask
   from .config import config

   def create_app(config_name='development'):
       app = Flask(__name__)
       app.config.from_object(config[config_name])

       return app
   ```

2. Create `app/config.py`:
   ```python
   import os
   from dataclasses import dataclass

   @dataclass
   class Config:
       SECRET_KEY: str = os.environ.get('SECRET_KEY', 'dev-secret-key')
       DEBUG: bool = False
       TESTING: bool = False

   @dataclass
   class DevelopmentConfig(Config):
       DEBUG: bool = True

   @dataclass
   class TestingConfig(Config):
       TESTING: bool = True

   @dataclass
   class ProductionConfig(Config):
       pass

   config = {
       'development': DevelopmentConfig,
       'testing': TestingConfig,
       'production': ProductionConfig,
       'default': DevelopmentConfig
   }
   ```

3. Create `.env` file (copy from `.env.example`)

### Verification
```bash
flask run
```
Application starts without errors (no routes yet, so browser shows 404).

---

## Step 4: Base Template with Header/Footer

**Exercise:** "Template Inheritance with Jinja2"

### Goal
Create reusable base template with header, main content area, footer.

### Instructions

Create `app/presentation/templates/base.html` with:
- HTML5 document structure
- CSS styling in `<style>` block
- Header with "News Flash" branding
- Main content area with `{% block content %}`
- Footer with copyright
- Block for additional scripts

### Verification
File exists with valid HTML structure.

---

## Step 5: First Route and Landing Page

**Exercise:** "Your First Route and Template"

### Goal
Complete the request flow: URL → Route → Template → Response.

### Instructions

1. Create `app/presentation/routes/public.py`:
   ```python
   from flask import Blueprint, render_template

   bp = Blueprint('public', __name__)

   @bp.route('/')
   def index():
       return render_template('index.html')
   ```

2. Create `app/presentation/templates/index.html`:
   ```html
   {% extends "base.html" %}

   {% block content %}
   <h1>Welcome to News Flash</h1>
   <p>Your daily dose of tech news.</p>
   {% endblock %}
   ```

3. Update `app/__init__.py` to register the blueprint and configure template folder.

### Verification
```bash
flask run
```
Visit http://localhost:5000 - see page with header, content, and footer.

---

## Step 6: Hero Section with Styling

**Exercise:** "The Hero Section and Call-to-Action"

### Goal
Add the main content - hero section with newsletter pitch and CTA button.

### Instructions

Update `index.html` with:
- Hero section with gradient background
- Headline and subheadline
- "Subscribe Now" button (styled, non-functional)

### Verification
Visit `/` - see styled hero section with gradient background and button.

---

## Step 7: Modal Dialog

**Exercise:** "Interactive Modal with JavaScript"

### Goal
Button click shows modal - placeholder for future subscription form.

### Instructions

1. Add modal CSS to `base.html` (in style block)
2. Add modal HTML to `index.html`
3. Add JavaScript for:
   - Open modal on button click
   - Close on "Close" button click
   - Close on Escape key
   - Close on click outside modal

### Verification
- Click "Subscribe Now" → modal appears
- Click "Close" → modal closes
- Press Escape → modal closes
- Click outside modal → modal closes

---

## Step 8: Subscription Page with Form

**Exercise:** "The Subscription Form"

### Goal
Create a dedicated subscription page with an HTML form.

### Instructions

1. Update the modal's "Subscribe Now" button to link to `/subscribe` instead of just closing.

2. Create `app/presentation/routes/public.py` - add new route:
   ```python
   @bp.route('/subscribe')
   def subscribe():
       return render_template('subscribe.html')
   ```

3. Create `app/presentation/templates/subscribe.html`:
   - Extends `base.html`
   - Contains a form with:
     - Email field (required)
     - Name field (optional)
     - Submit button
   - Form action posts to `/subscribe/confirm`
   - Link back to home page

### Verification
- Click "Subscribe Now" on landing page → navigates to `/subscribe`
- See form with email and name fields
- Form has submit button

---

## Step 9: Form Handling and Thank You Page

**Exercise:** "Processing Form Data"

### Goal
Handle form submission and display confirmation - no persistence yet.

### Instructions

1. Add POST route in `app/presentation/routes/public.py`:
   ```python
   @bp.route('/subscribe/confirm', methods=['POST'])
   def subscribe_confirm():
       email = request.form.get('email')
       name = request.form.get('name', 'Subscriber')

       # Verification: print to terminal
       print(f"New subscription: {email} ({name})")

       return render_template('thank_you.html', email=email, name=name)
   ```

2. Create `app/presentation/templates/thank_you.html`:
   - Extends `base.html`
   - Displays personalized thank you message
   - Echoes back the submitted email
   - Link back to home page

### Verification
- Fill in form at `/subscribe` and submit
- Terminal shows: `New subscription: user@example.com (John)`
- Browser shows thank you page with the submitted email
- No database involved - pure presentation layer

---

## Milestone 1 Complete: Presentation Layer

After all 9 steps, the application:

- Starts with `flask run`
- Shows landing page at `/` with hero section
- "Subscribe Now" button links to subscription page
- Subscription form at `/subscribe` with email and name fields
- Form submission shows thank you page with echoed data
- Terminal shows submitted data (verification)
- Three-tier folder structure in place
- **No business logic validation yet**
- **No database persistence yet**

---

## Milestone 2: Business Layer

### Goal
Add validation and business logic between presentation and data layers.

---

## Step 10: Email Validation Service

**Exercise:** "Input Validation"

### Goal
Create a service that validates email format before processing.

### Instructions

1. Create `app/business/services/subscription_service.py`:
   ```python
   import re

   class SubscriptionService:
       EMAIL_PATTERN = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

       def validate_email(self, email: str) -> tuple[bool, str]:
           """Returns (is_valid, error_message)"""
           if not email:
               return False, "Email is required"
           if not re.match(self.EMAIL_PATTERN, email):
               return False, "Invalid email format"
           return True, ""
   ```

2. Update the route to use the service:
   ```python
   from app.business.services.subscription_service import SubscriptionService

   @bp.route('/subscribe/confirm', methods=['POST'])
   def subscribe_confirm():
       email = request.form.get('email')
       name = request.form.get('name', 'Subscriber')

       service = SubscriptionService()
       is_valid, error = service.validate_email(email)

       if not is_valid:
           return render_template('subscribe.html', error=error, email=email, name=name)

       print(f"Valid subscription: {email} ({name})")
       return render_template('thank_you.html', email=email, name=name)
   ```

3. Update `subscribe.html` to display error messages.

### Verification
- Submit empty email → see error message, stay on form
- Submit "invalid" → see error message
- Submit "user@example.com" → see thank you page

---

## Step 11: Business Rules

**Exercise:** "Subscription Business Logic"

### Goal
Add business rules to the subscription service.

### Instructions

1. Extend `SubscriptionService` with business methods:
   ```python
   def normalize_email(self, email: str) -> str:
       """Lowercase and strip whitespace"""
       return email.lower().strip()

   def process_subscription(self, email: str, name: str) -> dict:
       """Process and return subscription data"""
       return {
           'email': self.normalize_email(email),
           'name': name.strip() if name else 'Subscriber',
           'subscribed_at': datetime.utcnow().isoformat()
       }
   ```

2. Update route to use full service processing.

### Verification
- Submit " USER@EXAMPLE.COM " → terminal shows normalized "user@example.com"
- Business layer transforms data before it would be saved

---

## Milestone 2 Complete: Business Layer

After Steps 10-11:

- Email validation with clear error messages
- Email normalization (lowercase, trimmed)
- Business logic separated from routes
- Service class is testable in isolation
- **Still no database - data printed to terminal**

---

## Milestone 3: Data Layer

### Goal
Add persistence with SQLAlchemy models and repository pattern.

---

## Step 12: Database Setup

**Exercise:** "Flask-SQLAlchemy Configuration"

### Goal
Configure SQLAlchemy and create the database.

### Instructions

1. Update `requirements.txt`:
   ```
   flask>=3.0.0
   python-dotenv>=1.0.0
   flask-sqlalchemy>=3.1.0
   flask-migrate>=4.0.0
   ```

2. Update `app/config.py` with database URI:
   ```python
   SQLALCHEMY_DATABASE_URI: str = os.environ.get(
       'DATABASE_URL', 'sqlite:///news_flash.db'
   )
   SQLALCHEMY_TRACK_MODIFICATIONS: bool = False
   ```

3. Initialize SQLAlchemy in `app/__init__.py`:
   ```python
   from flask_sqlalchemy import SQLAlchemy

   db = SQLAlchemy()

   def create_app(config_name='development'):
       app = Flask(__name__)
       app.config.from_object(config[config_name])

       db.init_app(app)

       # ... register blueprints ...

       return app
   ```

### Verification
```bash
pip install -r requirements.txt
flask run
```
Application starts without database errors.

---

## Step 13: Subscriber Model

**Exercise:** "Creating the Data Model"

### Goal
Define the Subscriber model in the data layer.

### Instructions

1. Create `app/data/models/subscriber.py`:
   ```python
   from datetime import datetime
   from app import db

   class Subscriber(db.Model):
       __tablename__ = 'subscribers'

       id = db.Column(db.Integer, primary_key=True)
       email = db.Column(db.String(255), unique=True, nullable=False, index=True)
       name = db.Column(db.String(100), nullable=True)
       subscribed_at = db.Column(db.DateTime, default=datetime.utcnow)

       def __repr__(self):
           return f'<Subscriber {self.email}>'
   ```

2. Create and run migration:
   ```bash
   flask db init
   flask db migrate -m "Create subscribers table"
   flask db upgrade
   ```

### Verification
- `news_flash.db` file created
- Table `subscribers` exists with correct columns

---

## Step 14: Repository Pattern

**Exercise:** "Data Access Layer"

### Goal
Create repository for database operations, keeping SQL out of services.

### Instructions

1. Create `app/data/repositories/subscriber_repository.py`:
   ```python
   from app import db
   from app.data.models.subscriber import Subscriber

   class SubscriberRepository:
       def find_by_email(self, email: str) -> Subscriber | None:
           return Subscriber.query.filter_by(email=email).first()

       def create(self, email: str, name: str = None) -> Subscriber:
           subscriber = Subscriber(email=email, name=name)
           db.session.add(subscriber)
           db.session.commit()
           return subscriber

       def exists(self, email: str) -> bool:
           return self.find_by_email(email) is not None
   ```

### Verification
Repository class created with CRUD methods.

---

## Step 15: Connecting the Layers

**Exercise:** "Full Stack Integration"

### Goal
Connect presentation → business → data layers for complete flow.

### Instructions

1. Update `SubscriptionService` to use repository:
   ```python
   from app.data.repositories.subscriber_repository import SubscriberRepository

   class SubscriptionService:
       def __init__(self):
           self.repository = SubscriberRepository()

       def subscribe(self, email: str, name: str) -> tuple[bool, str]:
           # Validate
           is_valid, error = self.validate_email(email)
           if not is_valid:
               return False, error

           # Normalize
           email = self.normalize_email(email)

           # Check duplicate
           if self.repository.exists(email):
               return False, "Email already subscribed"

           # Save
           self.repository.create(email, name)
           return True, ""
   ```

2. Update route to use the complete service:
   ```python
   @bp.route('/subscribe/confirm', methods=['POST'])
   def subscribe_confirm():
       email = request.form.get('email')
       name = request.form.get('name', '')

       service = SubscriptionService()
       success, error = service.subscribe(email, name)

       if not success:
           return render_template('subscribe.html', error=error, email=email, name=name)

       return render_template('thank_you.html', email=email, name=name)
   ```

### Verification
- Submit new email → saved to database, see thank you page
- Submit same email again → see "Email already subscribed" error
- Check database: `sqlite3 instance/news_flash.db "SELECT * FROM subscribers;"`

---

## Milestone 3 Complete: Data Layer

After Steps 12-15:

- SQLAlchemy configured with Flask-Migrate
- Subscriber model with proper fields
- Repository pattern for data access
- Full flow: Form → Route → Service → Repository → Database
- Duplicate email detection
- Three-tier architecture fully implemented

---

## Summary: Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Steps 4-9                                                   │
│  ├── Templates (base, index, subscribe, thank_you)          │
│  └── Routes (/, /subscribe, /subscribe/confirm)             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LAYER                           │
│  Steps 10-11                                                 │
│  └── SubscriptionService (validate, normalize, process)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  Steps 12-15                                                 │
│  ├── Subscriber model                                        │
│  └── SubscriberRepository (find, create, exists)            │
└─────────────────────────────────────────────────────────────┘
```

Each layer completed before moving to the next. Each milestone is independently verifiable.
