+++
title = "Develop and Run a Flask Application Locally"
description = "Set up and run a Python web application on your development machine"
weight = 1
+++

# Develop and Run a Flask Application Locally

## Goal

Set up a Python virtual environment and run a Flask contact form application on your local machine.

> **What you'll learn:**
>
> - How to create and activate a Python virtual environment
> - How to install dependencies from a requirements file
> - How to run a Flask application in development mode

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Python 3.11 or later installed on your machine
> - ✓ A workspace directory for your projects
> - ✓ Terminal (macOS/Linux) or Git Bash (Windows)

## Exercise Steps

### Overview

1. **Create the Project Directory**
2. **Create the Application File**
3. **Set Up the Virtual Environment**
4. **Install Dependencies and Run**

### **Step 1:** Create the Project Directory

Organize your work by creating a dedicated directory for this project inside your workspace folder.

1. **Open** a terminal (Terminal on macOS/Linux, Git Bash on Windows)

2. **Navigate to** your workspace directory (the folder where you keep your development projects):

   ```bash
   cd ~/your-workspace-directory
   ```

3. **Create** a new project directory:

   ```bash
   mkdir flask-contact-form
   cd flask-contact-form
   ```

> ✓ **Quick check:** Running `pwd` (macOS/Linux) or `cd` (Windows) shows you're in the `flask-contact-form` directory

### **Step 2:** Create the Application File

Create a minimal Flask application that handles three pages:

- **Home page** (`/`) — A welcome page with a link to the contact form
- **Contact form** (`/contact`) — A form for users to submit their name, email, and message
- **Thank you page** — Displayed after successful form submission

The application follows the **POST-Redirect-GET** pattern: when the form is submitted (POST), the server processes the data and returns a new page. This prevents duplicate submissions if the user refreshes the browser—refreshing a POST request would resubmit the form, while refreshing a GET request simply redisplays the page.

The form includes client-side validation using HTML attributes: `required` ensures fields are not empty, and `type="email"` validates the email format before submission. The browser enforces these rules—no server-side validation is implemented in this minimal example.

1. **Create** a new file named `app.py`

2. **Add** the following code:

   > `app.py`

   ```python
   from flask import Flask, request, render_template_string

   app = Flask(__name__)

   HOME_PAGE = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>Welcome</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; text-align: center; }
           h1 { color: #333; }
           a { color: #007bff; text-decoration: none; font-size: 1.2em; }
           a:hover { text-decoration: underline; }
       </style>
   </head>
   <body>
       <h1>Welcome</h1>
       <p>This is a simple Flask application.</p>
       <a href="/contact">Contact Us</a>
   </body>
   </html>
   """

   CONTACT_FORM = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>Contact Us</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
           h1 { color: #333; }
           label { display: block; margin-top: 15px; font-weight: bold; }
           input, textarea { width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box; }
           textarea { height: 100px; }
           button { margin-top: 20px; padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
           button:hover { background: #0056b3; }
       </style>
   </head>
   <body>
       <h1>Contact Us</h1>
       <form method="POST" action="/contact">
           <label for="name">Name:</label>
           <input type="text" id="name" name="name" required>
           <label for="email">Email:</label>
           <input type="email" id="email" name="email" required>
           <label for="message">Message:</label>
           <textarea id="message" name="message" required></textarea>
           <button type="submit">Send Message</button>
       </form>
   </body>
   </html>
   """

   THANK_YOU = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>Thank You</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; text-align: center; }
           h1 { color: #28a745; }
           a { color: #007bff; }
       </style>
   </head>
   <body>
       <h1>Thank You!</h1>
       <p>Thank you for contacting us, {{ name }}.</p>
       <p>We have received your message and will respond to {{ email }} soon.</p>
       <a href="/contact">Send another message</a>
   </body>
   </html>
   """

   @app.route("/")
   def home():
       return render_template_string(HOME_PAGE)

   @app.route("/contact", methods=["GET", "POST"])
   def contact():
       if request.method == "POST":
           name = request.form.get("name")
           email = request.form.get("email")
           message = request.form.get("message")
           print("\n" + "=" * 50)
           print("NEW CONTACT FORM SUBMISSION")
           print("=" * 50)
           print(f"Name:    {name}")
           print(f"Email:   {email}")
           print(f"Message: {message}")
           print("=" * 50 + "\n")
           return render_template_string(THANK_YOU, name=name, email=email)
       return render_template_string(CONTACT_FORM)

   if __name__ == "__main__":
       app.run(host="0.0.0.0", port=5001, debug=True)
   ```

3. **Create** a `requirements.txt` file with the following content:

   > `requirements.txt`

   ```text
   flask
   gunicorn
   ```

