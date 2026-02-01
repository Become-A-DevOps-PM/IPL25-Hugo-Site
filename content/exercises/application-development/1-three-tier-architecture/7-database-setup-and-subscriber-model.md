+++
title = "Database Setup and Subscriber Model"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build the data layer foundation by configuring SQLAlchemy and creating database migrations"
weight = 6
+++

# Database Setup and Subscriber Model

## Goal

Build the data layer foundation by configuring SQLAlchemy, creating database migrations with Flask-Migrate, and implementing a Subscriber model to persist newsletter subscriptions.

> **What you'll learn:**
>
> - How to configure Flask-SQLAlchemy for database access
> - How to use Flask-Migrate for database schema versioning
> - How to create SQLAlchemy models that map to database tables
> - Best practices for database initialization in Flask

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed the business layer validation service
> - ✓ Flask application running with `flask run`
> - ✓ Understanding of Python classes and decorators

## Exercise Steps

### Overview

1. **Add Database Dependencies**
2. **Configure SQLAlchemy**
3. **Initialize Extensions in Application Factory**
4. **Create the Subscriber Model**
5. **Run Database Migrations**
6. **Test Your Implementation**

### **Step 1:** Add Database Dependencies

Flask-SQLAlchemy provides a Flask-friendly wrapper around SQLAlchemy, the most popular Python ORM. Flask-Migrate adds database migration support using Alembic, allowing you to version control your database schema changes.

1. **Open** the file `requirements.txt` in the application root

2. **Add** the following dependencies:

   > `requirements.txt`

   ```text
   flask>=3.0.0
   python-dotenv>=1.0.0
   flask-sqlalchemy>=3.1.0
   flask-migrate>=4.0.0
   ```

3. **Install** the new dependencies:

   ```bash
   pip install -r requirements.txt
   ```

> ℹ **Concept Deep Dive**
>
> **Flask-SQLAlchemy** simplifies SQLAlchemy integration with Flask by handling:
>
> - Session management tied to request lifecycle
> - Configuration through Flask's config system
> - A declarative base class for models (`db.Model`)
>
> **Flask-Migrate** wraps Alembic to provide:
>
> - `flask db init` - Initialize migration repository
> - `flask db migrate` - Generate migration from model changes
> - `flask db upgrade` - Apply migrations to database
>
> ⚠ **Common Mistakes**
>
> - Forgetting to activate your virtual environment before `pip install`
> - Not specifying version constraints can lead to incompatible versions
>
> ✓ **Quick check:** Run `pip list | grep -i flask` to verify both packages are installed

### **Step 2:** Configure SQLAlchemy

The application needs to know where to store data and how to connect to the database. We'll add SQLAlchemy configuration to the config classes, using SQLite for development (a file-based database that requires no setup).

1. **Open** the file `app/config.py`

2. **Add** the database configuration to the `Config` base class:

   > `app/config.py`

   ```python
   """
   Application configuration using dataclasses.

   Configuration is loaded from environment variables with sensible defaults
   for development. In production, set SECRET_KEY and DATABASE_URL to secure values.
   """

   import os
   from dataclasses import dataclass


   @dataclass
   class Config:
       """Base configuration."""

       SECRET_KEY: str = os.environ.get("SECRET_KEY", "dev-secret-key")
       DEBUG: bool = False
       TESTING: bool = False

       # Database configuration
       SQLALCHEMY_DATABASE_URI: str = os.environ.get(
           "DATABASE_URL", "sqlite:///news_flash.db"
       )
       SQLALCHEMY_TRACK_MODIFICATIONS: bool = False


   @dataclass
   class DevelopmentConfig(Config):
       """Development configuration."""

       DEBUG: bool = True


   @dataclass
   class TestingConfig(Config):
       """Testing configuration."""

       TESTING: bool = True
       SQLALCHEMY_DATABASE_URI: str = "sqlite:///:memory:"


   @dataclass
   class ProductionConfig(Config):
       """Production configuration."""

       pass


   config = {
       "development": DevelopmentConfig,
       "testing": TestingConfig,
       "production": ProductionConfig,
       "default": DevelopmentConfig,
   }
   ```

