"""Flask CLI commands for application management."""
import click
from flask.cli import with_appcontext
from app.extensions import db
from app.services.auth_service import AuthService, DuplicateUsernameError


@click.command('init-db')
@with_appcontext
def init_db_command():
    """Initialize the database by creating all tables.

    This command creates all database tables defined in the models.
    Safe to run multiple times - existing tables are not modified.

    Example usage:
        flask init-db
    """
    db.create_all()
    click.echo('Database tables created successfully.')


@click.command('create-admin')
@click.argument('username')
@click.option('--password', '-p', default=None,
              help='Admin password (minimum 8 characters). If not provided, will prompt.')
@with_appcontext
def create_admin_command(username, password):
    """Create a new admin user.

    USERNAME: The username for the new admin account.

    The password can be provided via --password/-p option for non-interactive use,
    or will be prompted securely (hidden input with confirmation) if not provided.
    Minimum password length is 8 characters.

    Example usage:
        flask create-admin admin
        flask create-admin admin --password MySecurePass123!
        flask create-admin webmaster -p MySecurePass123!
    """
    # Prompt for password if not provided
    if password is None:
        password = click.prompt('Password', hide_input=True, confirmation_prompt=True)

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
    app.cli.add_command(init_db_command)
    app.cli.add_command(create_admin_command)
