# Repository Pattern and Full Integration

## Goal

Build a repository class to encapsulate database operations and integrate all three layers, enabling the subscription form to persist data to the database through the complete presentation → business → data flow.

> **What you'll learn:**
>
> - How to implement the repository pattern for data access
> - How to connect the business layer to the data layer
> - How dependency injection enables testable code
> - Best practices for layered architecture integration

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed database setup and Subscriber model
> - ✓ Database migrations applied (`flask db upgrade`)
> - ✓ Flask shell can create and query Subscribers

## Exercise Steps

### Overview

1. **Create the Subscriber Repository**
2. **Update the Subscription Service**
3. **Update the Route for Full Integration**
4. **Test Your Implementation**

### **Step 1:** Create the Subscriber Repository

The repository pattern encapsulates all database operations for a specific model. Instead of scattering SQLAlchemy queries throughout your code, the repository provides a clean interface for data access. This makes your business layer independent of the database implementation.

1. **Navigate to** the `app/data/repositories` directory

2. **Create a new file** named `subscriber_repository.py`

3. **Add the following code:**

   > `app/data/repositories/subscriber_repository.py`

   ```python
   """
   Subscriber repository - handles database operations for subscribers.

   This repository encapsulates all SQLAlchemy queries for the Subscriber model,
   keeping the business layer free from database-specific code.
   """

   from app import db
   from app.data.models.subscriber import Subscriber


   class SubscriberRepository:
       """
       Data access layer for Subscriber operations.

       Provides CRUD operations and queries for the Subscriber model.
       All database interactions for subscribers should go through this class.
       """

       def find_by_email(self, email: str) -> Subscriber | None:
           """
           Find a subscriber by email address.

           Args:
               email: The email address to search for (case-insensitive)

           Returns:
               Subscriber if found, None otherwise
           """
           return Subscriber.query.filter_by(email=email.lower()).first()

       def exists(self, email: str) -> bool:
           """
           Check if a subscriber with the given email exists.

           Args:
               email: The email address to check

           Returns:
               True if subscriber exists, False otherwise
           """
           return self.find_by_email(email) is not None

       def create(self, email: str, name: str) -> Subscriber:
           """
           Create a new subscriber.

           Args:
               email: The subscriber's email address
               name: The subscriber's display name

           Returns:
               The newly created Subscriber instance

           Raises:
               IntegrityError: If email already exists (unique constraint violation)
           """
           subscriber = Subscriber(email=email, name=name)
           db.session.add(subscriber)
           db.session.commit()
           return subscriber
   ```

4. **Update** the repositories package to expose the repository:

   > `app/data/repositories/__init__.py`

   ```python
   """Data repositories package."""

   from .subscriber_repository import SubscriberRepository

   __all__ = ["SubscriberRepository"]
   ```

> ℹ️ **Concept Deep Dive**
>
> **Why Repository Pattern?**
>
> - **Abstraction**: Business layer doesn't know about SQLAlchemy
> - **Testability**: Can mock the repository for unit tests
> - **Single Responsibility**: Each repository handles one model
> - **Consistency**: All data access follows the same pattern
>
> **Common Repository Methods:**
>
> - `find_by_*` - Query by specific field(s)
> - `exists` - Check existence without loading full object
> - `create` - Insert new record
> - `update` - Modify existing record
> - `delete` - Remove record
>
> The repository calls `db.session.commit()` to persist changes. In more complex applications, you might use a Unit of Work pattern to manage transactions across multiple repositories.
>
> ⚠️ **Common Mistakes**
>
> - Forgetting to call `db.session.commit()` means changes aren't saved
> - Not handling case sensitivity in email lookups causes duplicates
> - Putting business logic in repositories (validation belongs in services)
> - Not catching `IntegrityError` when unique constraints fail
>
> ✓ **Quick check:** Repository file created with `find_by_email`, `exists`, and `create` methods

### **Step 2:** Update the Subscription Service

Now we connect the business layer to the data layer. The service will use the repository to check for duplicates and save new subscribers. This is dependency injection - the repository is passed to the service, making it testable and flexible.

1. **Open** the file `app/business/services/subscription_service.py`

