# Business Layer Validation Service

## Goal

Build a validation service in the business layer to validate and normalize subscription data before processing, demonstrating proper separation of concerns in three-tier architecture.

> **What you'll learn:**
>
> - How to create a service class in the business layer
> - When to use validation at the business layer vs. presentation layer
> - How to connect the business layer to the presentation layer
> - Best practices for error handling and user feedback

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed the subscription form and thank you page implementation
> - ✓ Flask application running with `flask run`
> - ✓ Understanding of Python classes and regular expressions

## Exercise Steps

### Overview

1. **Create the Subscription Service**
2. **Add Business Rules Methods**
3. **Update the Route to Use the Service**
4. **Add Error Display to the Form**
5. **Test Your Implementation**

### **Step 1:** Create the Subscription Service

The business layer sits between presentation and data layers. It handles validation, business rules, and data transformation - logic that doesn't belong in routes (presentation) or database operations (data). By centralizing this logic in a service class, we make it reusable, testable, and maintainable.

1. **Navigate to** the `app/business/services` directory

2. **Create a new file** named `subscription_service.py`

3. **Add the following code:**

   > `app/business/services/subscription_service.py`

   ```python
   """
   Subscription service - handles validation and business logic for subscriptions.

   This service sits between the presentation layer (routes) and the data layer
   (repositories). It validates input, applies business rules, and prepares data
   for storage.
   """

   import re
   from datetime import datetime, timezone


   class SubscriptionService:
       """Service for handling subscription-related business logic."""

       # Email regex pattern for validation
       EMAIL_PATTERN = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

       def validate_email(self, email: str) -> tuple[bool, str]:
           """
           Validate email format.

           Args:
               email: The email address to validate

           Returns:
               Tuple of (is_valid, error_message)
               If valid, error_message is empty string
           """
           if not email:
               return False, "Email is required"

           if not email.strip():
               return False, "Email is required"

           if not re.match(self.EMAIL_PATTERN, email.strip()):
               return False, "Invalid email format"

           return True, ""
   ```

> ℹ️ **Concept Deep Dive**
>
> The service class encapsulates business logic that would otherwise clutter your routes. The `validate_email` method returns a tuple - a common Python pattern for returning both a success flag and additional information. This allows the caller to check validity and get the error message in one call.
>
> The regex pattern `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` validates basic email format: characters before @, domain name, and a TLD of at least 2 characters.
>
> ⚠️ **Common Mistakes**
>
> - Forgetting to check for empty strings after stripping whitespace
> - Using overly strict regex that rejects valid emails (like ones with + signs)
> - Not returning consistent types from validation methods
>
> ✓ **Quick check:** File created at `app/business/services/subscription_service.py`

### **Step 2:** Add Business Rules Methods

Beyond validation, the business layer handles data transformation and business rules. We'll add methods to normalize user input (consistent formatting) and prepare data for storage. These rules ensure data consistency regardless of how users enter their information.

1. **Open** the file `app/business/services/subscription_service.py`

2. **Add** the following methods to the `SubscriptionService` class:

   > `app/business/services/subscription_service.py`

   ```python
       def normalize_email(self, email: str) -> str:
           """
           Normalize email address.

           - Converts to lowercase
           - Strips leading/trailing whitespace

           Args:
               email: The email address to normalize

           Returns:
               Normalized email address
           """
           return email.lower().strip()

       def normalize_name(self, name: str | None) -> str:
           """
           Normalize name field.

           - Strips leading/trailing whitespace
           - Returns 'Subscriber' if empty or None

           Args:
               name: The name to normalize

           Returns:
               Normalized name or default value
           """
           if not name or not name.strip():
               return "Subscriber"
           return name.strip()

       def process_subscription(self, email: str, name: str | None) -> dict:
           """
           Process and prepare subscription data.

           Validates, normalizes, and packages data for storage.

           Args:
               email: The subscriber's email address
               name: The subscriber's name (optional)

           Returns:
               Dictionary with processed subscription data

           Raises:
               ValueError: If email validation fails
           """
           # Validate first
           is_valid, error = self.validate_email(email)
           if not is_valid:
               raise ValueError(error)

           # Normalize and package
           return {
               "email": self.normalize_email(email),
               "name": self.normalize_name(name),
               "subscribed_at": datetime.now(timezone.utc).isoformat(),
           }
   ```

