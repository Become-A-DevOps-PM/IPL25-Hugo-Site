+++
title = "Security Headers and Admin CLI"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Add OWASP-recommended security headers, custom error pages, and a CLI command for creating admin users"
weight = 6
+++

# Security Headers and Admin CLI

## Goal

Add OWASP-recommended security headers, custom error pages, and a CLI command for creating admin users to harden your News Flash application against common web attacks and simplify admin management.

> **What you'll learn:**
>
> - How to add security headers as Flask middleware using `@app.after_request`
> - How to create CLI commands with Flask's `click` integration
> - How to build custom error pages for a consistent user experience
> - Best practices for layered security in web applications

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Flask application running with authentication and Flask-Login configured
> - ✓ `AuthService` with `create_user()` and `DuplicateUsernameError` in the business layer
> - ✓ Templates in `app/presentation/templates/` with `base.html` providing navigation and flash messages
> - ✓ Database migrations applied (`flask db upgrade`)

## Exercise Steps

### Overview

1. **Add Security Headers Middleware**
2. **Create the Admin CLI Command**
3. **Add Custom Error Pages**
4. **Test Security Headers**
5. **Test CLI and Error Pages**

### **Step 1:** Add Security Headers Middleware

OWASP (Open Web Application Security Project) recommends several HTTP response headers to prevent common browser-level attacks. Instead of adding these headers to every route individually, we register an `after_request` handler that runs after every response. This ensures consistent security across the entire application with a single piece of code.

1. **Open** `app/__init__.py`

2. **Add** the following inside `create_app()`, after blueprint registration:

   > `app/__init__.py`

   ```python
   @app.after_request
   def add_security_headers(response):
       """Add OWASP-recommended security headers to all responses."""
       response.headers["X-Content-Type-Options"] = "nosniff"
       response.headers["X-Frame-Options"] = "SAMEORIGIN"
       response.headers["X-XSS-Protection"] = "1; mode=block"
       response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

       # HSTS only in production (not during development/testing)
       if not app.debug and not app.testing:
           response.headers["Strict-Transport-Security"] = (
               "max-age=31536000; includeSubDomains"
           )

       return response
   ```

> ℹ **Concept Deep Dive**
>
> Each header protects against a specific category of attack:
>
> - **`X-Content-Type-Options: nosniff`** -- Prevents browsers from guessing content types (MIME sniffing attacks). Without this, a browser might execute a file uploaded as `.txt` if it detects JavaScript inside.
> - **`X-Frame-Options: SAMEORIGIN`** -- Prevents clickjacking by blocking your page from being embedded in an iframe on another domain. An attacker could overlay invisible buttons on your page to trick users into clicking.
> - **`X-XSS-Protection: 1; mode=block`** -- Enables the browser's built-in XSS filter. If the browser detects a reflected XSS attack, it blocks the page instead of trying to sanitize it.
> - **`Referrer-Policy: strict-origin-when-cross-origin`** -- Controls what URL information is sent in the `Referer` header when navigating to other sites. This prevents leaking internal URL paths to external services.
> - **`Strict-Transport-Security`** -- Forces HTTPS for all future visits (the browser remembers for one year). This is only enabled in production because development uses HTTP on localhost.
>
> The `@app.after_request` decorator registers a function that runs after every response, regardless of which route handled the request. This is Flask's middleware pattern for response modification.
>
> ⚠ **Common Mistakes**
>
> - Placing the `@app.after_request` handler outside `create_app()` means `app` is not in scope and the code will fail
> - Forgetting `return response` causes Flask to return an empty response
> - Enabling HSTS in development breaks localhost access because browsers will refuse HTTP connections
>
> ✓ **Quick check:** The `add_security_headers` function is defined inside `create_app()` and returns the response object

### **Step 2:** Create the Admin CLI Command

CLI (Command-Line Interface) commands let you manage the application from the terminal without a web interface. This is essential for creating the first admin user -- you cannot log in to create an admin if no admin exists yet. This solves the "chicken-and-egg" problem of admin account creation.

1. **Create a new file** named `cli.py` in the `app/` directory

2. **Add the following code:**

   > `app/cli.py`

   ```python
   """Flask CLI commands for application management."""

   import click
   from flask.cli import with_appcontext
   from app.business.services.auth_service import AuthService, DuplicateUsernameError


   @click.command("create-admin")
   @click.argument("username")
   @click.option("--password", "-p", default=None,
                 help="Admin password (min 8 chars). Prompted if not provided.")
   @with_appcontext
   def create_admin_command(username, password):
       """Create a new admin user.

       USERNAME: The username for the new admin account.
       """
       # Prompt for password if not provided
       if password is None:
           password = click.prompt("Password", hide_input=True,
                                   confirmation_prompt=True)

       # Validate password length
       if len(password) < 8:
           click.echo("Error: Password must be at least 8 characters long.",
                      err=True)
           raise SystemExit(1)

       try:
           user = AuthService.create_user(username, password)
           click.echo(f"Admin user '{user.username}' created successfully.")
       except DuplicateUsernameError:
           click.echo(f"Error: Username '{username}' already exists.", err=True)
           raise SystemExit(1)
   ```