> ℹ **Concept Deep Dive**
>
> **SQLALCHEMY_DATABASE_URI** follows a standard format: `dialect://username:password@host:port/database`
>
> - `sqlite:///news_flash.db` - SQLite file in the instance folder (three slashes = relative path)
> - `sqlite:///:memory:` - In-memory database for testing (data lost when app stops)
> - `postgresql://user:pass@localhost/dbname` - PostgreSQL for production
>
> **SQLALCHEMY_TRACK_MODIFICATIONS** is set to `False` to disable Flask-SQLAlchemy's event system, which consumes extra memory and is rarely needed.
>
> The testing config uses an in-memory database for fast, isolated tests.
>
> ⚠ **Common Mistakes**
>
> - Using `sqlite://news_flash.db` (two slashes) creates an invalid URI
> - Hardcoding production database URLs exposes credentials in version control
> - Forgetting `SQLALCHEMY_TRACK_MODIFICATIONS` causes deprecation warnings
>
> ✓ **Quick check:** Config class has both `SQLALCHEMY_DATABASE_URI` and `SQLALCHEMY_TRACK_MODIFICATIONS`

### **Step 3:** Initialize Extensions in Application Factory

The application factory pattern requires extensions to be created at module level but initialized with the app later. This enables multiple app instances with different configurations (essential for testing).

1. **Open** the file `app/__init__.py`

2. **Replace** the contents with the following:

   > `app/__init__.py`

   ```python
   """
   News Flash - Application Factory

   This module creates and configures the Flask application using the
   application factory pattern. This pattern enables:
   - Multiple instances with different configurations
   - Easy testing with test configurations
   - Delayed configuration loading
   """

   import os

   from flask import Flask
   from flask_migrate import Migrate
   from flask_sqlalchemy import SQLAlchemy

   from .config import config

   # Create extensions at module level (initialized in create_app)
   db = SQLAlchemy()
   migrate = Migrate()


   def create_app(config_name: str | None = None) -> Flask:
       """
       Create and configure the Flask application.

       Args:
           config_name: Configuration to use ('development', 'testing', 'production').
                       Defaults to FLASK_ENV environment variable or 'development'.

       Returns:
           Configured Flask application instance.
       """
       if config_name is None:
           config_name = os.environ.get("FLASK_ENV", "development")

       app = Flask(
           __name__,
           template_folder="presentation/templates",
           static_folder="presentation/static",
       )

       # Load configuration
       app.config.from_object(config[config_name])

       # Initialize extensions
       db.init_app(app)
       migrate.init_app(app, db)

       # Register blueprints
       from .presentation.routes.public import bp as public_bp

       app.register_blueprint(public_bp)

       return app
   ```

> ℹ **Concept Deep Dive**
>
> The **two-phase initialization** pattern (`db = SQLAlchemy()` then `db.init_app(app)`) is essential for Flask extensions:
>
> 1. **Module level**: Create extension objects without app context
> 2. **Factory function**: Bind extensions to the specific app instance
>
> This allows:
>
> - **Testing**: Create fresh app instances with test configurations
> - **Multiple apps**: Run different configurations in the same process
> - **Circular imports**: Models can import `db` before the app exists
>
> The `migrate.init_app(app, db)` connects Flask-Migrate to both the app and the SQLAlchemy instance.
>
> ⚠ **Common Mistakes**
>
> - Creating extensions inside `create_app` breaks model imports
> - Forgetting to pass `db` to `migrate.init_app()` prevents migrations from working
> - Initializing extensions before loading config uses wrong settings
>
> ✓ **Quick check:** Both `db` and `migrate` are created at module level and initialized in `create_app`

### **Step 4:** Create the Subscriber Model

Models define the structure of your database tables. The Subscriber model maps Python objects to rows in a `subscribers` table, with columns for email, name, and subscription timestamp.

1. **Navigate to** the `app/data/models` directory

2. **Create a new file** named `subscriber.py`

