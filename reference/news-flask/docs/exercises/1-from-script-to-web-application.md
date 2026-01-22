# From Script to Web Application

## Goal

Transform a simple Python script into a web application using Flask to understand the fundamental difference between programs that run once and programs that respond to HTTP requests.

> **What you'll learn:**
>
> - The difference between a Python script (runs once, prints to terminal) and a web application (runs continuously, responds to HTTP requests)
> - How Flask's `@app.route()` decorator maps URLs to functions
> - The request/response cycle of web applications

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Python 3.11+ installed on your system
> - ✓ A terminal or command prompt
> - ✓ A text editor or IDE (VS Code recommended)

## Exercise Steps

### Overview

1. **Create the Project Directory**
2. **Write a Simple Python Script**
3. **Transform the Script into a Web Application**
4. **Run as a Web Application**
5. **Test Your Implementation**

### **Step 1:** Create the Project Directory

Every project needs a home. Creating a dedicated directory keeps your files organized and makes it easy to manage dependencies later when you add more features. This directory will contain all the code for the News Flash application throughout this exercise series.

1. **Open** your terminal

2. **Create** a new directory for the project:

   ```bash
   mkdir news-flash
   ```

3. **Navigate** into the directory:

   ```bash
   cd news-flash
   ```

> ✓ **Quick check:** You should now be inside the `news-flash` directory

### **Step 2:** Write a Simple Python Script

Before building a web application, let's start with the simplest possible Python program. A script is a program that runs from start to finish and then exits. Understanding this behavior helps you appreciate what makes web applications different.

1. **Create** a new file named `hello.py`

2. **Add** the following code:

   > `hello.py`

   ```python
   print("Hello World")
   ```

3. **Run** the script:

   ```bash
   python hello.py
   ```

4. **Observe** the output:

   ```text
   Hello World
   ```

> ℹ **Concept Deep Dive**
>
> This is the simplest possible Python program. When you run `python hello.py`, Python executes the code from top to bottom, prints "Hello World" to the terminal, and then the program exits. The script runs once and stops - there's no way to interact with it after it finishes.
>
> This "run once and exit" behavior is perfect for automation scripts, data processing, or batch jobs. But for a web application, we need something that keeps running and responds to requests from users.
>
> ✓ **Quick check:** The text "Hello World" appears in your terminal, and then you see your command prompt again (the script has exited)

### **Step 3:** Transform the Script into a Web Application

Now we'll transform this simple script into a web application using Flask. The key difference is that instead of printing to the terminal, we'll return text in response to HTTP requests. Flask will handle all the networking complexity for us.

1. **Create** a requirements file:

   > `requirements.txt`

   ```text
   flask>=3.0.0
   ```

2. **Create** a virtual environment:

   ```bash
   python3 -m venv .venv
   ```

3. **Activate** the virtual environment:

   ```bash
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

   > You'll know it's active when you see `(.venv)` at the start of your terminal prompt.

4. **Install** dependencies:

   ```bash
   pip install -r requirements.txt
   ```

5. **Replace** the contents of `hello.py` with:

   > `hello.py`

   ```python
   # hello.py - From Script to Web Application
   #
   # Step 1a: Run as Python script
   #   python hello.py
   #
   # Step 1b: Run as Flask app
   #   flask --app hello run
   #   Then visit http://localhost:5000

   from flask import Flask

   app = Flask(__name__)


   @app.route("/")
   def hello():
       return "Hello World"


   # This only runs when executed as a script (python hello.py)
   # When using `flask run`, Flask handles the server
   if __name__ == "__main__":
       print("Hello World")
       print("\nTo run as a web app, use: flask --app hello run")
   ```

> ℹ **Concept Deep Dive**
>
> Let's break down the key parts:
>
> - `from flask import Flask` - Imports the Flask class from the flask package
> - `app = Flask(__name__)` - Creates a Flask application instance. The `__name__` variable tells Flask where to find templates and static files
> - `@app.route("/")` - This decorator tells Flask that when someone visits the root URL (`/`), call the `hello()` function
> - `def hello(): return "Hello World"` - This function returns the HTTP response body
> - `if __name__ == "__main__":` - This block only runs when you execute `python hello.py` directly, not when Flask imports the file
>
> ⚠ **Common Mistakes**
>
> - Forgetting to install Flask first will cause `ModuleNotFoundError: No module named 'flask'`
> - Typos in `@app.route("/")` - the decorator must match exactly
> - Using `print()` instead of `return` in the route function - `print()` goes to the terminal, `return` goes to the browser
>
> ✓ **Quick check:** File saved with no syntax errors

### **Step 4:** Run as a Web Application

Now we'll run the same file as a web application instead of a script. Flask provides a built-in development server that keeps running and listens for HTTP requests on port 5000.

1. **Start** the Flask development server:

   ```bash
   flask --app hello run
   ```

2. **Observe** the server output:

   ```text
    * Serving Flask app 'hello'
    * Debug mode: off
    * Running on http://127.0.0.1:5000
   Press CTRL+C to quit
   ```

3. **Open** your web browser and visit:

   ```text
   http://localhost:5000
   ```

4. **Notice** that the server keeps running - it doesn't exit like the script did

> ℹ **Concept Deep Dive**
>
> The `flask run` command:
>
> - `--app hello` tells Flask which Python file contains your application (hello.py)
> - The server binds to `127.0.0.1:5000` (localhost, port 5000)
> - It runs continuously, waiting for HTTP requests
> - When you visit the URL in your browser, the browser sends an HTTP GET request
> - Flask matches the URL `/` to your `@app.route("/")` decorator
> - Flask calls your `hello()` function
> - The return value becomes the HTTP response body
> - Your browser displays "Hello World"
>
> ⚠ **Common Mistakes**
>
> - If port 5000 is already in use, Flask will show an error. Stop other applications using that port or use `flask --app hello run --port 5001`
> - Forgetting `--app hello` causes Flask to look for an `app.py` file by default
>
> ✓ **Quick check:** Browser displays "Hello World" and the terminal shows the server is still running

### **Step 5:** Test Your Implementation

Let's verify the key difference between script and web application by testing both modes and observing how each one behaves.

1. **Stop** the Flask server by pressing `Ctrl+C` in the terminal

2. **Run** as a script:

   ```bash
   python hello.py
   ```

3. **Observe:** The script prints to the terminal and exits immediately

4. **Run** as a web application:

   ```bash
   flask --app hello run
   ```

5. **Test** by refreshing your browser multiple times at `http://localhost:5000`

