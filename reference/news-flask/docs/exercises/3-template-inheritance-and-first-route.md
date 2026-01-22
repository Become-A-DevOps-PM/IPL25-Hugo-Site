# Template Inheritance and Your First Route

## Goal

Build a landing page using Jinja2 template inheritance and Flask Blueprints to create a maintainable, professional web interface.

> **What you'll learn:**
>
> - How to implement Jinja2 template inheritance with base templates and blocks
> - When to use Flask Blueprints to organize routes in real applications
> - Best practices for CSS organization with CSS variables and BEM naming

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A Flask application with the factory pattern and configuration
> - ✓ Flask application running with `flask run`
> - ✓ Basic understanding of HTML and CSS

## Before You Begin

> **Start each session by activating your environment:**
>
> ```bash
> cd application
> source .venv/bin/activate  # On Windows: .venv\Scripts\activate
> ```
>
> You'll know it's active when you see `(.venv)` in your terminal prompt.

## Exercise Steps

### Overview

1. **Create the Base Template**
2. **Create the Public Routes Blueprint**
3. **Create the Index Template**
4. **Register the Blueprint**
5. **Test Your Implementation**

### **Step 1:** Create the Base Template

Template inheritance is one of Jinja2's most powerful features. Instead of duplicating HTML structure across every page, you define a base template with common elements (header, footer, navigation) and "blocks" that child templates can override. This follows the DRY (Don't Repeat Yourself) principle and makes site-wide changes trivial.

1. **Navigate to** the `app/presentation/templates` directory

2. **Create a new file** named `base.html`