3. **Add the following code:**

   > `app/data/models/subscriber.py`

   ```python
   """
   Subscriber model - represents a newsletter subscriber.

   This model belongs to the Data Layer and defines the database schema
   for storing subscriber information.
   """

   from datetime import datetime, timezone

   from app import db


   class Subscriber(db.Model):
       """
       Newsletter subscriber.

       Attributes:
           id: Primary key
           email: Unique email address (required)
           name: Subscriber's display name
           subscribed_at: Timestamp when subscription was created
       """

       __tablename__ = "subscribers"

       id = db.Column(db.Integer, primary_key=True)
       email = db.Column(db.String(255), unique=True, nullable=False, index=True)
       name = db.Column(db.String(100), nullable=False, default="Subscriber")
       subscribed_at = db.Column(
           db.DateTime(timezone=True),
           nullable=False,
           default=lambda: datetime.now(timezone.utc),
       )

       def __repr__(self) -> str:
           """Return string representation for debugging."""
           return f"<Subscriber {self.email}>"
   ```

4. **Update** the models package to expose the model:

   > `app/data/models/__init__.py`

   ```python
   """Data models package."""

   from .subscriber import Subscriber

   __all__ = ["Subscriber"]
   ```

5. **Import models in the factory** to register them with SQLAlchemy. **Open** `app/__init__.py` and add after the extension initialization:

   > `app/__init__.py`

   ```python
       # Initialize extensions
       db.init_app(app)
       migrate.init_app(app, db)

       # Import models (after db.init_app to avoid circular imports)
       from .data import models  # noqa: F401

       # Register blueprints
   ```

> ℹ **Concept Deep Dive**
>
> **SQLAlchemy Column Types:**
>
> - `db.Integer` - Whole numbers, auto-increments as primary key
> - `db.String(255)` - Variable-length text up to 255 characters
> - `db.DateTime(timezone=True)` - Timestamp with timezone support
>
> **Column Constraints:**
>
> - `primary_key=True` - Unique identifier, auto-generated
> - `unique=True` - No duplicate values allowed
> - `nullable=False` - Value required (NOT NULL)
> - `index=True` - Create database index for faster lookups
> - `default=` - Value used when not provided (can be a callable like `lambda`)
>
> The `__tablename__` explicitly sets the table name; without it, SQLAlchemy would derive it from the class name.
>
> ⚠ **Common Mistakes**
>
> - Importing `db` before `db.init_app()` causes application context errors
> - Using `datetime.now()` without `timezone.utc` creates naive datetimes
> - Forgetting `index=True` on email makes duplicate checks slow
> - Not exposing models in `__init__.py` makes imports verbose
>
> ✓ **Quick check:** Model file created with all four columns defined

### **Step 5:** Run Database Migrations

Flask-Migrate manages database schema changes through migrations. We'll initialize the migration repository, generate an initial migration from our model, and apply it to create the database table.

1. **Initialize** the migration repository (one-time setup):

   ```bash
   flask db init
   ```

   This creates a `migrations/` directory with Alembic configuration.

2. **Generate** the initial migration:

   ```bash
   flask db migrate -m "Add subscribers table"
   ```

   This creates a migration file in `migrations/versions/` based on your model.

3. **Review** the generated migration file in `migrations/versions/` (optional but recommended):

   ```bash
   ls migrations/versions/
   ```

   The file name includes a revision ID and your message, e.g., `abc123_add_subscribers_table.py`

4. **Apply** the migration to create the table:

   ```bash
   flask db upgrade
   ```

   This executes the migration and creates the `subscribers` table.

5. **Verify** the table was created:

   ```bash
   sqlite3 instance/news_flash.db ".schema subscribers"
   ```

   You should see the table schema with all columns.