2. **Replace** the contents with the following updated service:

   > `app/business/services/subscription_service.py`

   ```python
   """
   Subscription service - handles validation and business logic for subscriptions.

   This service sits between the presentation layer (routes) and the data layer
   (repositories). It validates input, applies business rules, and orchestrates
   data storage through the repository.
   """

   import re
   from datetime import datetime, timezone

   from app.data.repositories.subscriber_repository import SubscriberRepository


   class SubscriptionService:
       """Service for handling subscription-related business logic."""

       # Email regex pattern for validation
       EMAIL_PATTERN = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

       def __init__(self, repository: SubscriberRepository | None = None):
           """
           Initialize the subscription service.

           Args:
               repository: SubscriberRepository instance for data operations.
                          If None, creates a new instance.
           """
           self.repository = repository or SubscriberRepository()

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

       def subscribe(self, email: str, name: str | None) -> tuple[bool, str]:
           """
           Full subscription flow: validate, check duplicate, save.

           This method orchestrates the complete subscription process:
           1. Validates the email format
           2. Normalizes email and name
           3. Checks for existing subscription
           4. Saves to database via repository

           Args:
               email: The subscriber's email address
               name: The subscriber's name (optional)

           Returns:
               Tuple of (success, error_message)
               If successful, error_message is empty string
           """
           # Validate email format
           is_valid, error = self.validate_email(email)
           if not is_valid:
               return False, error

           # Normalize inputs
           normalized_email = self.normalize_email(email)
           normalized_name = self.normalize_name(name)

           # Check for duplicate subscription
           if self.repository.exists(normalized_email):
               return False, "This email is already subscribed"

           # Save to database
           self.repository.create(email=normalized_email, name=normalized_name)
           return True, ""

       def process_subscription(self, email: str, name: str | None) -> dict:
           """
           Process and prepare subscription data (legacy method).

           Validates, normalizes, and packages data for storage.
           Note: Prefer using subscribe() for the full flow with persistence.

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
> **Dependency Injection:**
>
> The `__init__` method accepts an optional repository parameter. This pattern enables:
>
> - **Testing**: Pass a mock repository to test service logic without database
> - **Flexibility**: Swap repositories (e.g., in-memory for tests, PostgreSQL for production)
> - **Defaults**: `repository or SubscriberRepository()` creates one if not provided
>
> **The subscribe() Method:**
>
> This is the main orchestration method that coordinates the full flow:
>
> 1. **Validate** - Ensure email format is correct
> 2. **Normalize** - Standardize data format
> 3. **Check duplicate** - Business rule: one subscription per email
> 4. **Persist** - Save through repository
>
> The service owns the business rules (validation, duplicate check) while the repository handles persistence.
>
> ⚠️ **Common Mistakes**
>
> - Checking duplicates before normalizing causes case-sensitive issues
> - Not returning errors from `subscribe()` leaves users confused
> - Calling `process_subscription()` instead of `subscribe()` skips persistence
> - Creating repository inside methods instead of `__init__` breaks injection
>
> ✓ **Quick check:** Service imports repository, has `__init__` with injection, and `subscribe()` method

### **Step 3:** Update the Route for Full Integration

The route now uses the service's `subscribe()` method which handles the complete flow including database persistence. This simplifies the route to focus purely on HTTP concerns.

1. **Open** the file `app/presentation/routes/public.py`

2. **Replace** the `subscribe_confirm` function with the following:

   > `app/presentation/routes/public.py`

   ```python
   """
   Public routes - accessible without authentication.

   This blueprint handles all public-facing pages including the landing page
   and subscription flow.
   """

   from flask import Blueprint, render_template, request

   from app.business.services.subscription_service import SubscriptionService

   bp = Blueprint("public", __name__)


   @bp.route("/")
   def index():
       """Render the landing page."""
       return render_template("index.html")


   @bp.route("/subscribe")
   def subscribe():
       """Render the subscription form."""
       return render_template("subscribe.html")


   @bp.route("/subscribe/confirm", methods=["POST"])
   def subscribe_confirm():
       """Handle subscription form submission."""
       email = request.form.get("email", "")
       name = request.form.get("name", "")

       # Use business layer for full subscription flow
       service = SubscriptionService()
       success, error = service.subscribe(email, name)

       if not success:
           # Return to form with error message, preserving input
           return render_template(
               "subscribe.html",
               error=error,
               email=email,
               name=name,
           )

       # Subscription saved successfully - show thank you page
       # Use normalized values for display
       normalized_email = service.normalize_email(email)
       normalized_name = service.normalize_name(name)

       return render_template(
           "thank_you.html",
           email=normalized_email,
           name=normalized_name,
       )
   ```

> ℹ️ **Concept Deep Dive**
>
> **Simplified Route:**
>
> The route is now much simpler:
>
> 1. Get form data
> 2. Call `service.subscribe()`
> 3. Handle success or error
>
> All the complexity (validation, normalization, duplicate check, database save) is handled by the service.
>
> **Layer Responsibilities:**
>
> - **Route** (Presentation): HTTP request/response, template rendering
> - **Service** (Business): Validation, business rules, orchestration
> - **Repository** (Data): Database queries, persistence
>
> The route doesn't know about the database. The service doesn't know about HTTP. The repository doesn't know about business rules. This separation makes each layer focused and testable.
>
> ⚠️ **Common Mistakes**
>
> - Bypassing the service to call repository directly breaks layering
> - Forgetting to handle the error case leaves users on a broken page
> - Not normalizing values for the thank you page shows raw user input
>
> ✓ **Quick check:** Route calls `service.subscribe()` and handles both success and error cases

### **Step 4:** Test Your Implementation

Verify the complete three-layer integration works by testing the subscription flow end-to-end, including database persistence and duplicate detection.

1. **Start the application:**

   ```bash
   flask run
   ```

2. **Navigate to:** <http://localhost:5000/subscribe>

3. **Test valid subscription:**
   - Enter email: `test@example.com`
   - Enter name: `Test User`
   - Click "Subscribe"
   - Verify you see the thank you page with normalized values

4. **Verify database persistence:**

   ```bash
   sqlite3 instance/news_flash.db "SELECT * FROM subscribers;"
   ```

   You should see the new subscriber with:
   - Auto-generated ID
   - Lowercase email
   - Trimmed name
   - Automatic timestamp

5. **Test duplicate detection:**
   - Go back to <http://localhost:5000/subscribe>
   - Enter the same email: `test@example.com`
   - Click "Subscribe"
   - Verify error message: "This email is already subscribed"
   - Verify you stay on the form with input preserved

6. **Test email normalization:**
   - Enter email: `  ANOTHER@EXAMPLE.COM  ` (with spaces and uppercase)
   - Enter name: `  Another User  ` (with spaces)
   - Click "Subscribe"
   - Verify thank you page shows normalized values
   - Verify database has lowercase email and trimmed name

7. **Verify in database:**

   ```bash
   sqlite3 instance/news_flash.db "SELECT id, email, name FROM subscribers;"
   ```

> ✓ **Success indicators:**
>
> - Form submission saves to database
> - Thank you page shows normalized email and name
> - Duplicate email shows error message
> - Form preserves input on error
> - Database contains correct, normalized data
> - Timestamps are automatically set
>
> ✓ **Final verification checklist:**
>
> - ☐ `subscriber_repository.py` created in `app/data/repositories/`
> - ☐ Repository exposed in `app/data/repositories/__init__.py`
> - ☐ Service updated with repository injection and `subscribe()` method
> - ☐ Route uses `service.subscribe()` for full flow
> - ☐ Valid submissions persist to database
> - ☐ Duplicate emails show error message
> - ☐ Email normalized (lowercase, trimmed) in database
> - ☐ Name normalized or defaults to "Subscriber"

## Common Issues

> **If you encounter problems:**
>
> **"This email is already subscribed" on first try:** Delete test data: `sqlite3 instance/news_flash.db "DELETE FROM subscribers;"`
>
> **"Working outside of application context":** Repository methods must be called within a request or `with app.app_context():`
>
> **Changes not saving:** Verify `db.session.commit()` is called in the repository's `create` method
>
> **"ModuleNotFoundError: No module named 'app.data.repositories'":** Ensure `__init__.py` exists in the repositories directory
>
> **Duplicate check not working:** Verify email is normalized (lowercase) before checking and saving
>
> **Still stuck?** Use Flask shell to test repository methods directly:
>
> ```python
> flask shell
> >>> from app.data.repositories import SubscriberRepository
> >>> repo = SubscriberRepository()
> >>> repo.exists("test@example.com")
> ```

## Summary

You've successfully completed the three-tier architecture integration which:

- ✓ Encapsulates database operations in the repository
- ✓ Connects business layer to data layer with dependency injection
- ✓ Enables duplicate detection through the repository
- ✓ Persists subscriptions to the database

> **Key takeaway:** The three-tier architecture separates concerns cleanly: routes handle HTTP, services handle business logic, repositories handle persistence. Each layer depends only on the layer below it, making the code testable, maintainable, and flexible. You can now change the database (SQLite to PostgreSQL) by only modifying the data layer - the business and presentation layers remain unchanged.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a `get_all()` method to the repository for listing subscribers
> - Implement soft delete with an `is_active` flag
> - Add unit tests for the service using a mock repository
> - Research the Unit of Work pattern for transaction management

## Done! 🎉

Congratulations! You've built a complete three-tier Flask application with proper separation of concerns. The News Flash subscription system now validates input, enforces business rules, and persists data to a database - all through cleanly separated layers. This architecture pattern scales from small applications to enterprise systems.
