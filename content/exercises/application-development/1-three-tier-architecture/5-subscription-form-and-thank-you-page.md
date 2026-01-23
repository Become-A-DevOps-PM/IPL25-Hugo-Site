+++
title = "Subscription Form and Thank You Page"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build a subscription form and handle form submissions with a confirmation page"
weight = 4
+++

# Subscription Form and Thank You Page

## Goal

Build a subscription form on a dedicated page and handle form submissions with a confirmation page, completing the presentation layer of the three-tier architecture.

> **What you'll learn:**
>
> - How to create HTML forms that submit data to Flask routes
> - How to handle POST requests and access form data
> - How to pass data from routes to templates for display
> - Best practices for user feedback after form submission

## Prerequisites

> **Before starting, ensure you have:**
>
> - Completed the previous exercises (landing page with hero section)
> - Flask application running with `flask run`
> - Understanding of Flask routes and Jinja2 templates

## Exercise Steps

### Overview

1. **Update the Landing Page CTA**
2. **Create the Subscribe Route**
3. **Build the Subscription Form Template**
4. **Add the Form Submission Handler**
5. **Create the Thank You Page**
6. **Test Your Implementation**

### **Step 1:** Update the Landing Page CTA

The landing page currently has a "Subscribe Now" button that opens a modal. Now that we're building a dedicated subscription page, we need to change this button to navigate to the new page instead. This is a common pattern in web development - starting with a simple placeholder and then replacing it with the full implementation.

1. **Open** the file `app/presentation/templates/index.html`

2. **Locate** the hero section's call-to-action button

3. **Replace** the button element with a link:

   > `app/presentation/templates/index.html`

   ```html
   <a href="{{ url_for('public.subscribe') }}" class="btn btn--primary hero__cta">
       Subscribe Now
   </a>
   ```

4. **Remove** the modal HTML (the `modal-overlay` div and its contents)

5. **Remove** the JavaScript block at the bottom (the `{% block scripts %}` section with modal functionality)

> **Concept Deep Dive**
>
> The `url_for()` function generates URLs dynamically based on the route function name. Using `url_for('public.subscribe')` instead of hardcoding `/subscribe` makes your code more maintainable - if you ever change the URL pattern, you only need to update the route definition.
>
> **Common Mistakes**
>
> - Forgetting to remove the modal JavaScript will cause errors since the modal elements no longer exist
> - Using `href="/subscribe"` instead of `url_for()` works but is less maintainable
>
> **Quick check:** The button should now be an `<a>` tag, and the modal code should be removed

### **Step 2:** Create the Subscribe Route

Before we can navigate to the subscription page, we need to create the route that handles the request. Flask routes map URLs to Python functions that return responses. This route will serve the subscription form page.

1. **Open** the file `app/presentation/routes/public.py`

