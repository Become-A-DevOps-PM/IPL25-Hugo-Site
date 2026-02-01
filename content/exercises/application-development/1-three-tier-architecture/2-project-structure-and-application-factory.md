+++
title = "Project Structure and Application Factory"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Organize a Flask application using three-tier architecture and the application factory pattern"
weight = 1
+++

# Project Structure and Application Factory

## Goal

Organize a Flask application using three-tier architecture and the application factory pattern to create a maintainable, scalable codebase.

> **What you'll learn:**
>
> - How to implement three-tier architecture (presentation, business, data layers)
> - When to use the application factory pattern in Flask
> - Best practices for configuration management with dataclasses
> - Why structure matters for maintainability and testing

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Python 3.11 or later installed
> - ✓ Basic understanding of Python packages and modules
> - ✓ Familiarity with virtual environments

## Exercise Steps

### Overview

1. **Create the Directory Structure**
2. **Create Configuration Files**
3. **Implement the Application Factory**
4. **Add Configuration Management**
5. **Test Your Implementation**

### **Step 1:** Create the Directory Structure

Flask applications can quickly become difficult to maintain if all code lives in a single file. By organizing your code into a three-tier architecture from the start, you establish clear boundaries between different concerns: how data is presented to users (presentation), how business rules are applied (business), and how data is stored and retrieved (data). This separation makes your code easier to understand, test, and modify.

1. **Navigate to** your project root directory

2. **Create** the following directory structure:

   ```text
   application/
   ├── app/
   │   ├── __init__.py
   │   ├── config.py
   │   ├── presentation/
   │   │   ├── routes/
   │   │   │   └── __init__.py
   │   │   ├── templates/
   │   │   └── static/
   │   ├── business/
   │   │   └── services/
   │   └── data/
   │       ├── models/
   │       └── repositories/
   ├── requirements.txt
   ├── .env.example
   └── .gitignore
   ```

3. **Run the following commands** to create all directories:

   ```bash
   mkdir -p application/app/presentation/routes
   mkdir -p application/app/presentation/templates
   mkdir -p application/app/presentation/static
   mkdir -p application/app/business/services
   mkdir -p application/app/data/models
   mkdir -p application/app/data/repositories
   ```

4. **Create** empty `__init__.py` files to make directories into Python packages:

   ```bash
   touch application/app/__init__.py
   touch application/app/presentation/routes/__init__.py
   ```

> ℹ **Concept Deep Dive**
>
> The three-tier architecture separates your application into distinct layers:
>
> - **Presentation Layer** (`presentation/`): Handles HTTP requests, renders templates, serves static files. This is what users interact with.
> - **Business Layer** (`business/`): Contains your application logic and rules. This is where decisions are made.
> - **Data Layer** (`data/`): Manages data storage and retrieval. Models define structure; repositories handle database operations.
>
> This separation means you can change how data is stored (switching databases) without touching business logic, or redesign your UI without affecting how data is processed.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `__init__.py` files makes directories invisible to Python imports
> - Placing business logic in routes creates tight coupling and makes testing difficult
> - Mixing database queries directly in route handlers violates separation of concerns
>
> ✓ **Quick check:** All directories created and `__init__.py` files exist

### **Step 2:** Create Configuration Files

Every Python project needs proper dependency management and environment configuration. The `requirements.txt` file declares your dependencies with version constraints, ensuring consistent environments across development machines and production servers. Environment variables keep sensitive data like secret keys out of your codebase.

1. **Create** the requirements file:

   > `application/requirements.txt`

   ```text
   flask>=3.0.0
   python-dotenv>=1.0.0
   ```

2. **Create** the environment example file:

   > `application/.env.example`

   ```bash
   FLASK_APP=app
   FLASK_DEBUG=1
   SECRET_KEY=dev-secret-key-change-in-production
   ```

3. **Create** the `.gitignore` file:

   > `application/.gitignore`

   ```text
   __pycache__/
   *.py[cod]
   *$py.class
   .env
   .venv/
   venv/
   *.db
   .DS_Store
   *.egg-info/
   dist/
   build/
   .pytest_cache/
   .coverage
   htmlcov/
   ```

4. **Copy** the example environment file for local development:

   ```bash
   cp application/.env.example application/.env
   ```

> ℹ **Concept Deep Dive**
>
> The 12-Factor App methodology recommends storing configuration in environment variables. This approach:
>
> - Keeps secrets out of version control (`.env` is gitignored)
> - Allows different configurations per environment (dev, test, production)
> - Makes deployment configuration changes without code changes
>
> The `.env.example` file documents required variables without exposing actual values. New developers copy it to `.env` and fill in their values.
>
> ⚠ **Common Mistakes**
>
> - Committing `.env` to version control exposes secrets
> - Using `==` instead of `>=` in requirements pins to exact versions, blocking security updates
> - Forgetting to add `__pycache__/` to `.gitignore` clutters your repository
>
> ✓ **Quick check:** `.env` file exists and is listed in `.gitignore`

### **Step 3:** Implement the Application Factory

The application factory pattern creates your Flask application inside a function rather than as a module-level variable. This pattern is essential for testing (you can create multiple app instances with different configurations), for running multiple instances, and for delayed configuration loading when environment variables aren't available at import time.

1. **Open** the file `application/app/__init__.py`

