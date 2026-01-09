"""Registration form with validation."""
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired, Email, Length


class RegistrationForm(FlaskForm):
    """Form for webinar registration with validation.

    Validates:
    - name: 2-100 characters, required
    - email: valid email format, required
    - company: 2-100 characters, required
    - job_title: 2-100 characters, required
    """

    name = StringField('Full Name', validators=[
        DataRequired(message='Name is required.'),
        Length(min=2, max=100, message='Name must be between 2 and 100 characters.')
    ])

    email = StringField('Email Address', validators=[
        DataRequired(message='Email is required.'),
        Email(message='Please enter a valid email address.'),
        Length(max=120, message='Email must be less than 120 characters.')
    ])

    company = StringField('Company', validators=[
        DataRequired(message='Company is required.'),
        Length(min=2, max=100, message='Company must be between 2 and 100 characters.')
    ])

    job_title = StringField('Job Title', validators=[
        DataRequired(message='Job title is required.'),
        Length(min=2, max=100, message='Job title must be between 2 and 100 characters.')
    ])

    submit = SubmitField('Complete Registration')
