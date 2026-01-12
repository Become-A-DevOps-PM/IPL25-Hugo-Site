# Webinar Information Page

## Goal

Create a dedicated webinar information page displaying event details, agenda, and speakers (PRD requirement FR-001).

> **What you'll learn:**
>
> - Creating new routes and templates in Flask
> - Structuring informational content pages
> - Linking between pages with url_for
> - CSS grid layouts for responsive content

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.3 (Error styling and flash messages)
> - ✓ All 52 tests passing
> - ✓ Understanding of Flask routing and Jinja2 templates

## Exercise Steps

### Overview

1. **Add Webinar Info Route**
2. **Create Webinar Info Template**
3. **Update Landing Page Links**
4. **Update Navigation**
5. **Add CSS for Webinar Page**
6. **Add Webinar Page Tests**
7. **Verify with pytest**

### **Step 1:** Add Webinar Info Route

Add a new route to the main blueprint for the webinar information page.

1. **Open** `application/app/routes/main.py`

2. **Add** the following route after the `thank_you` function:

   ```python
   @main_bp.route('/webinar')
   def webinar_info():
       """Display webinar information page.

       Shows event details including topic, date, time, agenda,
       and speaker information as required by FR-001.
       """
       return render_template('webinar_info.html')
   ```

> ✓ **Quick check:** New route `/webinar` returns `webinar_info.html`

### **Step 2:** Create Webinar Info Template

This page provides comprehensive event information to help users decide to register.

1. **Create** `application/app/templates/webinar_info.html`:

   ```html
   {% extends "base.html" %}

   {% block title %}About the Webinar{% endblock %}

   {% block content %}
   <div class="webinar-info-page">
       <header class="webinar-header">
           <h1>Cloud Infrastructure Fundamentals</h1>
           <p class="subtitle">A hands-on introduction to modern deployment practices</p>
       </header>

       <section class="event-details">
           <h2>Event Details</h2>
           <div class="details-grid">
               <div class="detail-item">
                   <span class="detail-label">Date</span>
                   <span class="detail-value">February 15, 2026</span>
               </div>
               <div class="detail-item">
                   <span class="detail-label">Time</span>
                   <span class="detail-value">10:00 AM - 12:00 PM CET</span>
               </div>
               <div class="detail-item">
                   <span class="detail-label">Platform</span>
                   <span class="detail-value">Microsoft Teams (link sent after registration)</span>
               </div>
               <div class="detail-item">
                   <span class="detail-label">Cost</span>
                   <span class="detail-value">Free</span>
               </div>
           </div>
       </section>

       <section class="agenda">
           <h2>Agenda</h2>
           <ol class="agenda-list">
               <li>
                   <strong>Introduction to Cloud Infrastructure</strong>
                   <span class="duration">(20 min)</span>
                   <p>Understanding the fundamentals of cloud computing and Azure services.</p>
               </li>
               <li>
                   <strong>Infrastructure as Code with Bicep</strong>
                   <span class="duration">(30 min)</span>
                   <p>Learn how to define and deploy infrastructure using declarative templates.</p>
               </li>
               <li>
                   <strong>Flask Application Deployment</strong>
                   <span class="duration">(30 min)</span>
                   <p>Hands-on demonstration of deploying a Python web application to Azure.</p>
               </li>
               <li>
                   <strong>Best Practices &amp; Q&amp;A</strong>
                   <span class="duration">(40 min)</span>
                   <p>Security considerations, monitoring, and audience questions.</p>
               </li>
           </ol>
       </section>

       <section class="speakers">
           <h2>Speakers</h2>
           <div class="speaker-cards">
               <div class="speaker-card">
                   <div class="speaker-info">
                       <h3>Dr. Sarah Chen</h3>
                       <p class="speaker-title">Cloud Solutions Architect</p>
                       <p class="speaker-bio">
                           Sarah has 15 years of experience in cloud infrastructure and has helped
                           hundreds of organizations migrate to Azure. She holds multiple Azure
                           certifications and is a frequent speaker at tech conferences.
                       </p>
                   </div>
               </div>
               <div class="speaker-card">
                   <div class="speaker-info">
                       <h3>Marcus Johnson</h3>
                       <p class="speaker-title">Senior DevOps Engineer</p>
                       <p class="speaker-bio">
                           Marcus specializes in CI/CD pipelines and infrastructure automation.
                           He has authored several open-source tools for Azure deployment and
                           teaches DevOps practices at technical universities.
                       </p>
                   </div>
               </div>
           </div>
       </section>

       <section class="what-youll-learn">
           <h2>What You'll Learn</h2>
           <ul class="learning-outcomes">
               <li>How to provision cloud resources using Infrastructure as Code</li>
               <li>Best practices for Flask application deployment</li>
               <li>Security fundamentals for web applications</li>
               <li>Monitoring and observability strategies</li>
               <li>Cost optimization techniques for cloud infrastructure</li>
           </ul>
       </section>

       <section class="cta-section">
           <h2>Ready to Join?</h2>
           <p>Reserve your spot now and take the first step towards mastering cloud infrastructure.</p>
           <a href="{{ url_for('main.register') }}" class="btn btn-primary btn-lg">Register Now</a>
       </section>

       <p class="back-link"><a href="{{ url_for('main.index') }}">← Back to home</a></p>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> - Semantic HTML sections organize content (header, event-details, agenda, speakers)
> - **url_for()** generates URLs dynamically for internal links
> - Content follows a logical flow: overview → details → agenda → speakers → CTA
>
> ✓ **Quick check:** Template has all required sections and register link

### **Step 3:** Update Landing Page Links

Add a "Learn More" link to the landing page pointing to the webinar info.

1. **Open** `application/app/templates/landing.html`

2. **Replace** with the following content:

   ```html
   {% extends "base.html" %}

   {% block title %}Webinar Registration - Welcome{% endblock %}

   {% block content %}
   <div class="hero">
       <h1>Join Our Upcoming Webinar</h1>
       <p class="lead">Learn about cloud infrastructure and modern deployment practices from industry experts.</p>
       <div class="cta-buttons">
           <a href="{{ url_for('main.register') }}" class="btn btn-primary btn-lg">Register Now</a>
           <a href="{{ url_for('main.webinar_info') }}" class="btn btn-secondary btn-lg">Learn More</a>
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