> ℹ️ **Concept Deep Dive**
>
> Normalization ensures data consistency. Users might enter `"  JOHN@EXAMPLE.COM  "` but we store `"john@example.com"`. This prevents duplicate entries with different casing and makes searching reliable.
>
> The `process_subscription` method combines validation and normalization into a single operation. It raises a `ValueError` if validation fails, which is a clean way to signal errors in Python. The route can catch this exception or use `validate_email` directly for more control.
>
> The `str | None` type hint (Python 3.10+) indicates the parameter can be either a string or None.
>
> ⚠️ **Common Mistakes**
>
> - Forgetting that `name` can be `None` (not just empty string)
> - Not using timezone-aware datetime (always use `timezone.utc`)
> - Normalizing before validating (validate the original input)
>
> ✓ **Quick check:** Service class has four methods: `validate_email`, `normalize_email`, `normalize_name`, `process_subscription`

### **Step 3:** Update the Route to Use the Service

Now we connect the business layer to the presentation layer. The route will use the service to validate input and handle errors gracefully by returning to the form with error messages when validation fails.

1. **Open** the file `app/presentation/routes/public.py`

2. **Add** the import for the service at the top of the file:

   > `app/presentation/routes/public.py`

   ```python
   from flask import Blueprint, render_template, request

   from app.business.services.subscription_service import SubscriptionService
   ```

3. **Replace** the `subscribe_confirm` function with the following:

   > `app/presentation/routes/public.py`

   ```python
   @bp.route("/subscribe/confirm", methods=["POST"])
   def subscribe_confirm():
       """Handle subscription form submission."""
       email = request.form.get("email", "")
       name = request.form.get("name", "")

       # Use business layer for validation and processing
       service = SubscriptionService()

       # Validate email
       is_valid, error = service.validate_email(email)
       if not is_valid:
           # Return to form with error message, preserving input
           return render_template(
               "subscribe.html",
               error=error,
               email=email,
               name=name,
           )

       # Process subscription data (normalize email and name)
       data = service.process_subscription(email, name)

       # Verification: print to terminal (no persistence yet)
       print(f"New subscription: {data['email']} ({data['name']})")

       return render_template("thank_you.html", email=data["email"], name=data["name"])
   ```

> ℹ️ **Concept Deep Dive**
>
> The route now delegates validation to the business layer instead of handling it directly. This separation means:
>
> - **Routes** handle HTTP concerns (getting form data, rendering templates)
> - **Services** handle business concerns (validation, normalization)
>
> When validation fails, we re-render the form with three pieces of information: the error message, and the original email and name values. This preserves user input so they don't have to retype everything.
>
> ⚠️ **Common Mistakes**
>
> - Forgetting to pass `email` and `name` back to the template on error (loses user input)
> - Using `request.form.get("email")` without a default returns `None`, which can cause issues
> - Creating the service inside the route is fine for now; dependency injection comes later
>
> ✓ **Quick check:** Route imports the service and uses it for validation

### **Step 4:** Add Error Display to the Form

The form template needs to display error messages when validation fails and preserve the user's input. We'll add an error banner and update the input fields to show their previous values.

1. **Open** the file `app/presentation/templates/subscribe.html`

2. **Locate** the opening of the form (after the subtitle paragraph)

3. **Add** the error banner before the form:

   > `app/presentation/templates/subscribe.html`

   ```html
   {% if error %}
   <div class="form__error-banner">
       {{ error }}
   </div>
   {% endif %}

   <form class="form" action="{{ url_for('public.subscribe_confirm') }}" method="POST">
   ```

4. **Update** the email input to show previous value and error styling:

   > `app/presentation/templates/subscribe.html`

   ```html
   <input
       type="email"
       id="email"
       name="email"
       class="form__input {% if error %}form__input--error{% endif %}"
       placeholder="you@example.com"
       value="{{ email or '' }}"
       required
   >
   ```

5. **Update** the name input to preserve its value:

   > `app/presentation/templates/subscribe.html`

   ```html
   <input
       type="text"
       id="name"
       name="name"
       class="form__input"
       placeholder="Your name"
       value="{{ name or '' }}"
   >
   ```

6. **Add** the error styles to the `{% block extra_css %}` section:

   > `app/presentation/templates/subscribe.html`

   ```css
   .form__input--error {
       border-color: #ef4444;
   }

   .form__input--error:focus {
       border-color: #ef4444;
       box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
   }

   .form__error-banner {
       background-color: #fef2f2;
       border: 1px solid #fecaca;
       color: #dc2626;
       padding: 0.75rem 1rem;
       border-radius: 0.5rem;
       margin-bottom: 1.5rem;
       font-size: 0.875rem;
   }
   ```

