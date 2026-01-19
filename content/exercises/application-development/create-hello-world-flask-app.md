+++
title = "Create a Hello World Flask Application"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build the simplest possible Flask web application from scratch"
weight = 1
+++

# Create a Hello World Flask Application

## Goal

Build the simplest possible Flask web application to understand the fundamental structure of a Python web app.

> **What you'll learn:**
>
> - How to create a Flask application from scratch
> - The minimal code needed for a working web app
> - How to use virtual environments for Python projects
> - How Flask routes map URLs to Python functions

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Python 3.11 or later installed on your machine
> - ✓ A workspace directory for your projects
> - ✓ Terminal (macOS/Linux) or Git Bash (Windows)

## Exercise Steps

### Overview

1. **Create the Project Directory**
2. **Write the Flask Application**
3. **Create the Requirements File**
4. **Set Up the Virtual Environment**
5. **Test Your Application**

### **Step 1:** Create the Project Directory

Every project needs its own directory to keep files organized. Creating a dedicated folder ensures your project files are isolated and easy to manage.

1. **Open** a terminal (Terminal on macOS/Linux, Git Bash on Windows)

2. **Navigate to** your workspace directory:

   ```bash
   cd ~/your-workspace-directory
   ```

3. **Create** a new directory for your project:

   ```bash
   mkdir hello-flask
   ```

4. **Navigate into** the new directory:

   ```bash
   cd hello-flask
   ```

> ✓ **Quick check:** Running `pwd` should show you are inside the `hello-flask` directory

### **Step 2:** Write the Flask Application

Flask is a lightweight web framework that makes it easy to create web applications with Python. The entire application can be written in just a few lines of code.

1. **Create** a new file named `app.py`

2. **Add** the following code:

   > `app.py`

   ```python
   from flask import Flask

   app = Flask(__name__)


   @app.route('/')
   def hello():
       return 'Hello, World!'


   if __name__ == '__main__':
       app.run(debug=True)
   ```

> ℹ **Concept Deep Dive**
>
> Let's break down what each line does:
>
> - `from flask import Flask` imports the Flask class from the flask package
> - `app = Flask(__name__)` creates a Flask application instance. The `__name__` variable tells Flask where to find resources like templates
> - `@app.route('/')` is a decorator that maps the URL path `/` to the function below it
> - `def hello():` defines the function that handles requests to the root URL
> - `return 'Hello, World!'` sends this text back to the browser
> - The `if __name__ == '__main__':` block runs the development server when you execute the file directly
>
> ⚠ **Common Mistakes**
>
> - Forgetting the `@` symbol before `app.route` will cause the route to not work
> - Using `App` instead of `app` (Python is case-sensitive)
> - Missing the parentheses in `Flask(__name__)`
>
> ✓ **Quick check:** File saved as `app.py` in your project directory

### **Step 3:** Create the Requirements File

A requirements file lists all the Python packages your project needs. This makes it easy to install dependencies and share your project with others.

1. **Create** a new file named `requirements.txt`

2. **Add** the following line:

   > `requirements.txt`

   ```text
   flask
   ```

> ℹ **Concept Deep Dive**
>
> The `requirements.txt` file is a standard way to declare Python dependencies. When you run `pip install -r requirements.txt`, pip reads this file and installs all listed packages. You can also specify versions (e.g., `flask==3.0.0`) to ensure consistent behavior across environments.
>
> ✓ **Quick check:** You should now have two files: `app.py` and `requirements.txt`

### **Step 4:** Set Up the Virtual Environment

A virtual environment isolates your project's Python packages from other projects and from the system Python. This prevents version conflicts between projects.

#### macOS / Linux

1. **Create** a virtual environment:

   ```bash
   python3 -m venv .venv
   ```

2. **Activate** the virtual environment:

   ```bash
   source .venv/bin/activate
   ```

3. **Verify** the virtual environment is active:

   ```bash
   which python
   ```

   This should show a path containing `.venv`