> ✓ **Quick check:** Landing page has "Learn More" button linking to webinar_info

### **Step 4:** Update Navigation

Add the webinar info link to the navigation menu.

1. **Open** `application/app/templates/base.html`

2. **Update** the nav-links section to include the About link:

   ```html
   <div class="nav-links">
       <a href="{{ url_for('main.index') }}">Home</a>
       <a href="{{ url_for('main.webinar_info') }}">About</a>
       <a href="{{ url_for('main.register') }}">Register</a>
   </div>
   ```

> ✓ **Quick check:** Navigation has Home, About, and Register links

### **Step 5:** Add CSS for Webinar Page

1. **Open** `application/app/static/css/style.css`

2. **Add** the following CSS:

   ```css
   /* ===== Webinar Info Page ===== */
   .webinar-info-page {
       max-width: 900px;
       margin: 0 auto;
   }

   .webinar-header {
       text-align: center;
       margin-bottom: 2.5rem;
       padding-bottom: 1.5rem;
       border-bottom: 2px solid #e9ecef;
   }

   .webinar-header h1 {
       font-size: 2.5rem;
       margin-bottom: 0.5rem;
   }

   .subtitle {
       font-size: 1.25rem;
       color: #6c757d;
   }

   .event-details {
       margin-bottom: 2.5rem;
   }

   .details-grid {
       display: grid;
       grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
       gap: 1rem;
       background: #f8f9fa;
       padding: 1.5rem;
       border-radius: 8px;
   }

   .detail-item {
       display: flex;
       flex-direction: column;
   }

   .detail-label {
       font-weight: bold;
       color: #495057;
       font-size: 0.875rem;
       text-transform: uppercase;
       margin-bottom: 0.25rem;
   }

   .detail-value {
       font-size: 1.1rem;
   }

   .agenda {
       margin-bottom: 2.5rem;
   }

   .agenda-list {
       list-style: none;
       padding: 0;
       counter-reset: agenda-counter;
   }

   .agenda-list li {
       padding: 1.25rem;
       margin-bottom: 1rem;
       background: #fff;
       border-left: 4px solid #007bff;
       border-radius: 0 8px 8px 0;
       box-shadow: 0 2px 4px rgba(0,0,0,0.1);
   }

   .agenda-list li strong {
       display: block;
       font-size: 1.1rem;
       margin-bottom: 0.25rem;
   }

   .duration {
       color: #6c757d;
       font-size: 0.875rem;
   }

   .agenda-list li p {
       margin: 0.5rem 0 0 0;
       color: #495057;
   }

   .speakers {
       margin-bottom: 2.5rem;
   }

   .speaker-cards {
       display: grid;
       grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
       gap: 1.5rem;
   }

   .speaker-card {
       background: #fff;
       border-radius: 8px;
       box-shadow: 0 2px 8px rgba(0,0,0,0.1);
       overflow: hidden;
   }

   .speaker-info {
       padding: 1.5rem;
   }

   .speaker-info h3 {
       margin: 0 0 0.25rem 0;
   }

   .speaker-title {
       color: #007bff;
       font-weight: 500;
       margin-bottom: 0.75rem;
   }

   .speaker-bio {
       color: #495057;
       font-size: 0.95rem;
       line-height: 1.6;
   }

   .what-youll-learn {
       margin-bottom: 2.5rem;
   }

   .learning-outcomes {
       display: grid;
       gap: 0.75rem;
   }

   .learning-outcomes li {
       padding: 0.75rem 1rem;
       background: #e7f3ff;
       border-radius: 4px;
       color: #004085;
   }

   /* ===== Buttons ===== */
   .btn {
       display: inline-block;
       padding: 0.75rem 1.5rem;
       font-size: 1rem;
       font-weight: 500;
       text-decoration: none;
       border-radius: 4px;
       cursor: pointer;
       transition: all 0.15s ease-in-out;
       border: none;
   }

   .btn-primary {
       background-color: #007bff;
       color: white;
   }

   .btn-primary:hover {
       background-color: #0056b3;
   }

   .btn-secondary {
       background-color: #6c757d;
       color: white;
   }

   .btn-secondary:hover {
       background-color: #545b62;
   }

   .btn-lg {
       padding: 1rem 2rem;
       font-size: 1.1rem;
   }

   /* ===== CTA Section ===== */
   .cta-section {
       text-align: center;
       background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
       color: white;
       padding: 3rem 2rem;
       border-radius: 12px;
       margin: 2rem 0;
   }

   .cta-section h2 {
       color: white;
       margin-bottom: 0.5rem;
   }

   .cta-section p {
       margin-bottom: 1.5rem;
       opacity: 0.9;
   }

   .cta-buttons {
       display: flex;
       gap: 1rem;
       justify-content: center;
       flex-wrap: wrap;
   }

   /* ===== Hero Section ===== */
   .hero {
       text-align: center;
       padding: 3rem 1rem;
   }

   .hero h1 {
       font-size: 2.5rem;
       margin-bottom: 1rem;
   }

   .lead {
       font-size: 1.25rem;
       color: #6c757d;
       margin-bottom: 2rem;
   }
   ```

