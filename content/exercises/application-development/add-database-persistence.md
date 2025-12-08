+++
title = "Add Database Persistence"
description = "Store contact form submissions in a database using SQLAlchemy"
weight = 3
+++

# Add Database Persistence

## Goal

Store contact form submissions in a database so they persist across application restarts.

> **What you'll learn:**
>
> - How to use SQLAlchemy as an Object-Relational Mapper (ORM)
> - How to create database models in Python
> - How to configure database connections using environment variables
> - How to perform basic database operations (Create, Read)

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed the local Flask application setup
> - ✓ Python 3.11 or later with virtual environment activated
> - ✓ The contact form application running locally

## Exercise Steps

### Overview

1. **Add SQLAlchemy Dependencies**
2. **Configure the Database Connection**
3. **Create the Message Model**
4. **Update the Contact Route to Save Messages**
5. **Add a Messages Display Page**
6. **Test Your Implementation**

### **Step 1:** Add SQLAlchemy Dependencies

Flask-SQLAlchemy provides a simple integration between Flask and SQLAlchemy, the most popular Python ORM. Adding this dependency enables your application to interact with databases using Python objects instead of raw SQL queries.

1. **Open** the `requirements.txt` file in your project directory

2. **Add** the following line:

   > `requirements.txt`

   ```text
   flask
   gunicorn
   flask-sqlalchemy
   ```

3. **Install** the new dependency:

   ```bash
   pip install -r requirements.txt
   ```

> ℹ **Concept Deep Dive**
>
> SQLAlchemy is an Object-Relational Mapper (ORM) that translates between Python objects and database tables. Instead of writing SQL queries like `INSERT INTO messages (name, email) VALUES ('John', 'john@example.com')`, you write Python code like `db.session.add(message)`. The ORM handles the translation.
>
> Flask-SQLAlchemy is a Flask extension that simplifies SQLAlchemy setup. It provides sensible defaults and integrates with Flask's application context, making database operations cleaner.
>
> ✓ **Quick check:** Running `pip list` shows `Flask-SQLAlchemy` in the installed packages

### **Step 2:** Configure the Database Connection

Set up SQLAlchemy to use SQLite by default, with the ability to switch databases using an environment variable. This pattern allows the same code to use SQLite locally and PostgreSQL in production.

1. **Open** `app.py` in your project directory

2. **Add** the following imports at the top of the file:

   > `app.py`

   ```python
   import os
   from datetime import datetime
   from flask import Flask, request, render_template_string
   from flask_sqlalchemy import SQLAlchemy
   ```

3. **Add** the database configuration after `app = Flask(__name__)`:

   > `app.py`

   ```python
   app = Flask(__name__)

   # Database configuration - uses SQLite by default, can be overridden with DATABASE_URL
   app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
       'DATABASE_URL',
       'sqlite:///messages.db'
   )
   app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

   db = SQLAlchemy(app)
   ```

> ℹ **Concept Deep Dive**
>
> The `os.environ.get('DATABASE_URL', 'sqlite:///messages.db')` pattern provides a default value while allowing environment-based configuration. When `DATABASE_URL` is not set, the application uses SQLite. In production, you set `DATABASE_URL` to point to PostgreSQL.
>
> SQLite stores the entire database in a single file (`messages.db`). The `sqlite:///` prefix (three slashes) indicates a relative path from the application directory. This makes SQLite perfect for development—no server to install or configure.
>
> `SQLALCHEMY_TRACK_MODIFICATIONS = False` disables a feature that uses extra memory. Flask-SQLAlchemy recommends disabling it unless you specifically need modification tracking.
>
> ⚠ **Common Mistakes**
>
> - Using `sqlite://` (two slashes) instead of `sqlite:///` (three slashes) causes path errors
> - Forgetting to import `os` when using environment variables
> - Placing the configuration after route definitions can cause initialization errors
>
> ✓ **Quick check:** No import errors when running `python app.py`

### **Step 3:** Create the Message Model

Define a Python class that represents the database table structure. SQLAlchemy uses this model to create the table and map database rows to Python objects.

1. **Add** the Message model after the database configuration:

   > `app.py`

   ```python
   class Message(db.Model):
       """Stores contact form submissions."""
       id = db.Column(db.Integer, primary_key=True)
       name = db.Column(db.String(100), nullable=False)
       email = db.Column(db.String(120), nullable=False)
       message = db.Column(db.Text, nullable=False)
       created_at = db.Column(db.DateTime, default=datetime.utcnow)

       def __repr__(self):
           return f'<Message from {self.name}>'
   ```