4. **Install** Flask:

   ```bash
   pip install -r requirements.txt
   ```

5. **Run** the application with debug mode:

   ```bash
   flask run --debug
   ```

> **Tip:** If port 5000 is already in use (common on macOS due to AirPlay Receiver), use a different port:
> `flask run --debug --port 5001`

#### Windows

1. **Create** a virtual environment:

   ```cmd
   python -m venv .venv
   ```

2. **Activate** the virtual environment:

   ```cmd
   .venv\Scripts\activate
   ```

3. **Verify** the virtual environment is active:

   ```cmd
   where python
   ```

   This should show a path containing `.venv`

4. **Install** Flask:

   ```cmd
   pip install -r requirements.txt
   ```

5. **Run** the application with debug mode:

   ```cmd
   flask run --debug
   ```

> ℹ **Concept Deep Dive**
>
> The `--debug` flag enables two important features:
>
> - **Hot reload:** The server automatically restarts when you modify the code, so you can see changes immediately without manually restarting
> - **Debug mode:** If an error occurs, Flask shows a detailed error page in the browser to help you diagnose the problem
>
> ⚠ **Common Mistakes**
>
> - Forgetting to activate the virtual environment before running `pip install`
> - Running `flask run` from outside the project directory
> - On macOS, port 5000 may be used by AirPlay Receiver - use `--port 5001` if you get an "Address already in use" error
>
> ✓ **Quick check:** Terminal shows "Running on http://127.0.0.1:5000"

### **Step 5:** Test Your Application

Verify that your Flask application is working correctly by accessing it in a web browser.

1. **Open** your web browser

2. **Navigate to:** `http://localhost:5000` (or `http://localhost:5001` if you used a different port)

3. **Verify** you see the text "Hello, World!" displayed on the page

4. **Test hot reload:**

   - Keep the browser open
   - In your editor, change `'Hello, World!'` to `'Hello, Flask!'` in `app.py`
   - Save the file
   - Refresh the browser
   - Verify the new text appears

5. **Stop the server** by pressing `Ctrl+C` in the terminal

> ✓ **Success indicators:**
>
> - Browser displays "Hello, World!"
> - Changing the code and refreshing shows the updated text
> - No errors in the terminal
>
> ✓ **Final verification checklist:**
>
> - ☐ Project directory contains `app.py` and `requirements.txt`
> - ☐ Virtual environment is created (`.venv` directory exists)
> - ☐ Flask is installed in the virtual environment
> - ☐ Application runs without errors
> - ☐ Browser shows the expected output

## Common Issues

> **If you encounter problems:**
>
> **"flask: command not found":** Make sure your virtual environment is activated (you should see `(.venv)` in your terminal prompt)
>
> **"Address already in use":** Another application is using port 5000. Use `flask run --debug --port 5001` instead
>
> **"ModuleNotFoundError: No module named 'flask'":** You need to install Flask. Run `pip install -r requirements.txt` with the virtual environment activated
>
> **Browser shows "This site can't be reached":** Make sure the Flask server is running and you're using the correct port number
>
> **Still stuck?** Check that you're in the correct directory and that all files are saved

## Summary

You've successfully created a minimal Flask application which:

- ✓ Demonstrates the core structure of a Flask web app
- ✓ Uses virtual environments for dependency isolation
- ✓ Runs with hot reload for efficient development

> **Key takeaway:** A Flask application can be as simple as 10 lines of code. The framework handles all the HTTP complexity, letting you focus on what your application should do. This pattern of routes mapping to functions is fundamental to web development.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try adding a second route (e.g., `/about`) that returns different text
> - Experiment with returning HTML instead of plain text
> - Look up Flask's `render_template` function for using HTML templates
> - Try returning JSON data using `flask.jsonify()`

## Done! 🎉

Excellent work! You've built your first Flask application from scratch. This foundation - creating an app, defining routes, and running a development server - is the basis for every Flask project, no matter how complex.