3. **Add the following code:**

   > `app/presentation/templates/base.html`

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>{% block title %}News Flash{% endblock %}</title>
       <style>
           /* CSS Reset and Base Styles */
           *, *::before, *::after {
               box-sizing: border-box;
               margin: 0;
               padding: 0;
           }

           :root {
               --color-primary: #2563eb;
               --color-primary-dark: #1d4ed8;
               --color-secondary: #f59e0b;
               --color-text: #1f2937;
               --color-text-light: #6b7280;
               --color-bg: #ffffff;
               --color-bg-alt: #f3f4f6;
               --font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
           }

           body {
               font-family: var(--font-family);
               line-height: 1.6;
               color: var(--color-text);
               background-color: var(--color-bg);
               min-height: 100vh;
               display: flex;
               flex-direction: column;
           }

           /* Header Styles */
           .header {
               background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
               color: white;
               padding: 1rem 2rem;
               box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
           }

           .header__container {
               max-width: 1200px;
               margin: 0 auto;
               display: flex;
               justify-content: space-between;
               align-items: center;
           }

           .header__logo {
               font-size: 1.5rem;
               font-weight: 700;
               text-decoration: none;
               color: white;
               display: flex;
               align-items: center;
               gap: 0.5rem;
           }

           .header__logo-icon {
               font-size: 1.75rem;
           }

           .header__nav {
               display: flex;
               gap: 1.5rem;
           }

           .header__nav-link {
               color: rgba(255, 255, 255, 0.9);
               text-decoration: none;
               font-weight: 500;
               transition: color 0.2s;
           }

           .header__nav-link:hover {
               color: white;
           }

           /* Main Content */
           .main {
               flex: 1;
           }

           /* Footer Styles */
           .footer {
               background-color: var(--color-bg-alt);
               border-top: 1px solid #e5e7eb;
               padding: 2rem;
               margin-top: auto;
           }

           .footer__container {
               max-width: 1200px;
               margin: 0 auto;
               text-align: center;
           }

           .footer__text {
               color: var(--color-text-light);
               font-size: 0.875rem;
           }

           /* Button Styles */
           .btn {
               display: inline-block;
               padding: 0.75rem 1.5rem;
               font-size: 1rem;
               font-weight: 600;
               text-decoration: none;
               border-radius: 0.5rem;
               cursor: pointer;
               transition: all 0.2s;
               border: none;
           }

           .btn--primary {
               background-color: var(--color-primary);
               color: white;
           }

           .btn--primary:hover {
               background-color: var(--color-primary-dark);
               transform: translateY(-1px);
               box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
           }

           /* Modal Styles */
           .modal-overlay {
               display: none;
               position: fixed;
               top: 0;
               left: 0;
               width: 100%;
               height: 100%;
               background-color: rgba(0, 0, 0, 0.5);
               z-index: 1000;
               justify-content: center;
               align-items: center;
           }

           .modal-overlay.active {
               display: flex;
           }

           .modal {
               background: white;
               border-radius: 1rem;
               padding: 2rem;
               max-width: 500px;
               width: 90%;
               box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
               animation: modalSlideIn 0.3s ease-out;
           }

           @keyframes modalSlideIn {
               from {
                   opacity: 0;
                   transform: translateY(-20px);
               }
               to {
                   opacity: 1;
                   transform: translateY(0);
               }
           }

           .modal__header {
               display: flex;
               justify-content: space-between;
               align-items: center;
               margin-bottom: 1rem;
           }

           .modal__title {
               font-size: 1.25rem;
               font-weight: 600;
           }

           .modal__close {
               background: none;
               border: none;
               font-size: 1.5rem;
               cursor: pointer;
               color: var(--color-text-light);
               padding: 0.25rem;
               line-height: 1;
           }

           .modal__close:hover {
               color: var(--color-text);
           }

           .modal__body {
               color: var(--color-text-light);
           }

           {% block extra_css %}{% endblock %}
       </style>
   </head>
   <body>
       <header class="header">
           <div class="header__container">
               <a href="/" class="header__logo">
                   <span class="header__logo-icon">&#9889;</span>
                   News Flash
               </a>
               <nav class="header__nav">
                   <a href="/" class="header__nav-link">Home</a>
                   <a href="#" class="header__nav-link">About</a>
               </nav>
           </div>
       </header>

       <main class="main">
           {% block content %}{% endblock %}
       </main>

       <footer class="footer">
           <div class="footer__container">
               <p class="footer__text">
                   &copy; 2025 News Flash. Built with Flask.
               </p>
           </div>
       </footer>

       {% block scripts %}{% endblock %}
   </body>
   </html>
   ```

> ℹ **Concept Deep Dive**
>
> This base template introduces several important concepts:
>
> **Jinja2 Blocks** define overridable sections. Child templates use `{% block name %}...{% endblock %}` to replace content. We define four blocks:
> - `title` - Page title (has a default value)
> - `content` - Main page content (required)
> - `extra_css` - Additional page-specific styles
> - `scripts` - JavaScript at the end of the body
>
> **CSS Variables** (custom properties) are defined in `:root` and reused throughout. Changing `--color-primary` updates the entire color scheme instantly.
>
> **BEM Naming** (Block Element Modifier) creates readable, maintainable CSS. For example:
> - `.header` is the block
> - `.header__container` is an element within the block
> - `.btn--primary` is a modifier variant
>
> ⚠ **Common Mistakes**
>
> - Forgetting `{% endblock %}` causes a template syntax error
> - Block names are case-sensitive: `Content` is different from `content`
> - Missing the `<!DOCTYPE html>` declaration can cause rendering issues
>
> ✓ **Quick check:** File created at `app/presentation/templates/base.html`

### **Step 2:** Create the Public Routes Blueprint

Flask Blueprints organize routes into logical groups. Instead of defining all routes in one file, you can separate them by purpose: public pages, authentication, API endpoints, and admin functions. This keeps your code organized as your application grows.

1. **Navigate to** the `app/presentation/routes` directory

2. **Create a new file** named `public.py`

3. **Add the following code:**

   > `app/presentation/routes/public.py`

   ```python
   """
   Public routes - accessible without authentication.

   This blueprint handles all public-facing pages including the landing page.
   """

   from flask import Blueprint, render_template

   bp = Blueprint("public", __name__)


   @bp.route("/")
   def index():
       """Render the landing page."""
       return render_template("index.html")
   ```

> ℹ **Concept Deep Dive**
>
> A Blueprint is a way to organize related routes. Think of it as a mini-application that can be registered with the main Flask app. The key components are:
>
> - `Blueprint("public", __name__)` creates the blueprint with name "public"
> - `@bp.route("/")` decorates a function to handle requests to that URL
> - `render_template("index.html")` processes a Jinja2 template and returns HTML
>
> **The Request Flow:**
> 1. User visits `http://localhost:5000/`
> 2. Flask matches the URL to the `index()` function
> 3. `render_template()` finds and processes `index.html`
> 4. The rendered HTML is returned as the HTTP response
>
> In production applications, you might have multiple blueprints:
> - `public` for landing pages and public content
> - `auth` for login, logout, and registration
> - `admin` for administrative functions
> - `api` for JSON endpoints
>
> ⚠ **Common Mistakes**
>
> - Using `@app.route` instead of `@bp.route` when working with blueprints
> - Forgetting to import `render_template` results in `NameError`
> - Template not found errors often mean wrong template folder configuration
>
> ✓ **Quick check:** File created at `app/presentation/routes/public.py` with no syntax errors

