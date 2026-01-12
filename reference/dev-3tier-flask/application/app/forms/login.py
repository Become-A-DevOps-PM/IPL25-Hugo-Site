"""Login form with validation."""
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Length


class LoginForm(FlaskForm):
    """Form for admin login with validation.

    Validates:
    - username: required, 1-80 characters
    - password: required, minimum 1 character
    - remember_me: optional checkbox
    """

    username = StringField('Username', validators=[
        DataRequired(message='Username is required.'),
        Length(min=1, max=80, message='Username must be between 1 and 80 characters.')
    ])

    password = PasswordField('Password', validators=[
        DataRequired(message='Password is required.')
    ])

    remember_me = BooleanField('Remember Me')

    submit = SubmitField('Log In')
