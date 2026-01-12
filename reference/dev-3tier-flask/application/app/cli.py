"""Flask CLI commands for application management."""
import click
from flask.cli import with_appcontext
from app.services.auth_service import AuthService, DuplicateUsernameError


@click.command('create-admin')
@click.argument('username')
@click.option('--password', prompt=True, hide_input=True,
              confirmation_prompt=True, help='Admin password (minimum 8 characters)')
@with_appcontext
def create_admin_command(username, password):
    """Create a new admin user.

    USERNAME: The username for the new admin account.

    The password will be prompted securely (hidden input with confirmation).
    Minimum password length is 8 characters.

    Example usage:
        flask create-admin admin
        flask create-admin webmaster
    """
    # Validate password length
    if len(password) < 8:
        click.echo('Error: Password must be at least 8 characters long.', err=True)
        raise SystemExit(1)

    try:
        user = AuthService.create_user(username, password)
        click.echo(f"Admin user '{user.username}' created successfully.")
    except DuplicateUsernameError:
        click.echo(f"Error: Username '{username}' already exists.", err=True)
        raise SystemExit(1)


def register_commands(app):
    """Register CLI commands with the Flask application."""
    app.cli.add_command(create_admin_command)