### **Step 3:** Create the Index Template

Now create the child template that extends the base template. This demonstrates template inheritance in action - you only write the content specific to this page, inheriting everything else from the base.

1. **Navigate to** the `app/presentation/templates` directory

2. **Create a new file** named `index.html`

3. **Add the following code:**

   > `app/presentation/templates/index.html`

   ```html
   {% extends "base.html" %}

   {% block title %}News Flash - Stay Informed{% endblock %}

   {% block content %}
   <section style="padding: 4rem 2rem; text-align: center;">
       <h1>Welcome to News Flash</h1>
       <p>Your landing page is working!</p>
   </section>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> This simple template demonstrates the power of inheritance:
>
> - `{% extends "base.html" %}` must be the first line - it tells Jinja2 which template to inherit from
> - `{% block title %}...{% endblock %}` overrides the title block from base.html
> - `{% block content %}...{% endblock %}` provides the main page content
>
> Notice what we did NOT write:
> - No `<!DOCTYPE html>`, `<head>`, or `<body>` tags
> - No header or navigation HTML
> - No footer HTML
> - No CSS reset or base styles
>
> All of that comes automatically from `base.html`. If you later want to change the footer across all pages, you change it once in `base.html`.
>
> **Why this matters:** Real applications have dozens or hundreds of pages. Without template inheritance, changing the navigation would require editing every single file. With inheritance, you change the base template once.
>
> ✓ **Quick check:** File created at `app/presentation/templates/index.html`

### **Step 4:** Register the Blueprint

The blueprint exists, but Flask does not know about it yet. You must register the blueprint with the Flask application in the application factory. This is where the three-tier architecture becomes visible - the presentation layer (routes) connects to the application.

1. **Open** the file `app/__init__.py`

2. **Locate** the `create_app` function

3. **Update** the file to register the blueprint:

   > `app/__init__.py`

   ```python
   """
   News Flash - Application Factory
   """

   import os

   from flask import Flask

   from .config import config


   def create_app(config_name: str | None = None) -> Flask:
       if config_name is None:
           config_name = os.environ.get("FLASK_ENV", "development")

       app = Flask(
           __name__,
           template_folder="presentation/templates",
           static_folder="presentation/static",
       )

       app.config.from_object(config[config_name])

       # Register blueprints
       from .presentation.routes.public import bp as public_bp

       app.register_blueprint(public_bp)

       return app
   ```

> ℹ **Concept Deep Dive**
>
> Blueprint registration happens inside `create_app()` for important reasons:
>
> 1. **Import inside the function:** We import the blueprint inside `create_app()` to avoid circular imports. If you import at the top of the file, the blueprint module might try to use the app before it exists.
>
> 2. **Renaming on import:** `from .presentation.routes.public import bp as public_bp` imports `bp` but renames it to `public_bp`. This avoids naming conflicts when you have multiple blueprints, each with their own `bp`.
>
> 3. **`app.register_blueprint(public_bp)`** tells Flask to include all routes from this blueprint. You can also add a `url_prefix` to namespace routes, like `app.register_blueprint(api_bp, url_prefix='/api')`.
>
> **The path matters:** Notice the import path `.presentation.routes.public`. This matches our three-tier folder structure and makes the architecture visible in the code.
>
> ⚠ **Common Mistakes**
>
> - Importing blueprints at the top level causes circular import errors
> - Forgetting `register_blueprint()` means routes will not work (404 errors)
> - Wrong import path results in `ModuleNotFoundError`
>
> ✓ **Quick check:** Application starts without import errors

### **Step 5:** Test Your Implementation

Time to verify that template inheritance and blueprint registration work correctly. You will see the complete page rendered with header, content, and footer.

1. **Run the application:**

   ```bash
   flask run
   ```

2. **Open your browser** and navigate to `http://localhost:5000`