2. **Add** the database initialization code before the route definitions:

   > `app.py`

   ```python
   # Create tables if they don't exist
   with app.app_context():
       db.create_all()
   ```

> ℹ **Concept Deep Dive**
>
> Each class attribute with `db.Column()` becomes a column in the database table. SQLAlchemy infers the table name from the class name (`Message` becomes `message` table).
>
> - `primary_key=True` makes `id` auto-increment and unique
> - `nullable=False` means the field is required (NOT NULL in SQL)
> - `db.String(100)` limits text length; `db.Text` allows unlimited length
> - `default=datetime.utcnow` automatically sets the timestamp when a record is created
>
> The `db.create_all()` command creates all tables that don't exist. It's safe to run multiple times—it won't modify existing tables or delete data.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `app.app_context()` causes "Working outside of application context" error
> - Using `datetime.utcnow()` (with parentheses) as default calls the function once at startup, not per-record
> - Not inheriting from `db.Model` means SQLAlchemy won't recognize the class as a model
>
> ✓ **Quick check:** Running `python app.py` creates a `messages.db` file in your project directory

### **Step 4:** Update the Contact Route to Save Messages

Modify the contact form handler to save submissions to the database instead of just printing them to the console.

1. **Locate** the `contact()` function in `app.py`

2. **Replace** the existing function with:

   > `app.py`

   ```python
   @app.route("/contact", methods=["GET", "POST"])
   def contact():
       if request.method == "POST":
           name = request.form.get("name")
           email = request.form.get("email")
           message_text = request.form.get("message")

           # Save to database
           new_message = Message(
               name=name,
               email=email,
               message=message_text
           )
           db.session.add(new_message)
           db.session.commit()

           print("\n" + "=" * 50)
           print("NEW CONTACT FORM SUBMISSION (saved to database)")
           print("=" * 50)
           print(f"Name:    {name}")
           print(f"Email:   {email}")
           print(f"Message: {message_text}")
           print("=" * 50 + "\n")

           return render_template_string(THANK_YOU, name=name, email=email)
       return render_template_string(CONTACT_FORM)
   ```