> ✓ **Quick check:** CSS includes webinar page styles, buttons, and hero section

### **Step 6:** Add Webinar Page Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestWebinarInfoPage:
       """Tests for the webinar information page (FR-001)."""

       def test_webinar_info_page_loads(self, client):
           """Test that webinar info page loads successfully."""
           response = client.get('/webinar')
           assert response.status_code == 200

       def test_webinar_info_has_title(self, client):
           """Test that webinar info page has event title."""
           response = client.get('/webinar')
           assert b'Cloud Infrastructure Fundamentals' in response.data

       def test_webinar_info_has_date_time(self, client):
           """Test that webinar info page shows date and time."""
           response = client.get('/webinar')
           assert b'February 15, 2026' in response.data
           assert b'10:00 AM' in response.data

       def test_webinar_info_has_agenda(self, client):
           """Test that webinar info page includes agenda."""
           response = client.get('/webinar')
           assert b'Agenda' in response.data
           assert b'Infrastructure as Code' in response.data

       def test_webinar_info_has_speakers(self, client):
           """Test that webinar info page shows speakers."""
           response = client.get('/webinar')
           assert b'Speakers' in response.data
           assert b'Sarah Chen' in response.data
           assert b'Marcus Johnson' in response.data

       def test_webinar_info_has_register_link(self, client):
           """Test that webinar info page links to registration."""
           response = client.get('/webinar')
           assert b'/register' in response.data
           assert b'Register Now' in response.data

       def test_landing_page_links_to_webinar_info(self, client):
           """Test that landing page links to webinar info."""
           response = client.get('/')
           assert b'/webinar' in response.data
           assert b'Learn More' in response.data
   ```

> ✓ **Quick check:** 7 new tests for webinar info page content

### **Step 7:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 52 + 7 = 59 tests passing

> ✓ **Success indicators:**
>
> - All 59 tests pass
> - /webinar page displays all event information
> - Landing page links to webinar info

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `/webinar` route exists in `main.py`
> - ☐ `webinar_info.html` has event details, agenda, speakers
> - ☐ `landing.html` has "Learn More" link
> - ☐ Navigation includes "About" link
> - ☐ `style.css` has webinar page styling
> - ☐ `pytest tests/test_routes.py -v` passes (59 tests)

## Common Issues

> **If you encounter problems:**
>
> **404 on /webinar:** Check route is defined and blueprint registered
>
> **Template not found:** Verify filename is `webinar_info.html` (with underscore)
>
> **CSS not applying:** Check CSS file is saved and class names match
>
> **url_for error:** Ensure route function name matches (webinar_info not webinar)

## Summary

You've created the webinar information page:

- ✓ New route serving detailed event information
- ✓ Professional layout with event details, agenda, speakers
- ✓ Call-to-action linking to registration
- ✓ Updated navigation and landing page
- ✓ 7 new tests verify page content

> **Key takeaway:** Informational pages help users make decisions. A well-structured webinar page with clear CTAs increases registration conversions.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add speaker photos to the speaker cards
> - Implement a countdown timer to the event
> - Add social sharing buttons for the webinar

## Done!

Webinar information page is complete. Next phase will enhance the admin dashboard with sorting and statistics.
