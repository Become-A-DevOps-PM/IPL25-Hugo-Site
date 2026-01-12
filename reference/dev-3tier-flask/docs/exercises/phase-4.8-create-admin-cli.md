# Admin Creation CLI Command

## Goal

Add a `flask create-admin` CLI command for creating admin users, enabling Infrastructure as Code (IaC) compatible deployment.

> **What you'll learn:**
>
> - Creating custom Flask CLI commands with Click
> - Interactive password input with confirmation
> - The @with_appcontext decorator
> - IaC-compatible user provisioning

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.7 (Security Headers)
> - ✓ All 113 tests passing
> - ✓ Understanding of command-line interfaces

## Exercise Steps

### Overview

1. **Create CLI Module**
2. **Register CLI Commands**
3. **Add CLI Runner Test Fixture**
4. **Add CLI Tests**
5. **Verify with pytest**

### **Step 1:** Create CLI Module

Create a dedicated module for Flask CLI commands.

1. **Create** `application/app/cli.py`:

   ```python
   """Flask CLI commands for application management."""
   import click
   from flask.cli import with_appcontext


   @click.command('create-admin')
   @click.argument('username')
   @click.option('--password', prompt=True, hide_input=True,
                 confirmation_prompt=True, help='Admin password')
   @with_appcontext
   def create_admin_command(username, password):
       """Create a new admin user.

       Usage: flask create-admin USERNAME

       You will be prompted for a password (hidden input).
       Password must be at least 8 characters.

       Example:
           flask create-admin admin
       """
       from app.services.auth_service import AuthService, DuplicateUsernameError

       # Validate password length
       if len(password) < 8:
           click.echo('Error: Password must be at least 8 characters.')
           return

       try:
           user = AuthService.create_user(username, password)
           click.echo(f'Admin user "{user.username}" created successfully.')
       except DuplicateUsernameError:
           click.echo(f'Error: Username "{username}" already exists.')


   def register_cli_commands(app):
       """Register CLI commands with the Flask application.

       Args:
           app: The Flask application instance.
       """
       app.cli.add_command(create_admin_command)
   ```