3. **Verify the page structure:**
   - Header appears with "News Flash" logo and lightning bolt icon
   - Navigation shows "Home" and "About" links
   - Content area displays "Welcome to News Flash"
   - Footer shows copyright text

4. **Inspect the page source** (right-click, "View Page Source"):
   - Notice the complete HTML from `base.html`
   - Find where the `{% block content %}` was replaced
   - Observe the CSS variables in the `<style>` section

5. **Test the navigation:**
   - Click "Home" - should stay on the same page
   - Click "About" - link exists but page not implemented yet

> ✓ **Success indicators:**
>
> - Page loads without errors at http://localhost:5000
> - Header shows "News Flash" with lightning bolt icon (&#9889;)
> - Navigation links are visible and styled
> - Main content shows "Welcome to News Flash"
> - Footer displays copyright with current year
> - Page has blue gradient header and light gray footer
>
> ✓ **Final verification checklist:**
>
> - ☐ `base.html` created with all four blocks (title, content, extra_css, scripts)
> - ☐ `public.py` blueprint created with index route
> - ☐ `index.html` extends base.html correctly
> - ☐ Blueprint registered in `app/__init__.py`
> - ☐ Page renders with header, content, and footer

## Common Issues

> **If you encounter problems:**
>
> **TemplateNotFound error:** Verify `template_folder="presentation/templates"` in `create_app()` and that templates are in the correct directory.
>
> **404 Not Found:** Check that the blueprint is registered and the route decorator uses `@bp.route("/")` not `@app.route("/")`.
>
> **ImportError or ModuleNotFoundError:** Verify the import path matches your folder structure: `from .presentation.routes.public import bp`
>
> **Blank page or missing styles:** Ensure `base.html` has the complete `<style>` section and `index.html` starts with `{% extends "base.html" %}`.
>
> **Jinja2 syntax error:** Check for matching `{% block %}` and `{% endblock %}` tags. Remember, block names are case-sensitive.
>
> **Still stuck?** Run `flask run --debug` to see detailed error messages in the browser.

## Summary

You have successfully implemented template inheritance and Flask Blueprints which:

- Enables consistent page layouts through a single base template
- Follows the DRY principle by eliminating duplicate HTML
- Organizes routes logically using the Blueprint pattern

> **Key takeaway:** Template inheritance and Blueprints are foundational patterns for maintainable Flask applications. Template inheritance lets you change site-wide elements (header, footer, styles) in one place, while Blueprints keep your routes organized as your application grows. You will use these patterns in every Flask project.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try adding a new block `{% block header_extra %}{% endblock %}` in the header for page-specific navigation
> - Create an `about.html` template that extends `base.html` and add a route for it
> - Experiment with CSS variables - change `--color-primary` and watch the entire color scheme update
> - Research the `super()` function in Jinja2 to extend blocks instead of replacing them

## Done!

Excellent work! You have learned how to implement Jinja2 template inheritance and Flask Blueprints. Your application now has a professional structure with a reusable base template and organized routes. This foundation prepares you for adding more interactive features to your landing page.