> ℹ **Concept Deep Dive**
>
> The database operation follows a pattern: create object, add to session, commit. The **session** is a staging area that tracks changes. Nothing is written to the database until `commit()` is called. This allows you to make multiple changes and save them as a single transaction.
>
> We renamed `message` to `message_text` to avoid confusion with the `Message` model class. Variable naming clarity prevents bugs.
>
> The `print()` statements remain for debugging visibility—you can see submissions in the terminal and verify they're being saved.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `db.session.commit()` means data is never saved
> - Using the same name for the variable and the model class causes shadowing bugs
> - Not handling database errors can crash the application (we'll add error handling later)
>
> ✓ **Quick check:** Submitting the form no longer loses data after restarting the server

### **Step 5:** Add a Messages Display Page

Create a new route that displays all stored messages, demonstrating the Read operation and confirming data persistence.

1. **Add** the messages template after your existing templates:

   > `app.py`

   ```python
   MESSAGES_PAGE = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>All Messages</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 700px; margin: 50px auto; padding: 20px; }
           h1 { color: #333; }
           .message { border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 5px; }
           .message h3 { margin: 0 0 10px 0; color: #007bff; }
           .message p { margin: 5px 0; }
           .meta { color: #666; font-size: 0.9em; }
           a { color: #007bff; }
           .empty { color: #666; font-style: italic; }
       </style>
   </head>
   <body>
       <h1>All Messages</h1>
       <p><a href="/">Home</a> | <a href="/contact">Send a message</a></p>
       {% if messages %}
           {% for msg in messages %}
           <div class="message">
               <h3>{{ msg.name }}</h3>
               <p><strong>Email:</strong> {{ msg.email }}</p>
               <p>{{ msg.message }}</p>
               <p class="meta">Received: {{ msg.created_at.strftime('%Y-%m-%d %H:%M') }}</p>
           </div>
           {% endfor %}
       {% else %}
           <p class="empty">No messages yet. <a href="/contact">Send the first one!</a></p>
       {% endif %}
   </body>
   </html>
   """
   ```

2. **Add** the route to display messages:

   > `app.py`

   ```python
   @app.route("/messages")
   def messages():
       all_messages = Message.query.order_by(Message.created_at.desc()).all()
       return render_template_string(MESSAGES_PAGE, messages=all_messages)
   ```

3. **Update** the home page template to include a link to messages:

   > `app.py`

   ```python
   HOME_PAGE = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>Welcome</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; text-align: center; }
           h1 { color: #333; }
           a { color: #007bff; text-decoration: none; font-size: 1.2em; margin: 0 10px; }
           a:hover { text-decoration: underline; }
       </style>
   </head>
   <body>
       <h1>Welcome</h1>
       <p>This is a simple Flask application with database persistence.</p>
       <p>
           <a href="/contact">Contact Us</a>
           <a href="/messages">View Messages</a>
       </p>
   </body>
   </html>
   """
   ```

> ℹ **Concept Deep Dive**
>
> `Message.query` provides access to SQLAlchemy's query interface. The `.order_by(Message.created_at.desc())` sorts results by newest first. The `.all()` method executes the query and returns a list of Message objects.
>
> Jinja2 templates (the `{% %}` and `{{ }}` syntax) allow Python-like logic in HTML. The `for` loop iterates through messages, and `strftime` formats the datetime for display.
>
> ⚠ **Common Mistakes**
>
> - Using `.first()` instead of `.all()` returns only one record
> - Forgetting `.all()` returns a query object, not results
> - Template syntax errors (missing `%` or `}`) cause 500 errors
>
> ✓ **Quick check:** Navigating to `/messages` shows an empty state or previously submitted messages

### **Step 6:** Test Your Implementation

Verify that the database persistence works correctly by testing the complete workflow and confirming data survives application restarts.

1. **Run the application:**

   ```bash
   python app.py
   ```

2. **Navigate to:** `http://localhost:5001/`

3. **Test message submission:**

   - Click "Contact Us"
   - Fill in the form with test data
   - Submit the form
   - Verify the thank you page appears

4. **Test message persistence:**

   - Click "View Messages" from the home page
   - Verify your submitted message appears
   - Note the timestamp

5. **Test data survives restart:**

   - Stop the server with `Ctrl+C`
   - Start it again with `python app.py`
   - Navigate to `/messages`
   - **Verify your message is still there**

6. **Submit additional messages:**

   - Submit 2-3 more messages
   - Verify they appear in reverse chronological order

7. **(Optional) Inspect the database in VS Code:**

   - **Install** the "SQLite Viewer" extension by Florian Klampfer from the VS Code marketplace
   - **Open** your project folder in VS Code
   - **Click** on the `messages.db` file in the file explorer
   - **View** the `message` table with all your submitted data
   - You can see columns: id, name, email, message, created_at

> ℹ **Concept Deep Dive**
>
> The SQLite Viewer extension lets you browse SQLite databases directly in VS Code without external tools. This is useful for debugging—you can verify data is being saved correctly, check column values, and understand the database structure.
>
> The `messages.db` file is a standard SQLite database. You can also open it with dedicated tools like DB Browser for SQLite if you prefer a full-featured database GUI.

> ✓ **Success indicators:**
>
> - Messages display at `/messages` endpoint
> - Data persists after server restart
> - Newest messages appear first
> - Timestamps are recorded correctly
> - `messages.db` file exists in your project directory
>
> ✓ **Final verification checklist:**
>
> - ☐ `flask-sqlalchemy` installed in virtual environment
> - ☐ `messages.db` file created automatically
> - ☐ Contact form saves to database
> - ☐ Messages page displays all submissions
> - ☐ Data persists across server restarts

## Common Issues

> **If you encounter problems:**
>
> **"No module named flask_sqlalchemy":** Ensure virtual environment is activated and run `pip install -r requirements.txt`
>
> **"Working outside of application context":** Wrap database operations in `with app.app_context():`
>
> **Messages not saving:** Check that you're calling `db.session.commit()` after `db.session.add()`
>
> **"OperationalError: no such table":** Ensure `db.create_all()` runs before any database operations
>
> **Still stuck?** Delete `messages.db` and restart the application to recreate the database

## Summary

You've successfully added database persistence which:

- ✓ Stores form submissions in a SQLite database
- ✓ Uses SQLAlchemy ORM for database operations
- ✓ Configures database connection via environment variable
- ✓ Displays stored messages on a dedicated page

> **Key takeaway:** The `DATABASE_URL` environment variable pattern allows the same code to work with different databases. Locally, SQLite requires no setup. In production, you set `DATABASE_URL` to point to PostgreSQL—no code changes required.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Inspect the SQLite database using DB Browser for SQLite (<https://sqlitebrowser.org/>)
> - Add a delete button to remove messages
> - Implement pagination for the messages page
> - Add server-side validation before saving to database

## Done! 🎉

Great work! Your application now persists data to a database. This same code will work with PostgreSQL in production by simply changing the `DATABASE_URL` environment variable.