> ℹ **Concept Deep Dive**
>
> - **@click.command('create-admin')** defines the command name
> - **@click.argument('username')** makes username a required positional argument
> - **@click.option('--password', prompt=True)** prompts for password if not provided
> - **hide_input=True** masks password input (shows dots/nothing)
> - **confirmation_prompt=True** asks user to type password twice
> - **@with_appcontext** ensures app context exists for database operations
> - **click.echo()** outputs to console (preferred over print in CLI)
>
> **Why CLI for Admin Creation:**
> - Enables automated deployment scripts
> - No need to expose admin creation via web routes
> - Works in production without web interface access
> - Secure: password never transmitted over network
>
> ⚠ **Common Mistakes**
>
> - Forgetting @with_appcontext (database won't work)
> - Using print instead of click.echo (less compatible)
> - Not validating password before creating user
>
> ✓ **Quick check:** create-admin command with password prompt and validation

### **Step 2:** Register CLI Commands

Add CLI registration to the application factory.

1. **Open** `application/app/__init__.py`

2. **Add** CLI registration before the return statement:

   ```python
       # Register CLI commands
       from app.cli import register_cli_commands
       register_cli_commands(app)

       return app
   ```

The full `create_app` function should now end with:

```python
    # Register error handlers
    register_error_handlers(app)

    # Register security headers
    register_security_headers(app)

    # Register CLI commands
    from app.cli import register_cli_commands
    register_cli_commands(app)

    return app
```

> ✓ **Quick check:** CLI commands registered in application factory

### **Step 3:** Add CLI Runner Test Fixture

Add a fixture for testing CLI commands.

1. **Open** `application/tests/conftest.py`

2. **Add** the following fixture:

   ```python
   @pytest.fixture
   def runner(app):
       """Create a CLI test runner."""
       return app.test_cli_runner()
   ```

> ℹ **Concept Deep Dive**
>
> - **test_cli_runner()** creates a Click test runner bound to the Flask app
> - Enables invoking CLI commands in tests without subprocess
> - Captures command output for assertions
>
> ✓ **Quick check:** runner fixture returns CLI test runner

### **Step 4:** Add CLI Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestCreateAdminCLI:
       """Tests for the create-admin CLI command."""

       def test_create_admin_command_exists(self, runner):
           """Test that create-admin command is registered."""
           result = runner.invoke(args=['create-admin', '--help'])
           assert result.exit_code == 0
           assert 'Create a new admin user' in result.output

       def test_create_admin_success(self, app, runner):
           """Test successful admin user creation via CLI."""
           result = runner.invoke(
               args=['create-admin', 'cliadmin'],
               input='validpassword123\nvalidpassword123\n'
           )
           assert 'created successfully' in result.output

           # Verify user exists in database
           with app.app_context():
               from app.services.auth_service import AuthService
               user = AuthService.get_user_by_username('cliadmin')
               assert user is not None

       def test_create_admin_duplicate_username(self, app, runner):
           """Test that duplicate username shows error."""
           # Create first user
           runner.invoke(
               args=['create-admin', 'duplicate'],
               input='password12345678\npassword12345678\n'
           )

           # Try to create duplicate
           result = runner.invoke(
               args=['create-admin', 'duplicate'],
               input='password12345678\npassword12345678\n'
           )
           assert 'already exists' in result.output

       def test_create_admin_short_password(self, runner):
           """Test that short password is rejected."""
           result = runner.invoke(
               args=['create-admin', 'shortpass'],
               input='short\nshort\n'
           )
           assert 'at least 8 characters' in result.output

       def test_created_admin_can_login(self, app, runner, client):
           """Test that CLI-created admin can log in."""
           runner.invoke(
               args=['create-admin', 'loginableadmin'],
               input='securepassword123\nsecurepassword123\n'
           )

           response = client.post('/auth/login', data={
               'username': 'loginableadmin',
               'password': 'securepassword123'
           }, follow_redirects=False)

           assert response.status_code == 302
           assert '/admin/attendees' in response.location
   ```

> ℹ **Concept Deep Dive**
>
> - **runner.invoke()** executes CLI commands programmatically
> - **input='password\npassword\n'** simulates user typing password + confirmation
> - **result.output** contains stdout from the command
> - **result.exit_code** should be 0 for success
> - End-to-end test verifies CLI user can login via web
>
> ✓ **Quick check:** 5 new tests for CLI command functionality

### **Step 5:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 113 + 5 = 118 tests passing

3. **Test** CLI manually:

   ```bash
   flask create-admin --help
   # Output shows command usage

   flask create-admin admin
   # Prompts for password (hidden)
   # Prompts for confirmation
   # Shows success message
   ```

> ✓ **Success indicators:**
>
> - All 118 tests pass
> - CLI command creates admin users
> - Password validation enforced
> - Created users can log in

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `app/cli.py` exists with create_admin_command
> - ☐ Command uses @click.command('create-admin')
> - ☐ Password prompt with hidden input and confirmation
> - ☐ Password minimum length (8 chars) validated
> - ☐ Duplicate username error handled gracefully
> - ☐ CLI registered in application factory
> - ☐ `conftest.py` has runner fixture
> - ☐ `pytest tests/test_routes.py -v` passes (118 tests)

## Common Issues

> **If you encounter problems:**
>
> **Command not found:** Ensure register_cli_commands() called in create_app()
>
> **Database error:** Verify @with_appcontext decorator is present
>
> **Input not working in tests:** Use `input='password\npassword\n'` with newlines
>
> **Exit code non-zero:** Check click.echo vs raise exception behavior

## Summary

You've implemented the admin creation CLI:

- ✓ flask create-admin command for user provisioning
- ✓ Secure password input with confirmation prompt
- ✓ Password validation (minimum 8 characters)
- ✓ Duplicate username error handling
- ✓ IaC-compatible deployment support
- ✓ 5 new tests verify CLI functionality

> **Key takeaway:** CLI commands enable Infrastructure as Code deployment. Admin users can be created during automated deployments without exposing admin creation via web routes, improving security and enabling reproducible infrastructure.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add flask delete-admin command
> - Implement flask list-admins for user management
> - Add password change command with old password verification

## Done!

Phase 4 is now complete! You have implemented a full authentication system:

- User model with secure password hashing
- Authentication service layer
- Flask-Login session management
- Login form with validation
- Auth blueprint with login/logout routes
- Protected admin routes
- Security headers middleware
- CLI command for admin creation

The application now has 118 tests and is ready for production deployment.