> ℹ️ **Concept Deep Dive**
>
> The `{% if error %}` block uses Jinja2 conditional rendering - the error banner only appears when an error exists. The `{{ email or '' }}` syntax provides a default empty string if `email` is undefined, preventing template errors.
>
> Error styling uses red colors (#ef4444, #dc2626) which are universally recognized as indicating problems. The error banner appears above the form so users see it immediately.
>
> ⚠️ **Common Mistakes**
>
> - Forgetting the `or ''` fallback causes errors when variables are undefined
> - Placing the error banner inside the form can cause layout issues
> - Not preserving both email and name values frustrates users
>
> ✓ **Quick check:** Template shows error banner conditionally and preserves input values

### **Step 5:** Test Your Implementation

Verify the complete validation flow works correctly. We'll test both invalid and valid inputs to ensure the business layer properly validates and normalizes data.

1. **Start the application:**

   ```bash
   flask run
   ```

2. **Navigate to:** <http://localhost:5000/subscribe>

3. **Test empty email:**
   - Leave the email field empty
   - Click "Subscribe"
   - Verify error banner shows "Email is required"
   - Verify you stay on the form page

4. **Test invalid email format:**
   - Enter "invalid" in the email field
   - Enter "John" in the name field
   - Click "Subscribe"
   - Verify error banner shows "Invalid email format"
   - Verify "invalid" and "John" are still in the fields

5. **Test valid email with normalization:**
   - Enter "  TEST@EXAMPLE.COM  " (with spaces and uppercase)
   - Enter "  Jane  " (with spaces)
   - Click "Subscribe"
   - Verify thank you page shows "test@example.com" (normalized)
   - Verify thank you page shows "Jane" (trimmed)

6. **Check terminal output:**
   - Verify terminal shows: `New subscription: test@example.com (Jane)`

> ✓ **Success indicators:**
>
> - Empty email shows "Email is required" error
> - Invalid format shows "Invalid email format" error
> - Form preserves input values on error
> - Valid email is normalized (lowercase, trimmed)
> - Name is trimmed or defaults to "Subscriber"
> - Terminal shows processed (normalized) data
>
> ✓ **Final verification checklist:**
>
> - ☐ `subscription_service.py` created in `app/business/services/`
> - ☐ Service has `validate_email`, `normalize_email`, `normalize_name`, `process_subscription` methods
> - ☐ Route imports and uses `SubscriptionService`
> - ☐ Form displays error banner when validation fails
> - ☐ Form preserves input values on error
> - ☐ Email input shows error styling when validation fails
> - ☐ Valid submissions show normalized data on thank you page

## Common Issues

> **If you encounter problems:**
>
> **"ModuleNotFoundError: No module named 'app.business'":** Ensure `__init__.py` files exist in `app/business/` and `app/business/services/` directories
>
> **Error banner not showing:** Check that you're passing `error=error` to `render_template` and using `{% if error %}` in the template
>
> **Input values not preserved:** Verify you're passing `email=email, name=name` to `render_template` and using `value="{{ email or '' }}"` in inputs
>
> **Regex not matching valid emails:** The pattern should handle common formats; test with simple emails like `test@example.com` first
>
> **Still stuck?** Check the Flask terminal for Python errors - they usually indicate the exact problem

## Summary

You've successfully implemented the business layer which:

- ✓ Validates email format with clear error messages
- ✓ Normalizes data for consistency (lowercase, trimmed)
- ✓ Separates business logic from presentation concerns
- ✓ Provides user-friendly error feedback

> **Key takeaway:** The business layer handles "what the business cares about" - valid emails, consistent data formats, business rules. It doesn't know about HTTP requests (presentation) or databases (data). This separation makes each layer focused, testable, and maintainable. When you need to change validation rules, you change one place: the service.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add more validation rules (minimum name length, blocked email domains)
> - Implement a generic `ValidationResult` class instead of tuples
> - Add unit tests for the `SubscriptionService` class
> - Research Python's `dataclasses` for structured return types

## Done! 🎉

Excellent work! You've built a proper business layer that validates and normalizes user input. The application now has clear separation between presentation (how things look) and business logic (what rules apply). Next, you'll add the data layer to actually persist subscriptions to a database.