> ℹ **Concept Deep Dive**
>
> **Migration Workflow:**
>
> 1. `flask db init` - Creates migration repository (only once per project)
> 2. `flask db migrate` - Compares models to database, generates migration script
> 3. `flask db upgrade` - Applies pending migrations to database
>
> **Why Migrations?**
>
> - Version control for database schema
> - Team members can apply the same changes
> - Rollback capability with `flask db downgrade`
> - Production deployments are reproducible
>
> The `instance/` folder is Flask's default location for instance-specific files like SQLite databases. It's typically gitignored.
>
> ⚠ **Common Mistakes**
>
> - Running `migrate` before `init` fails with "No such directory"
> - Forgetting to `upgrade` after `migrate` means tables aren't created
> - Editing migration files incorrectly can corrupt the database
> - Not importing models before migration results in empty migrations
>
> ✓ **Quick check:** `migrations/` directory exists and `sqlite3` shows the table schema

### **Step 6:** Test Your Implementation

Verify the database layer works by using Flask's interactive shell to create and query subscribers directly.

1. **Start** the Flask shell:

   ```bash
   flask shell
   ```

2. **Import** the model and db:

   ```python
   from app import db
   from app.data.models import Subscriber
   ```

3. **Create** a test subscriber:

   ```python
   subscriber = Subscriber(email="test@example.com", name="Test User")
   db.session.add(subscriber)
   db.session.commit()
   print(f"Created: {subscriber}")
   ```

4. **Query** subscribers:

   ```python
   all_subscribers = Subscriber.query.all()
   print(f"Total subscribers: {len(all_subscribers)}")

   found = Subscriber.query.filter_by(email="test@example.com").first()
   print(f"Found: {found.name} subscribed at {found.subscribed_at}")
   ```

5. **Exit** the shell:

   ```python
   exit()
   ```

6. **Verify** data persisted using sqlite3:

   ```bash
   sqlite3 instance/news_flash.db "SELECT * FROM subscribers;"
   ```

> ✓ **Success indicators:**
>
> - Flask shell starts without errors
> - `Subscriber` can be imported from `app.data.models`
> - Creating a subscriber doesn't raise exceptions
> - Query returns the created subscriber
> - sqlite3 shows the row with all columns populated
> - `subscribed_at` has a timestamp (set automatically)
>
> ✓ **Final verification checklist:**
>
> - [ ] `flask-sqlalchemy` and `flask-migrate` in requirements.txt
> - [ ] `SQLALCHEMY_DATABASE_URI` configured in config.py
> - [ ] `db` and `migrate` initialized in application factory
> - [ ] `Subscriber` model created in `app/data/models/subscriber.py`
> - [ ] Models exposed in `app/data/models/__init__.py`
> - [ ] `migrations/` directory exists with version files
> - [ ] `instance/news_flash.db` contains `subscribers` table
> - [ ] Flask shell can create and query subscribers

## Common Issues

> **If you encounter problems:**
>
> **"No application found":** Ensure you're in the `application/` directory and `FLASK_APP` is set (or `.flaskenv` exists)
>
> **"Working outside of application context":** Import db inside the factory or use `with app.app_context():`
>
> **"Table already exists":** Delete `instance/news_flash.db` and run `flask db upgrade` again
>
> **Empty migration generated:** Ensure models are imported in `create_app` before calling `flask db migrate`
>
> **"Target database is not up to date":** Run `flask db upgrade` before `flask db migrate`
>
> **Still stuck?** Check the Flask terminal for Python errors and verify all imports are correct

## Summary

You've successfully set up the data layer foundation which:

- ✓ Configures SQLAlchemy for database access
- ✓ Uses Flask-Migrate for schema versioning
- ✓ Defines a Subscriber model with proper constraints
- ✓ Creates the database through migrations

> **Key takeaway:** The data layer handles persistence - storing and retrieving data from the database. By using SQLAlchemy models, you work with Python objects instead of raw SQL. Migrations ensure database changes are versioned and reproducible across environments. The model defines "what data looks like" while the repository (next exercise) defines "how to access it."

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add more fields to Subscriber (e.g., `is_active`, `unsubscribed_at`)
> - Explore SQLAlchemy relationships for connected models
> - Try `flask db history` to see migration history
> - Research database indexing strategies for performance

## Done! 🎉

Great job! You've learned how to set up a database layer with SQLAlchemy and Flask-Migrate, and can now define models that map Python objects to database tables. This foundation enables persistent data storage and versioned schema management for your application.
