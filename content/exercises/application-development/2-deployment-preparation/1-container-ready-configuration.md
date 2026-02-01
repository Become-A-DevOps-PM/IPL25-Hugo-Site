+++
title = "Container-Ready Configuration"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Prepare the News Flash application for container deployment with environment-driven configuration, Gunicorn, and Docker"
weight = 1
+++

# Container-Ready Configuration

## Goal

Prepare the News Flash application for container deployment by updating configuration for environment-driven database selection, adding a production entry point with Gunicorn, and creating a Dockerfile for Azure Container Apps.

> **What you'll learn:**
>
> - How to apply the 12-Factor App methodology for environment-driven configuration
> - When to use Gunicorn as a production WSGI server
> - How to create a Dockerfile optimized with layer caching
> - Best practices for preparing Flask applications for container deployment

## Prerequisites

> **Before starting, ensure you have:**
>
> - Completed the three-tier architecture exercises
> - Flask application running with subscriber persistence
> - Docker installed on your development machine

## Exercise Steps

### Overview

1. **Update Configuration for Environment-Driven Settings**
2. **Update Requirements for Production**
3. **Create the Gunicorn Entry Point**
4. **Create the Dockerfile**
5. **Test the Container Build**

### **Step 1:** Update Configuration for Environment-Driven Settings

The 12-Factor App methodology states that configuration should come from the environment, not be hardcoded in source code. This principle allows the same application code to run locally with SQLite during development and connect to Azure SQL Database in production. The only thing that changes between environments is the set of environment variables.

1. **Open** the file `app/config.py`

2. **Replace** the contents with the updated configuration:

   > `app/config.py`

   ```python
   """
   Application configuration for different environments.

   Follows the 12-Factor App methodology: configuration comes from
   environment variables, not hardcoded values. The same code runs
   in development (SQLite) and production (Azure SQL).
   """

   import os
   from dataclasses import dataclass

   BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


   @dataclass
   class Config:
       """Base configuration shared by all environments."""
       SECRET_KEY: str = os.environ.get("SECRET_KEY", "dev-secret-key")
       SQLALCHEMY_TRACK_MODIFICATIONS: bool = False


   @dataclass
   class DevelopmentConfig(Config):
       """Local development with SQLite."""
       DEBUG: bool = True
       SQLALCHEMY_DATABASE_URI: str = f"sqlite:///{os.path.join(BASE_DIR, 'instance', 'news_flash.db')}"


   @dataclass
   class TestingConfig(Config):
       """Automated testing with in-memory SQLite."""
       TESTING: bool = True
       SQLALCHEMY_DATABASE_URI: str = "sqlite:///:memory:"
       WTF_CSRF_ENABLED: bool = False


   @dataclass
   class ProductionConfig(Config):
       """Production deployment - all settings from environment."""
       DEBUG: bool = False
       SQLALCHEMY_DATABASE_URI: str = os.environ.get("DATABASE_URL", "")
       SECRET_KEY: str = os.environ.get("SECRET_KEY", "")


   config_by_name = {
       "development": DevelopmentConfig,
       "testing": TestingConfig,
       "production": ProductionConfig,
   }
   ```

> **Concept Deep Dive**
>
> The 12-Factor App is a methodology for building software-as-a-service applications. Factor III (Config) demands strict separation of config from code. The same Docker image runs anywhere — only the environment variables change. `DATABASE_URL` points to SQLite locally and Azure SQL in production. `SECRET_KEY` has a development fallback but **must** be set to a strong random value in production.
>
> The `config_by_name` dictionary maps environment names to configuration classes. Your `create_app()` factory reads the `FLASK_ENV` environment variable and looks up the matching class: `config_by_name[env_name]`. This pattern eliminates if/else chains and makes adding new environments trivial.
>
> **Common Mistakes**
>
> - Hardcoding database credentials in `config.py` — use environment variables instead
> - Forgetting that `ProductionConfig.SECRET_KEY` defaults to empty string — always set it in production
> - Using the same `SECRET_KEY` in development and production compromises session security
>
> **Quick check:** `config.py` updated with `ProductionConfig` reading from environment variables and `config_by_name` dictionary

3. **Create** a file named `.env.example` in the project root to document all supported environment variables:

   > `.env.example`

   ```text
   FLASK_ENV=development
   SECRET_KEY=dev-secret-key-change-in-production
   DATABASE_URL=sqlite:///instance/news_flash.db
   ```

> **Concept Deep Dive**
>
> The `.env.example` file is not loaded by the application — it serves as documentation for anyone setting up the project. It lists every environment variable the application supports and provides safe example values. Never commit a real `.env` file with production secrets to version control.
>
> For Azure SQL Database, the connection string format is:
>
> ```text
> mssql+pyodbc://user:pass@server/db?driver=ODBC+Driver+18+for+SQL+Server
> ```
>
> SQLAlchemy abstracts the database driver — your application code does not change, only the `DATABASE_URL` value changes between environments.

