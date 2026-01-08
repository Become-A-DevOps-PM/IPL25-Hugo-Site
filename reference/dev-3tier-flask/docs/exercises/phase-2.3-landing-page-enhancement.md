# Enhancing the Landing Page with a Call-to-Action

## Goal

Transform the landing page into a webinar registration entry point with a prominent call-to-action button.

> **What you'll learn:**
>
> - How to structure landing pages for conversion
> - Using Flask templates with Jinja2
> - Testing HTML content presence

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.2 (Registration Service)
> - ✓ Basic HTML understanding
> - ✓ 21 tests passing

## Exercise Steps

### Overview

1. **Update the Landing Page Template**
2. **Add Tests for Enhanced Landing Page**
3. **Verify with pytest**

### **Step 1:** Update the Landing Page Template

The enhanced landing page features a hero section with a clear call-to-action.

1. **Open** `application/app/templates/landing.html`

2. **Replace** the entire contents with:

   ```html
   {% extends "base.html" %}

   {% block title %}Webinar Registration - Welcome{% endblock %}

   {% block content %}
   <div class="hero">
       <h1>Join Our Upcoming Webinar</h1>
       <p class="lead">Learn about cloud infrastructure and modern deployment practices from industry experts.</p>
       <div class="cta-section">
           <a href="/register" class="btn btn-primary btn-lg">Register Now</a>
       </div>
   </div>

   <div class="features">
       <h2>What You'll Learn</h2>
       <ul>
           <li>Modern infrastructure as code practices</li>
           <li>Azure deployment strategies</li>
           <li>Best practices for Flask applications</li>
       </ul>
   </div>

   <div class="demo-link">
       <p><small>Looking for the Phase 1 demo? <a href="{{ url_for('demo.index') }}">Visit the demo page</a></small></p>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> The landing page structure follows conversion best practices:
>
> - **Hero Section**: Prominent headline and value proposition
> - **Call-to-Action**: Clear, action-oriented button ("Register Now")
> - **Features List**: Supporting benefits to reinforce the value
> - **Demo Link**: Preserved Phase 1 functionality for continuity
>
> The CTA links to `/register` which will be implemented in Phase 2.4.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to link to the demo page (breaks Phase 1)
> - Using vague CTA text ("Click Here" instead of "Register Now")
>
> ✓ **Quick check:** Hero, CTA button, features list, demo link present

### **Step 2:** Add Tests for Enhanced Landing Page

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class for the enhanced landing page:

   ```python
   class TestLandingPageEnhanced:
       """Tests for enhanced landing page with CTA."""

       def test_landing_page_has_register_link(self, client):
           """Test that landing page contains register link."""
           response = client.get('/')
           assert response.status_code == 200
           assert b'/register' in response.data
           assert b'Register Now' in response.data

       def test_landing_page_has_hero_section(self, client):
           """Test that landing page has hero content."""
           response = client.get('/')
           assert b'Join Our Upcoming Webinar' in response.data

       def test_landing_page_links_to_demo(self, client):
           """Test that landing page still links to demo."""
           response = client.get('/')
           assert b'/demo' in response.data
   ```

> ✓ **Quick check:** Three new tests for register link, hero, and demo link

### **Step 3:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (21 existing + 3 new = 24 tests)

> ✓ **Success indicators:**
>
> - All 24 tests pass
> - Landing page shows hero section
> - CTA button visible with correct text

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `landing.html` contains hero section with webinar title
> - ☐ `landing.html` contains "Register Now" link to `/register`
> - ☐ `landing.html` still links to `/demo` (Phase 1 preserved)
> - ☐ `pytest tests/test_routes.py -v` passes (24 tests)

## Common Issues

> **If you encounter problems:**
>
> **Template syntax error:** Check Jinja2 block tags match
>
> **Demo link test fails:** Ensure url_for still references demo.index
>
> **Missing content in tests:** Verify exact text matches (case-sensitive)
>
> **Still stuck?** Compare with the original landing.html in git history

## Summary

You've enhanced the landing page with:

- ✓ Hero section with compelling headline
- ✓ Prominent "Register Now" call-to-action
- ✓ Feature list supporting the value proposition
- ✓ Preserved link to Phase 1 demo
- ✓ Three tests verifying the enhancements

> **Key takeaway:** Landing pages drive user action. A clear call-to-action with supporting content creates a path to conversion (registration).

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add CSS styling to base.html for the hero section
> - Add an event countdown timer
> - Add speaker information section

## Done!

The landing page now drives users toward registration. Next phase will create the registration form.
