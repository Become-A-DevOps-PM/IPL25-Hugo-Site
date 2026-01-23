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