### **Step 2:** Update Requirements for Production

Running Flask's built-in development server in production is not safe or performant. Gunicorn is a production-grade WSGI HTTP server that handles multiple concurrent requests with worker processes. The pyodbc package provides ODBC database connectivity, which is required for connecting to Azure SQL Database.

1. **Open** the file `requirements.txt` in the project root

2. **Add** the following production dependencies:

   > `requirements.txt`

   ```text
   gunicorn==22.0.0
   pyodbc==5.2.0
   ```

3. **Install** the new dependencies:

   ```bash
   pip install -r requirements.txt
   ```

> **Concept Deep Dive**
>
> **Gunicorn** (Green Unicorn) is a Python WSGI HTTP server. It replaces Flask's built-in Werkzeug development server, which is single-threaded and not designed for production traffic. Gunicorn runs multiple worker processes, each handling requests independently — this is how Python web applications scale.
>
> **pyodbc** provides ODBC (Open Database Connectivity) bindings for Python. Azure SQL Database uses the Microsoft ODBC Driver, and SQLAlchemy connects through pyodbc. You do not need pyodbc for local development with SQLite — it is only used when `DATABASE_URL` points to an Azure SQL instance.
>
> **Quick check:** `requirements.txt` includes `gunicorn` and `pyodbc`

### **Step 3:** Create the Gunicorn Entry Point

In development, `flask run` discovers your application factory automatically. In production, Gunicorn needs an explicit module path to import the application. The `wsgi.py` file creates the application instance that Gunicorn imports at startup.

1. **Create** a new file named `wsgi.py` in the project root (sibling to the `app/` directory):

   > `wsgi.py`

   ```python
   """
   Gunicorn entry point for production deployment.

   Usage:
       gunicorn wsgi:app

   The FLASK_ENV environment variable controls which configuration
   class is loaded (development, testing, or production).
   """

   from app import create_app

   app = create_app()
   ```

> **Concept Deep Dive**
>
> The command `gunicorn wsgi:app` tells Gunicorn: "import the variable `app` from the module `wsgi.py`." Gunicorn then uses this WSGI application object to handle incoming HTTP requests. The `create_app()` call reads `FLASK_ENV` to select the right configuration class, so the same `wsgi.py` file works in every environment.
>
> **Why not point Gunicorn at `app:create_app()`?** While Gunicorn supports factory patterns with `--factory`, the explicit `wsgi.py` approach is simpler, more portable, and works identically across WSGI servers (Gunicorn, uWSGI, Waitress).
>
> **Common Mistakes**
>
> - Placing `wsgi.py` inside the `app/` directory — it must be in the project root alongside `app/`
> - Forgetting to set `FLASK_ENV` when running Gunicorn — defaults to development config
> - Running `flask run` in production — it is single-threaded and shows debug information
>
> **Quick check:** `wsgi.py` created in the project root with `create_app()` call

### **Step 4:** Create the Dockerfile

Docker packages your application and all its dependencies into a container image. The key optimization is layer caching: copy the requirements file first, install dependencies, then copy the application code. When you change application code, Docker reuses the cached dependency layer — saving significant build time.

1. **Create** a new file named `Dockerfile` in the project root:

   > `Dockerfile`

   ```dockerfile
   # Flask with Azure SQL Database
   FROM python:3.11-slim

   # Install ODBC Driver 18 for Azure SQL Database
   RUN apt-get update && apt-get install -y --no-install-recommends \
       curl gnupg2 unixodbc \
       && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
       && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
       && apt-get update \
       && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
       && rm -rf /var/lib/apt/lists/*

   WORKDIR /app

   # Copy requirements first for layer caching
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt

   # Copy application code
   COPY . .

   EXPOSE 5000

   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "wsgi:app"]
   ```

2. **Create** a new file named `.dockerignore` in the project root:

   > `.dockerignore`

   ```text
   .venv/
   instance/
   __pycache__/
   *.pyc
   .env
   *.db
   .git/
   .gitignore
   migrations/
   ```

