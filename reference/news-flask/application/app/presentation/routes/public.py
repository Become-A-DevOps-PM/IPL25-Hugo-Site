"""
Public routes - accessible without authentication.

This blueprint handles all public-facing pages including the landing page
and subscription flow.
"""

from flask import Blueprint, render_template, request

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
    email = request.form.get("email")
    name = request.form.get("name", "Subscriber")

    # Verification: print to terminal (no persistence yet)
    print(f"New subscription: {email} ({name})")

    return render_template("thank_you.html", email=email, name=name)