6. **Observe** the terminal shows a log entry for each request:

   ```text
   127.0.0.1 - - [22/Jan/2025 10:30:45] "GET / HTTP/1.1" 200 -
   ```

7. **Stop** the server with `Ctrl+C`

> ✓ **Success indicators:**
>
> - Script mode: Prints "Hello World" and exits
> - Web app mode: Server keeps running until you stop it
> - Browser shows "Hello World"
> - Refreshing the page still works (server responds to repeated requests)
> - Terminal shows request logs for each browser visit
>
> ✓ **Final verification checklist:**
>
> - ☐ `news-flash` directory created
> - ☐ `requirements.txt` file created with `flask>=3.0.0`
> - ☐ Virtual environment created (`.venv` directory exists)
> - ☐ Virtual environment activated (prompt shows `(.venv)`)
> - ☐ `hello.py` file created with Flask code
> - ☐ Flask installed successfully via `pip install -r requirements.txt`
> - ☐ `python hello.py` prints and exits
> - ☐ `flask --app hello run` starts a persistent server
> - ☐ Browser displays "Hello World" at http://localhost:5000

## Common Issues

> **If you encounter problems:**
>
> **ModuleNotFoundError: No module named 'flask':** Make sure your virtual environment is activated (you should see `(.venv)` in your prompt), then run `pip install -r requirements.txt`
>
> **Address already in use:** Another application is using port 5000. Either stop that application or run Flask on a different port: `flask --app hello run --port 5001`
>
> **404 Not Found:** Make sure you're visiting `http://localhost:5000/` (with the trailing slash) and that your `@app.route("/")` decorator is correct
>
> **Browser shows nothing:** Check that the Flask server is still running in your terminal. The server should show "Running on http://127.0.0.1:5000"
>
> **Still stuck?** Verify your `hello.py` file matches the code exactly, including the `@app.route` decorator

## Summary

You've successfully transformed a Python script into a web application which:

- ✓ Demonstrates the difference between run-once scripts and persistent web servers
- ✓ Uses Flask's `@app.route()` decorator to map URLs to functions
- ✓ Responds to HTTP requests from a web browser

> **Key takeaway:** The fundamental difference between a script and a web application is persistence. Scripts run once and exit; web applications run continuously and respond to requests. Flask's decorator-based routing (`@app.route()`) makes it simple to map URLs to Python functions, turning function return values into HTTP responses.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try adding a second route like `@app.route("/about")` that returns different text
> - Add `debug=True` to see automatic reloading: `flask --app hello run --debug`
> - Open the browser's developer tools (F12) and look at the Network tab to see the HTTP request and response
> - Try returning HTML instead of plain text: `return "<h1>Hello World</h1>"`

## Done!

Excellent work! You've learned the fundamental difference between Python scripts and web applications. This concept - that web apps are persistent programs responding to requests - is the foundation for everything else you'll build with Flask. Your News Flash application will use these same patterns to serve dynamic news content to users.