> **Concept Deep Dive**
>
> **Layer caching** is the most important Docker optimization to understand. Each instruction in a Dockerfile creates a layer. Docker caches layers and only rebuilds from the first changed layer onward. By placing `COPY requirements.txt` and `pip install` before `COPY . .`, dependency installation is cached separately from code changes. Since dependencies change rarely but code changes frequently, this saves minutes on every build.
>
> **ODBC Driver 18** enables SQLAlchemy to connect to Azure SQL Database through pyodbc. The installation adds Microsoft's package repository and installs the driver. This is required in the container because Azure SQL uses the TDS (Tabular Data Stream) protocol, not the PostgreSQL or SQLite wire protocols.
>
> **`--no-cache-dir`** tells pip not to store downloaded packages in a cache directory. Since the Docker image is immutable after build, caching pip downloads would only increase image size with no benefit.
>
> **`.dockerignore`** excludes files from the Docker build context. This makes builds faster (less data sent to the Docker daemon) and images smaller (no development artifacts). The `instance/` directory contains the local SQLite database, which should never be baked into the image — the production container uses Azure SQL instead.
>
> **Common Mistakes**
>
> - Placing `COPY . .` before `pip install` defeats layer caching — every code change reinstalls all dependencies
> - Forgetting `.dockerignore` copies `.venv/` (hundreds of megabytes) into the image
> - Not exposing port 5000 means the container runs but is unreachable
> - Using `python:3.11` instead of `python:3.11-slim` adds hundreds of megabytes of unnecessary build tools
>
> **Quick check:** `Dockerfile` and `.dockerignore` created in the project root

### **Step 5:** Test the Container Build

Time to verify that everything works together. You will build the Docker image, run the container, and confirm the application starts with Gunicorn.

1. **Build** the Docker image:

   ```bash
   docker build -t news-flash .
   ```

2. **Run** the container with environment variables:

   ```bash
   docker run -p 5000:5000 -e FLASK_ENV=production -e SECRET_KEY=test-secret -e DATABASE_URL=sqlite:///news_flash.db news-flash
   ```

3. **Verify** Gunicorn starts with 2 workers by checking the terminal output. You should see lines like:

   ```text
   [INFO] Starting gunicorn 22.0.0
   [INFO] Listening at: http://0.0.0.0:5000
   [INFO] Using worker: sync
   [INFO] Booting worker with pid: ...
   [INFO] Booting worker with pid: ...
   ```

4. **Open** <http://localhost:5000> in your browser and verify the landing page loads

5. **Test** with different `FLASK_ENV` values to confirm configuration switching:

   ```bash
   docker run -p 5000:5000 -e FLASK_ENV=development news-flash
   ```

   - `FLASK_ENV=development` uses SQLite and enables debug mode
   - `FLASK_ENV=production` requires `DATABASE_URL` and `SECRET_KEY` from environment

> **Note:** The actual Azure deployment (Container Apps environment, Azure SQL provisioning) is handled by separate deployment exercises. This exercise prepares the application code only.

> **Success indicators:**
>
> - Docker image builds without errors
> - Container starts with Gunicorn (2 workers shown in logs)
> - Application responds at <http://localhost:5000>
> - Different `FLASK_ENV` values select different configurations
> - `.dockerignore` excludes development files
>
> **Final verification checklist:**
>
> - [ ] `config.py` updated with environment-driven settings and `config_by_name`
> - [ ] `.env.example` documents all supported environment variables
> - [ ] `gunicorn` and `pyodbc` added to `requirements.txt`
> - [ ] `wsgi.py` created as the Gunicorn entry point
> - [ ] `Dockerfile` builds successfully with ODBC Driver and layer caching
> - [ ] `.dockerignore` excludes development artifacts
> - [ ] Container runs and serves the application via Gunicorn

## Common Issues

> **If you encounter problems:**
>
> **"ModuleNotFoundError: No module named 'pyodbc'":** This is expected locally if the ODBC driver is not installed. pyodbc is only needed when connecting to Azure SQL Database. SQLite works without it.
>
> **Docker build fails at ODBC step:** Ensure Docker has internet access. The Microsoft package repository must be reachable during the build.
>
> **"Connection refused" on localhost:5000:** Check that `-p 5000:5000` is included in the `docker run` command. This flag maps the container's port 5000 to your host machine's port 5000.
>
> **Application starts but database errors:** In production mode, `DATABASE_URL` must be set. For local testing inside the container, use `-e DATABASE_URL=sqlite:///news_flash.db`.
>
> **Still stuck?** Run `docker logs <container-id>` to see Gunicorn output and any Python errors.

## Summary

You've successfully prepared the News Flash application for container deployment which:

- Updated configuration for environment-driven settings following the 12-Factor App methodology
- Added Gunicorn as the production WSGI server with an explicit entry point
- Created a Dockerfile with ODBC Driver for Azure SQL Database connectivity
- Optimized Docker builds with layer caching and `.dockerignore`

> **Key takeaway:** The same code runs anywhere — only environment variables change. Development uses SQLite and `flask run`. Production uses Azure SQL and Gunicorn. Docker packages everything into a deployable container image that works identically in every environment.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a health check endpoint (`/api/health`) that container orchestrators can poll
> - Research multi-stage Docker builds to reduce the final image size
> - Explore Docker Compose for local development with PostgreSQL instead of SQLite
> - Learn about Azure Container Apps environment variables and secrets management

## Done!

Your application is now container-ready. The Dockerfile packages everything needed to deploy to Azure Container Apps, while the environment-driven configuration ensures the same code works in development and production.