2. **Add** the request import to access form data (we'll need this for the next step too):

   > `app/presentation/routes/public.py`

   ```python
   from flask import Blueprint, render_template, request
   ```

3. **Add** the subscribe route after the index route:

   > `app/presentation/routes/public.py`

   ```python
   @bp.route("/subscribe")
   def subscribe():
       """Render the subscription form."""
       return render_template("subscribe.html")
   ```

> **Concept Deep Dive**
>
> By default, Flask routes only respond to GET requests. GET requests are used to retrieve pages - the user is asking to "get" the subscription form. Later, we'll add a POST route to handle form submissions. This separation follows HTTP semantics: GET for retrieving, POST for submitting.
>
> **Quick check:** The route is defined but will fail until we create the template in the next step

### **Step 3:** Build the Subscription Form Template

Now we create the form that users will fill out. HTML forms collect user input and send it to the server. We'll create a clean, styled form with email (required) and name (optional) fields.

1. **Navigate to** the `app/presentation/templates` directory

2. **Create a new file** named `subscribe.html`

3. **Add the following template:**

   > `app/presentation/templates/subscribe.html`

   ```html
   {% extends "base.html" %}

   {% block title %}Subscribe - News Flash{% endblock %}

   {% block content %}
   <section class="subscribe">
       <div class="subscribe__container">
           <h1 class="subscribe__title">Subscribe to News Flash</h1>
           <p class="subscribe__subtitle">
               Get the latest tech news delivered to your inbox every week.
           </p>

           <form class="form" action="{{ url_for('public.subscribe_confirm') }}" method="POST">
               <div class="form__group">
                   <label class="form__label" for="email">Email Address *</label>
                   <input
                       type="email"
                       id="email"
                       name="email"
                       class="form__input"
                       placeholder="you@example.com"
                       required
                   >
               </div>

               <div class="form__group">
                   <label class="form__label" for="name">Name (optional)</label>
                   <input
                       type="text"
                       id="name"
                       name="name"
                       class="form__input"
                       placeholder="Your name"
                   >
               </div>

               <button type="submit" class="btn btn--primary form__submit">
                   Subscribe
               </button>
           </form>

           <p class="subscribe__back">
               <a href="{{ url_for('public.index') }}">&larr; Back to Home</a>
           </p>
       </div>
   </section>
   {% endblock %}

   {% block extra_css %}
   <style>
       .subscribe {
           padding: 4rem 2rem;
           max-width: 500px;
           margin: 0 auto;
       }

       .subscribe__container {
           background: white;
           padding: 2rem;
           border-radius: 1rem;
           box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
       }

       .subscribe__title {
           font-size: 2rem;
           font-weight: 700;
           margin-bottom: 0.5rem;
           color: var(--color-text);
       }

       .subscribe__subtitle {
           color: var(--color-text-light);
           margin-bottom: 2rem;
       }

       .form__group {
           margin-bottom: 1.5rem;
       }

       .form__label {
           display: block;
           font-weight: 600;
           margin-bottom: 0.5rem;
           color: var(--color-text);
       }

       .form__input {
           width: 100%;
           padding: 0.75rem 1rem;
           font-size: 1rem;
           border: 2px solid #e5e7eb;
           border-radius: 0.5rem;
           transition: border-color 0.2s, box-shadow 0.2s;
       }

       .form__input:focus {
           outline: none;
           border-color: var(--color-primary);
           box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
       }

       .form__input::placeholder {
           color: #9ca3af;
       }

       .form__submit {
           width: 100%;
           margin-top: 0.5rem;
       }

       .subscribe__back {
           margin-top: 1.5rem;
           text-align: center;
       }

       .subscribe__back a {
           color: var(--color-primary);
           text-decoration: none;
       }

       .subscribe__back a:hover {
           text-decoration: underline;
       }
   </style>
   {% endblock %}
   ```

> **Concept Deep Dive**
>
> The form's `action` attribute specifies where to send the data, and `method="POST"` indicates we're submitting data. The `name` attribute on inputs is crucial - it becomes the key used to access the data on the server (`request.form.get("email")`). The `required` attribute provides browser-side validation.
>
> **Common Mistakes**
>
> - Forgetting the `name` attribute means the data won't be sent to the server
> - Using `method="GET"` exposes form data in the URL (not suitable for sensitive data)
> - The `for` attribute on labels must match the `id` on inputs for accessibility
>
> **Quick check:** Visit `/subscribe` - you should see the styled form (submission won't work yet)

### **Step 4:** Add the Form Submission Handler

Now we need a route to receive the form data when the user clicks "Subscribe". This route will use the POST method to handle the submitted data. For now, we'll print the data to the terminal for verification - no database yet.

1. **Open** the file `app/presentation/routes/public.py`

2. **Add** the form handling route:

   > `app/presentation/routes/public.py`

   ```python
   @bp.route("/subscribe/confirm", methods=["POST"])
   def subscribe_confirm():
       """Handle subscription form submission."""
       email = request.form.get("email")
       name = request.form.get("name", "Subscriber")

       # Verification: print to terminal (no persistence yet)
       print(f"New subscription: {email} ({name})")

       return render_template("thank_you.html", email=email, name=name)
   ```

> **Concept Deep Dive**
>
> The `methods=["POST"]` parameter restricts this route to only accept POST requests. The `request.form` object contains all submitted form data as a dictionary-like object. Using `.get()` with a default value (`"Subscriber"`) handles cases where the optional name field is empty.
>
> Printing to the terminal is a simple verification technique during development. In the presentation layer, we're not persisting data - that's the data layer's responsibility. This print statement proves our form handling works before we add complexity.
>
> **Common Mistakes**
>
> - Forgetting `methods=["POST"]` results in a "Method Not Allowed" error
> - Using `request.args` instead of `request.form` only works for URL parameters
> - Not providing a default value for optional fields can cause issues downstream
>
> **Quick check:** Route exists but will fail until we create the thank you template

### **Step 5:** Create the Thank You Page

The thank you page confirms the subscription and echoes back the submitted data. This provides immediate feedback to the user, showing that their submission was received correctly.

1. **Navigate to** the `app/presentation/templates` directory

2. **Create a new file** named `thank_you.html`

3. **Add the following template:**

   > `app/presentation/templates/thank_you.html`

   ```html
   {% extends "base.html" %}

   {% block title %}Thank You - News Flash{% endblock %}

   {% block content %}
   <section class="thank-you">
       <div class="thank-you__container">
           <div class="thank-you__icon">&#10003;</div>
           <h1 class="thank-you__title">Thank You, {{ name }}!</h1>
           <p class="thank-you__message">
               We've received your subscription request for:
           </p>
           <p class="thank-you__email">{{ email }}</p>
           <p class="thank-you__note">
               You'll start receiving our newsletter soon.
           </p>
           <a href="{{ url_for('public.index') }}" class="btn btn--primary">
               Back to Home
           </a>
       </div>
   </section>
   {% endblock %}

   {% block extra_css %}
   <style>
       .thank-you {
           padding: 4rem 2rem;
           text-align: center;
           min-height: 60vh;
           display: flex;
           align-items: center;
           justify-content: center;
       }

       .thank-you__container {
           background: white;
           padding: 3rem;
           border-radius: 1rem;
           box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
           max-width: 500px;
       }

       .thank-you__icon {
           width: 80px;
           height: 80px;
           background: linear-gradient(135deg, #10b981 0%, #059669 100%);
           color: white;
           font-size: 2.5rem;
           border-radius: 50%;
           display: flex;
           align-items: center;
           justify-content: center;
           margin: 0 auto 1.5rem;
       }

       .thank-you__title {
           font-size: 2rem;
           font-weight: 700;
           margin-bottom: 1rem;
           color: var(--color-text);
       }

       .thank-you__message {
           color: var(--color-text-light);
           margin-bottom: 0.5rem;
       }

       .thank-you__email {
           font-size: 1.125rem;
           font-weight: 600;
           color: var(--color-primary);
           margin-bottom: 1rem;
           word-break: break-all;
       }

       .thank-you__note {
           color: var(--color-text-light);
           margin-bottom: 2rem;
       }
   </style>
   {% endblock %}
   ```

> **Concept Deep Dive**
>
> The variables `{{ name }}` and `{{ email }}` are Jinja2 template expressions. These are replaced with the actual values passed from the route's `render_template()` call. This is how we pass data from Python to HTML - the route function provides the data, and the template displays it.
>
> Echoing the submitted data back to the user serves two purposes: it confirms receipt and allows the user to verify the information is correct. This is a common UX pattern for form submissions.
>
> **Common Mistakes**
>
> - Variable names in the template must exactly match the keyword arguments in `render_template()`
> - Forgetting to pass a variable results in an undefined error or empty output
>
> **Quick check:** Template created with proper variable placeholders

### **Step 6:** Test Your Implementation

Verify the complete subscription flow works end-to-end. We'll test the happy path and check that data appears in the terminal.

1. **Start the application** (if not already running):

   ```bash
   flask run
   ```

2. **Navigate to:** <http://localhost:5000>

3. **Test the navigation:**
   - Click the "Subscribe Now" button
   - Verify you're redirected to `/subscribe`
   - Verify the "Back to Home" link works

4. **Test the form submission:**
   - Enter an email: `test@example.com`
   - Enter a name: `John`
   - Click "Subscribe"
   - Verify the thank you page displays with your data

5. **Verify terminal output:**
   - Check your terminal where Flask is running
   - You should see: `New subscription: test@example.com (John)`

6. **Test with optional name empty:**
   - Go back to `/subscribe`
   - Enter only an email
   - Submit and verify it shows "Thank You, Subscriber!"

> **Success indicators:**
>
> - Landing page "Subscribe Now" links to `/subscribe`
> - Form displays with proper styling
> - Form submission redirects to thank you page
> - Thank you page shows the submitted email and name
> - Terminal displays the subscription data
>
> **Final verification checklist:**
>
> - [ ] `index.html` updated with link instead of button
> - [ ] Modal code removed from `index.html`
> - [ ] `/subscribe` route returns the form page
> - [ ] `/subscribe/confirm` POST route handles submission
> - [ ] `subscribe.html` template created with form
> - [ ] `thank_you.html` template created with confirmation
> - [ ] Terminal shows submitted data

## Common Issues

> **If you encounter problems:**
>
> **"Method Not Allowed" error:** Ensure the form uses `method="POST"` and the route includes `methods=["POST"]`
>
> **Form data not appearing:** Check that input fields have `name` attributes that match what you're accessing in `request.form.get()`
>
> **"BuildError: Could not build url for endpoint":** Verify the route function name matches what's in `url_for()` (e.g., `public.subscribe_confirm`)
>
> **Variables not showing in template:** Ensure you pass them to `render_template()` as keyword arguments
>
> **Still stuck?** Check the Flask terminal for error messages - they usually indicate exactly what's wrong

## Summary

You've successfully completed the presentation layer which:

- Collects user input through an HTML form
- Handles form submissions in Flask routes
- Provides user feedback with a confirmation page
- Demonstrates the request-response cycle without persistence

> **Key takeaway:** The presentation layer handles everything the user sees and interacts with. Forms collect data, routes process requests, and templates display responses. Notice we haven't validated the email format or saved anything to a database - those responsibilities belong to the business and data layers respectively.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try adding client-side validation with JavaScript
> - Add more form fields (e.g., subscription preferences)
> - Style the form with different states (focus, error, success)
> - Research CSRF protection for form security