3. **Open** `app/__init__.py`

4. **Add** the following inside `create_app()` to register the command:

   > `app/__init__.py`

   ```python
   from app.cli import create_admin_command
   app.cli.add_command(create_admin_command)
   ```

> ℹ **Concept Deep Dive**
>
> Flask uses the `click` library for CLI commands. Here is what each decorator does:
>
> - **`@click.command("create-admin")`** -- Registers this function as a CLI command called `create-admin`. You run it with `flask create-admin`.
> - **`@click.argument("username")`** -- Defines a required positional argument. The user must provide it: `flask create-admin admin`.
> - **`@click.option("--password", "-p")`** -- Defines an optional flag. The `-p` shorthand lets you write `flask create-admin admin -p MyPassword` instead of `--password MyPassword`.
> - **`@with_appcontext`** -- Ensures the Flask application context is active so database operations work. Without this, `AuthService.create_user()` would fail because SQLAlchemy needs an active application context.
>
> The password handling demonstrates defense in depth: if the password is not provided on the command line, `click.prompt()` asks interactively with `hide_input=True` (characters are not displayed) and `confirmation_prompt=True` (the user must type the password twice). This prevents typos in admin passwords.
>
> `raise SystemExit(1)` exits with a non-zero status code, which signals failure to shell scripts and CI/CD pipelines.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `@with_appcontext` causes `RuntimeError: Working outside of application context`
> - Forgetting to register the command with `app.cli.add_command()` means Flask will not find the `create-admin` command
> - Using `print()` instead of `click.echo()` bypasses click's output handling and breaks pipe operations
>
> ✓ **Quick check:** `app/cli.py` created and command registered in `app/__init__.py`

### **Step 3:** Add Custom Error Pages

Custom error pages provide a consistent user experience instead of showing Flask's default debug pages (which can leak sensitive information like stack traces and file paths). We create templates for the two most common HTTP errors and register handlers in the application factory.

1. **Create** the directory `app/presentation/templates/errors/`

2. **Create a new file** named `404.html`:

   > `app/presentation/templates/errors/404.html`

   ```html
   {% extends "base.html" %}
   {% block title %}Page Not Found - News Flash{% endblock %}
   {% block content %}
   <div class="error-page">
       <h1>404 - Page Not Found</h1>
       <p>The page you're looking for doesn't exist.</p>
       <a href="{{ url_for('public.index') }}">Return to Home</a>
   </div>
   {% endblock %}
   ```

3. **Create a new file** named `500.html`:

   > `app/presentation/templates/errors/500.html`

   ```html
   {% extends "base.html" %}
   {% block title %}Server Error - News Flash{% endblock %}
   {% block content %}
   <div class="error-page">
       <h1>500 - Server Error</h1>
       <p>Something went wrong. Please try again later.</p>
       <a href="{{ url_for('public.index') }}">Return to Home</a>
   </div>
   {% endblock %}
   ```

4. **Open** `app/__init__.py`

5. **Add** the following error handlers inside `create_app()`:

   > `app/__init__.py`

   ```python
   @app.errorhandler(404)
   def not_found_error(error):
       return render_template("errors/404.html"), 404

   @app.errorhandler(500)
   def internal_error(error):
       db.session.rollback()
       return render_template("errors/500.html"), 500
   ```

> ℹ **Concept Deep Dive**
>
> Flask's `@app.errorhandler` decorator registers a function that handles a specific HTTP error code. When Flask encounters a 404 (page not found) or 500 (internal server error), it calls the registered function instead of showing the default error page.
>
> The 500 handler calls `db.session.rollback()` because a database error may have caused the 500. Without the rollback, the SQLAlchemy session remains in a broken state and any subsequent database operations in the same request would fail. This is a defensive measure -- even if the error was not database-related, calling rollback on a clean session is harmless.
>
> Notice the return tuple `render_template("errors/404.html"), 404`. The second value is the HTTP status code. Without it, Flask would return a 200 (OK) status for the error page, which confuses browsers and search engines.
>
> Both templates extend `base.html` so the error pages include the site navigation, header, and footer. This keeps the user experience consistent -- they can navigate away from the error page using the normal site navigation.
>
> ⚠ **Common Mistakes**
>
> - Forgetting the status code in the return tuple (`, 404`) causes the error page to return HTTP 200
> - Registering error handlers outside `create_app()` means they will not be active
> - Not extending `base.html` leaves the error page without navigation, stranding the user
> - Forgetting `db.session.rollback()` in the 500 handler can cause cascading database errors
>
> ✓ **Quick check:** Both error templates created in `app/presentation/templates/errors/` and handlers registered in `create_app()`

### **Step 4:** Test Security Headers

Verify that the security headers are present on every HTTP response from your application. This confirms the `after_request` handler is working correctly.