2. **Add the following code:**

   > `application/app/__init__.py`

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

   from .config import config


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

       return app
   ```

> ℹ **Concept Deep Dive**
>
> The `create_app()` function is the application factory. When called, it:
>
> 1. Determines which configuration to use (from argument or environment)
> 2. Creates a new Flask instance with custom template and static paths
> 3. Loads configuration from the appropriate config class
> 4. Returns the configured application
>
> The custom `template_folder` and `static_folder` paths align with our three-tier architecture, placing presentation assets in the presentation layer.
>
> ⚠ **Common Mistakes**
>
> - Creating the app at module level (`app = Flask(__name__)`) prevents testing with different configs
> - Forgetting to import `config` will cause `NameError` at runtime
> - Using relative imports incorrectly (`from config` vs `from .config`) breaks package structure
>
> ✓ **Quick check:** File saved with no syntax errors

### **Step 4:** Add Configuration Management

Configuration classes organize your application settings in a type-safe, documented way. Using dataclasses provides automatic `__init__`, `__repr__`, and type hints. Different configuration classes for each environment (development, testing, production) ensure appropriate settings are applied automatically.

1. **Create** the configuration file:

   > `application/app/config.py`

   ```python
   """
   Application configuration using dataclasses.

   Configuration is loaded from environment variables with sensible defaults
   for development. In production, set SECRET_KEY to a secure random value.
   """

   import os
   from dataclasses import dataclass


   @dataclass
   class Config:
       """Base configuration."""

       SECRET_KEY: str = os.environ.get("SECRET_KEY", "dev-secret-key")
       DEBUG: bool = False
       TESTING: bool = False


   @dataclass
   class DevelopmentConfig(Config):
       """Development configuration."""

       DEBUG: bool = True


   @dataclass
   class TestingConfig(Config):
       """Testing configuration."""

       TESTING: bool = True


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
> The configuration hierarchy works through inheritance:
>
> - `Config` is the base class with shared settings and sensible defaults
> - `DevelopmentConfig` enables debug mode for helpful error pages
> - `TestingConfig` sets `TESTING=True` which disables error catching during tests
> - `ProductionConfig` uses base defaults (DEBUG=False, TESTING=False)
>
> The `config` dictionary maps string names to classes, allowing `create_app("testing")` to load test configuration. This is cleaner than if/else chains and makes adding new environments trivial.
>
> ⚠ **Common Mistakes**
>
> - Using `DEBUG=True` in production exposes sensitive information in error pages
> - Hardcoding secrets instead of using environment variables
> - Forgetting to set a strong `SECRET_KEY` in production breaks session security
>
> ✓ **Quick check:** Config file created with all four configuration classes

### **Step 5:** Test Your Implementation

Testing ensures your application factory works correctly before adding more complexity. At this stage, the application should start without errors but return 404 for all routes since we haven't defined any yet. This is expected and confirms the foundation is solid.

1. **Set up** your virtual environment:

   ```bash
   cd application
   python3 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. **Install** dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. **Run** the development server:

   ```bash
   flask run
   ```

4. **Verify** the application starts:
   - Open your browser to `http://localhost:5000`
   - You should see a "Not Found" (404) page
   - This is expected - we have no routes yet!

5. **Check** the terminal output:
   - No import errors or exceptions
   - Server running message: `Running on http://127.0.0.1:5000`

> ✓ **Success indicators:**
>
> - Virtual environment created and activated
> - Dependencies installed without errors
> - `flask run` starts the server
> - Browser shows 404 Not Found (no routes defined yet)
> - No Python errors in terminal output
>
> ✓ **Final verification checklist:**
>
> - ☐ All directories created with correct structure
> - ☐ `__init__.py` files exist in `app/` and `presentation/routes/`
> - ☐ `requirements.txt`, `.env`, and `.gitignore` created
> - ☐ `create_app()` function exists in `app/__init__.py`
> - ☐ Configuration classes defined in `app/config.py`
> - ☐ Application starts without import errors

## Common Issues

> **If you encounter problems:**
>
> **ModuleNotFoundError: No module named 'app':** Ensure you're running `flask run` from the `application/` directory where `app/` is located
>
> **ImportError: cannot import name 'config':** Check that `config.py` exists in `app/` directory and uses correct dataclass syntax
>
> **Secret key not set:** Create `.env` file by copying `.env.example` and ensure `python-dotenv` is installed
>
> **Template/static folder not found:** Verify the directory structure matches the paths in `create_app()`
>
> **Still stuck?** Verify all file paths match exactly and check for typos in import statements

## Summary

You've successfully implemented the project structure and application factory which:

- ✓ Organizes code into three-tier architecture for clear separation of concerns
- ✓ Uses the application factory pattern for flexible configuration and testing
- ✓ Implements configuration management with environment-aware settings

> **Key takeaway:** The application factory pattern is essential for maintainable Flask applications because it enables testing with different configurations and keeps your application modular. You'll use this pattern in virtually every production Flask project.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try creating a `create_app()` call with `config_name="testing"` and verify `TESTING=True`
> - Research Flask extensions and how they integrate with the application factory
> - Implement logging configuration that changes based on environment
> - Add type hints to all configuration values for better IDE support

## Done! 🎉

Great job! You've set up a well-organized Flask project with three-tier architecture and the application factory pattern. This foundation will support every feature you build going forward, keeping your codebase maintainable and testable as it grows.
