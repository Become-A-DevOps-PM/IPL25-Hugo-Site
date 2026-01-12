"""Business logic for user authentication."""
from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.user import User


class DuplicateUsernameError(Exception):
    """Raised when attempting to create user with existing username."""
    pass


class AuthService:
    """Service layer for authentication operations."""

    @staticmethod
    def authenticate(username, password):
        """Authenticate user by username and password.

        Args:
            username: User's username
            password: Plain text password to verify

        Returns:
            User: The authenticated user, or None if authentication fails
        """
        user = User.query.filter_by(username=username).first()
        if user and user.is_active and user.check_password(password):
            return user
        return None

    @staticmethod
    def create_user(username, password):
        """Create a new admin user.

        Args:
            username: Unique username for the admin
            password: Plain text password (will be hashed)

        Returns:
            User: The created user object

        Raises:
            DuplicateUsernameError: If username already exists
        """
        user = User(username=username)
        user.set_password(password)
        try:
            db.session.add(user)
            db.session.commit()
            return user
        except IntegrityError:
            db.session.rollback()
            raise DuplicateUsernameError(f"Username '{username}' already exists.")

    @staticmethod
    def get_user_by_id(user_id):
        """Get user by ID for Flask-Login.

        Args:
            user_id: User's database ID

        Returns:
            User: The user object, or None if not found
        """
        return db.session.get(User, int(user_id))

    @staticmethod
    def get_user_by_username(username):
        """Get user by username.

        Args:
            username: User's username

        Returns:
            User: The user object, or None if not found
        """
        return User.query.filter_by(username=username).first()