1. **Start the application:**

   ```bash
   flask run
   ```

2. **Open** browser developer tools (F12) and navigate to the **Network** tab

3. **Load** any page (e.g., `http://localhost:5000/`)

4. **Click** on the request in the Network tab and inspect the **Response Headers**

5. **Verify** the following headers are present:

   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: SAMEORIGIN`
   - `X-XSS-Protection: 1; mode=block`
   - `Referrer-Policy: strict-origin-when-cross-origin`
   - `Strict-Transport-Security` should **NOT** be present (because debug mode is on)

6. **Alternatively**, test with `curl`:

   ```bash
   curl -I http://localhost:5000/
   ```

   The output should include all four security headers in the response.

> ✓ **Quick check:** All four security headers appear in the response. HSTS is absent in development mode.

### **Step 5:** Test CLI and Error Pages

Verify the CLI command works for all scenarios (success, duplicate, short password) and that custom error pages render correctly.

1. **Test CLI with password option:**

   ```bash
   flask create-admin admin -p SecurePass1
   ```

   Expected output: `Admin user 'admin' created successfully.`

2. **Test CLI with interactive prompt:**

   ```bash
   flask create-admin webmaster
   ```

   The command will prompt you to enter and confirm the password interactively.

3. **Test duplicate username:**

   ```bash
   flask create-admin admin -p AnotherPass1
   ```

   Expected output: `Error: Username 'admin' already exists.`

4. **Test short password:**

   ```bash
   flask create-admin shortpw -p "abc"
   ```

   Expected output: `Error: Password must be at least 8 characters long.`

5. **Test custom 404 page:**
   - **Navigate to** `http://localhost:5000/nonexistent`
   - Verify the custom 404 page appears with site navigation and a "Return to Home" link

6. **Test end-to-end login:**
   - **Log in** with the admin user created via CLI to verify the account works through the web interface

> ✓ **Success indicators:**
>
> - All four security headers present on every response
> - HSTS is NOT present in development mode
> - CLI creates admin users successfully with both inline and interactive passwords
> - CLI rejects passwords shorter than 8 characters
> - CLI rejects duplicate usernames with a clear error message
> - Custom 404 page renders with consistent site styling and navigation
> - Admin user created via CLI can log in through the web interface
>
> ✓ **Final verification checklist:**
>
> - [ ] `add_security_headers` registered inside `create_app()` as `@app.after_request`
> - [ ] `app/cli.py` created with `create-admin` command
> - [ ] CLI command registered with `app.cli.add_command()`
> - [ ] `errors/404.html` and `errors/500.html` templates created
> - [ ] Error handlers registered inside `create_app()`
> - [ ] Security headers visible in browser developer tools or curl output
> - [ ] CLI handles success, duplicate, and validation cases correctly
> - [ ] Custom 404 page displays when visiting a non-existent URL

## Common Issues

> **If you encounter problems:**
>
> **Headers not showing in browser:** Ensure `add_security_headers` is registered inside `create_app()` with the `@app.after_request` decorator. The function must return the `response` object.
>
> **"Error: No such command 'create-admin'":** Register the command with `app.cli.add_command(create_admin_command)` inside `create_app()` in `app/__init__.py`. Verify the import path is correct.
>
> **CLI password prompt not working:** The `click` library is included with Flask -- no separate installation is needed. If the prompt does not appear, check that `password is None` evaluates correctly when no `-p` flag is provided.
>
> **404 page shows default Flask page:** Register the error handler with `@app.errorhandler(404)` inside `create_app()`. Verify the template exists at `app/presentation/templates/errors/404.html`.
>
> **"RuntimeError: Working outside of application context":** Ensure the CLI command function has the `@with_appcontext` decorator.
>
> **Still stuck?** Test each component independently. Start with `curl -I http://localhost:5000/` to check headers, then `flask create-admin --help` to verify the CLI command is registered, then visit a non-existent URL to test error pages.

## Summary

You've successfully hardened your News Flash application which:

- ✓ Added OWASP-recommended security headers to all HTTP responses
- ✓ Created a CLI command for secure admin user management
- ✓ Built custom error pages that match the site design and prevent information leakage
- ✓ Implemented layered security across middleware, authentication, and error handling

> **Key takeaway:** Security is layered -- no single measure is sufficient. Headers protect against browser-level attacks (clickjacking, MIME sniffing, XSS). Authentication protects routes from unauthorized access. CLI commands enable secure admin setup without exposing a web registration form. Custom error pages prevent information leakage from default error messages that may reveal stack traces, file paths, or framework versions.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a `Content-Security-Policy` header to prevent inline script injection (XSS)
> - Implement rate limiting on the login route to prevent brute-force attacks
> - Add logging for security events (failed logins, admin creation attempts)
> - Research Flask-Talisman for comprehensive security header management

## Done! 🎉

You have completed the Authentication and Security exercise series. Your News Flash application now has user authentication, protected admin routes, security headers, custom error pages, and CLI tooling for admin management.