> ℹ **Concept Deep Dive**
>
> **Flask** is a web framework that adds HTTP handling capabilities to Python. Python alone cannot listen for web requests or send HTTP responses—Flask provides this functionality. When you write `app = Flask(__name__)`, you create a web application object that can receive requests from browsers and return HTML responses.
>
> The `@app.route("/")` decorator tells Flask which function to call when a browser requests a specific URL path. Flask handles the HTTP protocol details: parsing incoming requests, extracting form data, and formatting responses with correct headers.
>
> The `render_template_string()` function processes Jinja2 template syntax (like `{{ name }}`) and replaces placeholders with actual values. This is **server-side rendering**—the HTML is constructed on the server before being sent to the browser.
>
> The `requirements.txt` file lists Python packages your project needs. When you share your project or deploy it, others can install all dependencies with a single command.
>
> **Gunicorn** is included for server deployment. During local development, you won't use it—Flask's built-in development server is sufficient. But when you deploy to a server, Gunicorn provides a production-ready application server that can handle multiple concurrent requests.
>
> ✓ **Quick check:** Your project directory contains both `app.py` and `requirements.txt`

### **Step 3:** Set Up the Virtual Environment

A virtual environment isolates your project's Python packages from other projects and from the system Python. This prevents version conflicts between projects.

1. **Create** a virtual environment named `venv`:

   ```bash
   python3 -m venv venv
   ```

   > On Windows, use `python` instead of `python3` if that's how Python is installed.

2. **Activate** the virtual environment:

   **macOS/Linux:**

   ```bash
   source venv/bin/activate
   ```

   **Windows (Git Bash):**

   ```bash
   source venv/Scripts/activate
   ```

3. **Verify** activation by checking your prompt:

   Your terminal prompt should now show `(venv)` at the beginning:

   ```text
   (venv) ~/Developer/flask-contact-form $
   ```

> ℹ **Concept Deep Dive**
>
> A **virtual environment** is an isolated Python installation within your project directory. Without it, all Python packages install globally—meaning every project on your machine shares the same packages. This causes problems when different projects need different versions of the same package.
>
> The `python3 -m venv venv` command creates a `venv/` directory containing:
>
> - A copy of the Python interpreter
> - Its own `pip` package manager
> - An empty `site-packages/` directory for installed packages
>
> When activated, the virtual environment modifies your PATH so that `python` and `pip` commands use the versions inside `venv/` rather than system-wide installations. Packages installed with `pip` go into the virtual environment only, keeping your project's dependencies separate from other projects.
>
> This isolation is essential for reproducible deployments. When you deploy to a server, you create a virtual environment there too, ensuring the same package versions run in production as in development. To exit the virtual environment later, run `deactivate`.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to activate before installing packages installs them system-wide
> - Using the wrong activation path (`venv/bin/` on macOS/Linux vs `venv/Scripts/` on Windows)
>
> ✓ **Quick check:** Your prompt shows `(venv)` and `which python` (macOS/Linux) or `where python` (Windows) points to the venv directory

### **Step 4:** Install Dependencies and Run

With the virtual environment active, install Flask and start the development server.

1. **Install** the required packages:

   ```bash
   pip install -r requirements.txt
   ```

2. **Run** the Flask application:

   ```bash
   python app.py
   ```

3. **Observe** the startup output:

   ```text
    * Debug mode: on
    * Running on http://127.0.0.1:5001
   Press CTRL+C to quit
   ```

4. **Open** your web browser and navigate to:

   ```text
   http://localhost:5001/
   ```

5. **Test** the contact form:
   - Fill in all fields
   - Click "Send Message"
   - Verify the thank you page appears
   - Check your terminal for the printed form data

6. **Stop** the server when finished:
   - Press `Ctrl+C` in the terminal

> ✓ **Success indicators:**
>
> - Flask starts without errors
> - Contact form loads in browser
> - Form submission shows thank you page
> - Form data prints to terminal
>
> ✓ **Final verification checklist:**
>
> - ☐ Virtual environment created and activated
> - ☐ Flask installed in virtual environment
> - ☐ Application runs with `python app.py`
> - ☐ Browser can access the contact form
> - ☐ Form submission works correctly

## Common Issues

> **If you encounter problems:**
>
> **"python3: command not found":** On Windows, try `python` instead of `python3`
>
> **"No module named flask":** Ensure virtual environment is activated (prompt shows `(venv)`)
>
> **Port already in use:** Another application is using port 5001—stop it or change the port in `app.py`
>
> **Still stuck?** Delete the `venv` folder and repeat Step 3 to create a fresh environment

## Summary

You've successfully set up a local Flask development environment which:

- ✓ Uses a virtual environment to isolate dependencies
- ✓ Installs packages from a requirements file
- ✓ Runs a Flask application in debug mode

> **Key takeaway:** Virtual environments keep project dependencies separate and reproducible. Always activate the environment before working on your project, and always use `requirements.txt` to track dependencies.

## Done! 🎉

Great work! You now have a working Flask application running locally. This same application can later be deployed to a server using Gunicorn for production use.
