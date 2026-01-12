# CM Corp Webinar Platform Roadmap: Phases 5-12

## Document Purpose

This roadmap extends the dev-3tier-flask application from a single-webinar MVP (Phases 1-4 complete) to a full-fledged, EU-compliant webinar platform. It serves as:

1. **Implementation Guide** - Detailed specifications for each phase
2. **Educational Resource** - Demonstrates that real applications require attention to compliance, security, and operations alongside features
3. **Project Planning Tool** - Can be used to scope work and track progress

---

## Background and Rationale

### Current State (Phases 1-4 Complete)

The application currently provides:
- Landing page with webinar call-to-action
- Single hardcoded webinar registration
- Admin authentication with secure password storage
- Attendee list with sorting and CSV export
- 118 passing unit tests
- Automated Azure deployment

### Why This Roadmap?

CM Corp wants to:
1. **Support multiple webinars** - The current single-webinar model doesn't scale
2. **Comply with European standards** - GDPR requires consent management, data access rights, and retention policies
3. **Improve user experience** - Email confirmations, calendar integration
4. **Enable marketing operations** - Speaker profiles, analytics, content management

### Design Philosophy

**Balanced Development:** Each phase intentionally mixes:
- New features (business value)
- Compliance requirements (legal necessity)
- Security hardening (risk reduction)
- Operational improvements (maintainability)

**Iterative Approach:** No aspect is "perfected" in one phase. Instead:
- Phase 5 introduces GDPR consent basics
- Phase 8 adds data access rights
- Phase 11 completes with retention/erasure

This mirrors real-world development where requirements evolve and compliance deepens over time.

**Simplicity First:** Each phase introduces concepts at a basic level. Students learn that:
- You must address compliance/security, but can start simple
- Iteration improves each area over multiple cycles
- "Good enough now, better later" is pragmatic

---

## Work Distribution Analysis

Realistic breakdown of effort across phases:

| Category | Percentage | Rationale |
|----------|------------|-----------|
| New Features | 50% | Core business value |
| Compliance/Legal | 25% | GDPR is mandatory for EU operations |
| Security Hardening | 15% | Defense in depth, risk mitigation |
| Operations/Monitoring | 10% | Long-term maintainability |

This distribution reflects that **half of software development work is "invisible"** - users don't see compliance, security, or operational features, but they're essential.

---

## Phase Summary

| Phase | Theme | Primary Deliverable | Secondary Focus |
|-------|-------|---------------------|-----------------|
| 5 | Privacy Foundation | Privacy policy + consent capture | GDPR basics |
| 6 | Multi-Webinar | Webinar model + CRUD | Data architecture |
| 7 | Communication | Email confirmations | Audit logging |
| 8 | Data Rights | Self-service data access | GDPR Art. 15 |
| 9 | Content Management | Speaker profiles | Input validation |
| 10 | Analytics | Admin dashboard | Privacy-compliant metrics |
| 11 | Data Lifecycle | Retention policies | GDPR Art. 17 |
| 12 | Production Readiness | Performance + security audit | Operational docs |

---

## Phase 5: Privacy Foundation

**Theme:** Establish GDPR basics before adding more data collection

### Business Context

Before collecting more user data (multi-webinar registrations, speaker info, analytics), CM Corp must establish legal foundations:
- Privacy policy explaining data use
- Explicit consent capture
- Terms of service

### Deliverables

#### New Pages
- `/privacy-policy` - Comprehensive GDPR-compliant privacy policy
- `/terms` - Terms of service
- Footer links on all pages

#### Database Changes

```python
# app/models/registration.py - new fields
gdpr_consent = db.Column(db.Boolean, nullable=False, default=False)
marketing_consent = db.Column(db.Boolean, nullable=False, default=False)
consent_timestamp = db.Column(db.DateTime, nullable=True)
privacy_policy_version = db.Column(db.String(20), nullable=True)
```

#### Form Changes

```python
# app/forms/registration.py - new fields
gdpr_consent = BooleanField(
    'I have read and accept the Privacy Policy',
    validators=[DataRequired(message='You must accept the privacy policy')]
)
marketing_consent = BooleanField(
    'I consent to receive marketing communications about future webinars'
)
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/routes/legal.py` | Create | Legal pages blueprint |
| `app/templates/legal/privacy_policy.html` | Create | Privacy policy content |
| `app/templates/legal/terms.html` | Create | Terms of service content |
| `app/templates/base.html` | Modify | Add footer with legal links |
| `app/models/registration.py` | Modify | Add consent fields |
| `app/forms/registration.py` | Modify | Add consent checkboxes |
| `app/templates/register.html` | Modify | Display consent checkboxes |
| `app/services/registration_service.py` | Modify | Record consent timestamp |
| `migrations/versions/xxx_add_consent_fields.py` | Create | Database migration |

### Test Requirements

```python
# tests/test_legal.py
def test_privacy_policy_page_loads():
    """Privacy policy returns 200 OK"""

def test_terms_page_loads():
    """Terms of service returns 200 OK"""

# tests/test_registration.py (additions)
def test_registration_requires_gdpr_consent():
    """Registration fails without GDPR consent"""

def test_consent_timestamp_recorded():
    """Consent timestamp saved on registration"""

def test_privacy_version_recorded():
    """Privacy policy version saved on registration"""

def test_csv_export_includes_consent_fields():
    """CSV export contains consent data"""
```

### Acceptance Criteria

- [ ] Privacy policy page accessible at `/privacy-policy`
- [ ] Terms page accessible at `/terms`
- [ ] Footer links visible on all pages
- [ ] Registration form shows consent checkboxes
- [ ] GDPR consent is required (form validation)
- [ ] Marketing consent is optional
- [ ] Consent timestamp recorded in database
- [ ] Privacy policy version recorded
- [ ] CSV export includes consent fields
- [ ] All existing tests still pass
- [ ] New tests added and passing

---

## Phase 6: Multi-Webinar Support

**Theme:** Core feature expansion with proper data architecture

### Business Context

CM Corp plans multiple webinars. The current hardcoded single-webinar approach must evolve to:
- Support unlimited webinars
- Track registrations per webinar
- Allow admin management of webinars

### Data Model

```python
# app/models/webinar.py (new)
class Webinar(db.Model):
    __tablename__ = 'webinars'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    slug = db.Column(db.String(100), unique=True, nullable=False, index=True)
    description = db.Column(db.Text, nullable=True)
    event_date = db.Column(db.DateTime, nullable=False)
    registration_deadline = db.Column(db.DateTime, nullable=True)
    max_attendees = db.Column(db.Integer, nullable=True)  # None = unlimited
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, onupdate=datetime.utcnow)

    # Relationships
    registrations = db.relationship('Registration', backref='webinar', lazy='dynamic')

# app/models/registration.py (modification)
webinar_id = db.Column(db.Integer, db.ForeignKey('webinars.id'), nullable=True)
# nullable=True for backward compatibility with existing registrations
```

### New Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/webinars` | GET | List upcoming and past webinars |
| `/webinars/<slug>` | GET | Individual webinar details |
| `/webinars/<slug>/register` | GET/POST | Webinar-specific registration |
| `/admin/webinars` | GET | List all webinars (admin) |
| `/admin/webinars/new` | GET/POST | Create webinar form |
| `/admin/webinars/<id>/edit` | GET/POST | Edit webinar |
| `/admin/webinars/<id>/delete` | POST | Soft-delete webinar |
| `/admin/webinars/<id>/attendees` | GET | Per-webinar attendee list |

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/models/webinar.py` | Create | Webinar model |
| `app/services/webinar_service.py` | Create | Webinar business logic |
| `app/routes/webinars.py` | Create | Public webinar routes |
| `app/forms/webinar.py` | Create | Admin webinar form |
| `app/templates/webinars/list.html` | Create | Webinar listing |
| `app/templates/webinars/detail.html` | Create | Webinar detail page |
| `app/templates/webinars/register.html` | Create | Webinar registration |
| `app/templates/admin/webinars/list.html` | Create | Admin webinar list |
| `app/templates/admin/webinars/form.html` | Create | Admin webinar form |
| `app/models/registration.py` | Modify | Add webinar_id FK |
| `app/templates/landing.html` | Modify | Show next upcoming webinar |
| `migrations/versions/xxx_add_webinar_model.py` | Create | Migration |

### Compliance Consideration

**Data Minimization:** Only collect fields necessary for each webinar. Consider:
- Which fields are truly required?
- Can job_title be optional for some webinars?
- Should company field be conditional?

### Test Requirements

```python
# tests/test_webinars.py (new)
def test_webinar_creation():
    """Admin can create webinar"""

def test_webinar_listing_shows_active_only():
    """Public listing excludes inactive webinars"""

def test_past_webinars_shown_separately():
    """Past webinars in separate section"""

def test_registration_links_to_webinar():
    """Registration saved with webinar_id"""

def test_capacity_limit_enforced():
    """Registration rejected when webinar full"""

def test_deadline_enforced():
    """Registration rejected after deadline"""
```

### Acceptance Criteria

- [ ] Webinar model with all fields
- [ ] Public webinar listing at `/webinars`
- [ ] Individual webinar pages with registration link
- [ ] Webinar-specific registration flow
- [ ] Admin CRUD for webinars
- [ ] Per-webinar attendee lists
- [ ] Landing page shows next webinar dynamically
- [ ] Capacity limits enforced (if set)
- [ ] Registration deadline enforced (if set)
- [ ] Soft-delete preserves data integrity

---

## Phase 7: Email Communication

**Theme:** User experience improvement with audit trail

### Business Context

Users expect confirmation emails after registering. Additionally:
- Calendar integration (ICS) improves attendance
- Audit trail of communications supports GDPR accountability

### Email Types

1. **Registration Confirmation** (immediate)
   - Thank you message
   - Webinar details
   - ICS calendar attachment
   - Link to data access portal (Phase 8)

2. **Reminder Email** (future enhancement)
   - 24 hours before event
   - 1 hour before event

### Data Model

```python
# app/models/email_log.py (new)
class EmailLog(db.Model):
    __tablename__ = 'email_logs'

    id = db.Column(db.Integer, primary_key=True)
    recipient_email = db.Column(db.String(120), nullable=False, index=True)
    email_type = db.Column(db.String(50), nullable=False)  # confirmation, reminder, marketing
    subject = db.Column(db.String(200), nullable=False)
    sent_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='sent')  # sent, failed, bounced
    registration_id = db.Column(db.Integer, db.ForeignKey('registrations.id'), nullable=True)
    webinar_id = db.Column(db.Integer, db.ForeignKey('webinars.id'), nullable=True)
```

### Email Service Architecture

```python
# app/services/email_service.py
class EmailService:
    def send_confirmation(self, registration: Registration) -> bool:
        """Send registration confirmation with ICS attachment"""

    def send_reminder(self, registration: Registration, hours_before: int) -> bool:
        """Send reminder email"""

    def _log_email(self, recipient: str, email_type: str, subject: str, status: str):
        """Create audit log entry"""

    def _generate_ics(self, webinar: Webinar) -> str:
        """Generate ICS calendar file content"""
```

### Configuration

```python
# config.py additions
MAIL_SERVER = os.environ.get('MAIL_SERVER', 'smtp.sendgrid.net')
MAIL_PORT = int(os.environ.get('MAIL_PORT', 587))
MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() == 'true'
MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER', 'webinars@cmcorp.example')
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/models/email_log.py` | Create | Email audit model |
| `app/services/email_service.py` | Create | Email sending logic |
| `app/utils/ics_generator.py` | Create | Calendar file generation |
| `app/templates/email/confirmation.html` | Create | HTML email template |
| `app/templates/email/confirmation.txt` | Create | Plain text fallback |
| `app/templates/admin/email_logs.html` | Create | Admin email log view |
| `app/routes/admin.py` | Modify | Add email log route |
| `app/services/registration_service.py` | Modify | Trigger confirmation email |
| `config.py` | Modify | Add mail configuration |
| `requirements.txt` | Modify | Add Flask-Mail |

### Compliance Consideration

**Audit Trail:** Email logs support GDPR Article 5 accountability:
- Demonstrate what communications were sent
- Evidence of consent-based marketing
- Track unsubscribe requests

### Test Requirements

```python
# tests/test_email.py (new)
def test_confirmation_email_sent_on_registration():
    """Email service called after successful registration"""

def test_ics_attachment_generated():
    """ICS file contains correct webinar details"""

def test_email_log_created():
    """EmailLog entry created for each sent email"""

def test_email_failure_logged():
    """Failed emails recorded with error status"""

def test_marketing_email_respects_consent():
    """Marketing emails only sent if marketing_consent=True"""
```

### Acceptance Criteria

- [ ] Confirmation email sent on registration
- [ ] ICS calendar attachment included
- [ ] Plain text and HTML email versions
- [ ] Email log entry created for each email
- [ ] Admin can view email logs
- [ ] Email failures logged with status
- [ ] Marketing emails respect consent flag
- [ ] Unsubscribe link in marketing emails

---

## Phase 8: Data Subject Rights

**Theme:** GDPR compliance - right to access

### Business Context

GDPR Article 15 gives individuals the right to:
- Know if their data is being processed
- Access a copy of their personal data
- Receive data in a portable format

This phase implements a self-service portal for data access.

### User Flow

1. User visits `/my-data`
2. User enters email address
3. System sends verification email with secure link
4. User clicks link (valid 24 hours)
5. User sees their registration data
6. User can download as JSON
7. User can request deletion (creates admin ticket)

### Data Model

```python
# app/models/data_request.py (new)
class DataRequest(db.Model):
    __tablename__ = 'data_requests'

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), nullable=False, index=True)
    request_type = db.Column(db.String(20), nullable=False)  # access, deletion, export
    token = db.Column(db.String(100), unique=True, nullable=False)
    token_expires = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.String(20), default='pending')  # pending, completed, expired
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed_at = db.Column(db.DateTime, nullable=True)
    ip_address = db.Column(db.String(45), nullable=True)  # For audit
```

### Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/my-data` | GET | Data access landing page |
| `/my-data` | POST | Submit email for verification |
| `/my-data/verify/<token>` | GET | Verify token and show data |
| `/my-data/export/<token>` | GET | Download data as JSON |
| `/my-data/delete/<token>` | POST | Request data deletion |
| `/admin/data-requests` | GET | View pending requests |
| `/admin/data-requests/<id>/complete` | POST | Mark request complete |

### JSON Export Format

```json
{
  "export_date": "2024-01-15T10:30:00Z",
  "data_subject": {
    "email": "user@example.com"
  },
  "registrations": [
    {
      "webinar": "Introduction to DevOps",
      "registration_date": "2024-01-10T14:22:00Z",
      "name": "John Doe",
      "company": "Example Corp",
      "job_title": "Developer",
      "gdpr_consent": true,
      "marketing_consent": false
    }
  ],
  "emails_received": [
    {
      "type": "confirmation",
      "sent_at": "2024-01-10T14:22:05Z",
      "subject": "Registration Confirmed"
    }
  ]
}
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/models/data_request.py` | Create | Data request model |
| `app/services/data_rights_service.py` | Create | Data rights logic |
| `app/routes/data_rights.py` | Create | Data rights routes |
| `app/utils/token_generator.py` | Create | Secure token generation |
| `app/templates/data_rights/request.html` | Create | Email input form |
| `app/templates/data_rights/verify_sent.html` | Create | Check email message |
| `app/templates/data_rights/view_data.html` | Create | Display user data |
| `app/templates/data_rights/deletion_requested.html` | Create | Deletion confirmation |
| `app/templates/admin/data_requests.html` | Create | Admin request queue |
| `app/templates/email/data_access.html` | Create | Verification email |

### Security Considerations

- Tokens must be cryptographically secure (use `secrets.token_urlsafe()`)
- Tokens expire after 24 hours
- Rate limit email requests (prevent enumeration)
- Log all data access for audit trail
- Verify email ownership before showing data

### Test Requirements

```python
# tests/test_data_rights.py (new)
def test_data_request_creates_token():
    """Email submission creates secure token"""

def test_verification_email_sent():
    """Verification email sent to user"""

def test_valid_token_shows_data():
    """Valid token displays user data"""

def test_expired_token_rejected():
    """Expired token returns error"""

def test_invalid_token_rejected():
    """Invalid token returns 404"""

def test_json_export_complete():
    """JSON export contains all user data"""

def test_deletion_request_creates_ticket():
    """Deletion request creates admin ticket"""

def test_rate_limiting_on_requests():
    """Multiple requests from same IP limited"""
```

### Acceptance Criteria

- [ ] Self-service data access portal at `/my-data`
- [ ] Email verification required before showing data
- [ ] Secure tokens with 24-hour expiry
- [ ] User can view all their registration data
- [ ] User can download data as JSON
- [ ] User can request data deletion
- [ ] Admin can view pending deletion requests
- [ ] Admin can mark requests complete
- [ ] All requests logged for audit
- [ ] Rate limiting prevents abuse

---

## Phase 9: Content Management

**Theme:** Scalable content with security hardening

### Business Context

As the webinar catalog grows, CM Corp needs:
- Speaker profiles (reusable across webinars)
- Rich text descriptions (Markdown)
- Potentially speaker photos

This phase also adds security hardening appropriate for user-generated content.

### Data Model

```python
# app/models/speaker.py (new)
class Speaker(db.Model):
    __tablename__ = 'speakers'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    title = db.Column(db.String(100), nullable=True)
    bio = db.Column(db.Text, nullable=True)
    photo_url = db.Column(db.String(500), nullable=True)  # External URL initially
    linkedin_url = db.Column(db.String(500), nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Many-to-many relationship
webinar_speakers = db.Table('webinar_speakers',
    db.Column('webinar_id', db.Integer, db.ForeignKey('webinars.id'), primary_key=True),
    db.Column('speaker_id', db.Integer, db.ForeignKey('speakers.id'), primary_key=True)
)

# Update Webinar model
speakers = db.relationship('Speaker', secondary=webinar_speakers, backref='webinars')
```

### Security Hardening

#### Content Security Policy (CSP)

```python
# app/__init__.py - after_request handler
@app.after_request
def add_security_headers(response):
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' https:; "
        "font-src 'self'; "
        "frame-ancestors 'none'; "
    )
    return response
```

#### Rate Limiting

```python
# app/middleware/rate_limit.py
from functools import wraps
from flask import request, abort
import time

# Simple in-memory rate limiter (use Redis in production)
request_counts = {}

def rate_limit(max_requests=10, window_seconds=60):
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            ip = request.remote_addr
            now = time.time()
            # ... rate limiting logic
            return f(*args, **kwargs)
        return wrapped
    return decorator
```

#### Markdown Sanitization

```python
# app/utils/markdown_renderer.py
import markdown
import bleach

ALLOWED_TAGS = ['p', 'h1', 'h2', 'h3', 'ul', 'ol', 'li', 'strong', 'em', 'a', 'code', 'pre']
ALLOWED_ATTRS = {'a': ['href', 'title']}

def render_markdown(text: str) -> str:
    """Render Markdown to HTML with XSS protection"""
    html = markdown.markdown(text)
    return bleach.clean(html, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRS)
```

### Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/speakers` | GET | List all active speakers |
| `/speakers/<id>` | GET | Speaker profile with webinars |
| `/admin/speakers` | GET | List speakers (admin) |
| `/admin/speakers/new` | GET/POST | Create speaker |
| `/admin/speakers/<id>/edit` | GET/POST | Edit speaker |

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/models/speaker.py` | Create | Speaker model |
| `app/services/speaker_service.py` | Create | Speaker business logic |
| `app/routes/speakers.py` | Create | Speaker routes |
| `app/forms/speaker.py` | Create | Admin speaker form |
| `app/utils/markdown_renderer.py` | Create | Safe Markdown rendering |
| `app/middleware/rate_limit.py` | Create | Rate limiting |
| `app/templates/speakers/list.html` | Create | Speaker listing |
| `app/templates/speakers/profile.html` | Create | Speaker profile |
| `app/templates/admin/speakers/` | Create | Admin speaker templates |
| `app/__init__.py` | Modify | Add CSP headers |
| `app/models/webinar.py` | Modify | Add speakers relationship |
| `requirements.txt` | Modify | Add markdown, bleach |

### Test Requirements

```python
# tests/test_speakers.py (new)
def test_speaker_crud():
    """Admin can create, read, update speakers"""

def test_speaker_webinar_association():
    """Speakers can be linked to webinars"""

# tests/test_security.py (new)
def test_csp_header_present():
    """CSP header on all responses"""

def test_markdown_xss_prevented():
    """Malicious markdown sanitized"""

def test_rate_limiting_triggers():
    """Excessive requests blocked"""
```

### Acceptance Criteria

- [ ] Speaker model with profile fields
- [ ] Speaker-webinar many-to-many relationship
- [ ] Speaker listing and profile pages
- [ ] Admin CRUD for speakers
- [ ] Markdown rendering for descriptions
- [ ] XSS protection in Markdown
- [ ] CSP headers on all pages
- [ ] Rate limiting on registration forms
- [ ] All existing tests pass

---

## Phase 10: Analytics Dashboard

**Theme:** Operational visibility with privacy compliance

### Business Context

Marketing needs visibility into:
- Registration trends
- Popular webinars
- Conversion rates
- Geographic distribution

All analytics must be privacy-compliant (aggregate data only).

### Dashboard Features

1. **Registration Overview**
   - Total registrations (all time, this month, this week)
   - Registrations by day (line chart)
   - Registrations by webinar (bar chart)

2. **Webinar Performance**
   - Most popular webinars
   - Registration vs. capacity
   - Registration timeline per webinar

3. **Audience Insights**
   - Company domain distribution (aggregate)
   - Job title distribution (aggregate)
   - Geographic hints from email domains

### Data Model

```python
# app/models/admin_log.py (new)
class AdminLog(db.Model):
    """Audit log for admin actions"""
    __tablename__ = 'admin_logs'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    action = db.Column(db.String(50), nullable=False)  # view, export, delete, edit
    resource_type = db.Column(db.String(50), nullable=False)  # webinar, registration, speaker
    resource_id = db.Column(db.Integer, nullable=True)
    details = db.Column(db.Text, nullable=True)  # JSON with additional context
    ip_address = db.Column(db.String(45), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
```

### Statistics Service

```python
# app/services/statistics_service.py
class StatisticsService:
    def get_registration_summary(self) -> dict:
        """Aggregate registration counts"""

    def get_registrations_by_day(self, days: int = 30) -> list:
        """Daily registration counts for charting"""

    def get_webinar_statistics(self) -> list:
        """Per-webinar registration counts"""

    def get_domain_distribution(self) -> list:
        """Aggregate by email domain (top 10)"""

    def get_job_title_distribution(self) -> list:
        """Aggregate by job title (top 10)"""
```

### Privacy Compliance

- **No PII in charts** - Only aggregate counts
- **Domain aggregation** - Show "gmail.com: 45" not individual emails
- **Minimum threshold** - Don't show categories with <5 entries
- **No tracking cookies** - All analytics from database
- **Admin action logging** - Who viewed what data

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/models/admin_log.py` | Create | Admin audit model |
| `app/services/statistics_service.py` | Create | Aggregation logic |
| `app/routes/dashboard.py` | Create | Dashboard routes |
| `app/templates/admin/dashboard.html` | Create | Dashboard page |
| `app/static/js/charts.js` | Create | Chart.js initialization |
| `app/decorators/audit.py` | Create | Audit logging decorator |
| `app/routes/admin.py` | Modify | Add audit logging |
| `requirements.txt` | Modify | Add chart library if needed |

### Test Requirements

```python
# tests/test_dashboard.py (new)
def test_dashboard_requires_login():
    """Dashboard returns 401 without auth"""

def test_statistics_aggregate_correctly():
    """Registration counts match database"""

def test_no_pii_in_statistics():
    """Statistics endpoints return no individual data"""

def test_admin_actions_logged():
    """Viewing dashboard creates log entry"""
```

### Acceptance Criteria

- [ ] Dashboard page with charts
- [ ] Registration trend visualization
- [ ] Per-webinar statistics
- [ ] Domain distribution (aggregate)
- [ ] Job title distribution (aggregate)
- [ ] All charts use aggregate data only
- [ ] Admin actions logged
- [ ] No third-party tracking
- [ ] Dashboard loads under 2 seconds

---

## Phase 11: Data Lifecycle

**Theme:** GDPR compliance - retention and erasure

### Business Context

GDPR requires:
- Data retention policies (don't keep data forever)
- Right to erasure (delete on request)
- Data minimization (remove unnecessary data)

### Retention Policy

| Data Type | Retention Period | Action |
|-----------|------------------|--------|
| Active registrations | Until webinar + 90 days | Anonymize |
| Cancelled registrations | 30 days | Delete |
| Email logs | 1 year | Delete |
| Admin logs | 2 years | Archive/Delete |
| Data requests | 3 years | Archive |

### Anonymization vs. Deletion

**Anonymization** preserves statistics:
```python
# Before
{"name": "John Doe", "email": "john@example.com", "company": "Example Corp"}

# After anonymization
{"name": "ANONYMIZED", "email": "anon_12345@anonymized.local", "company": "ANONYMIZED"}
```

**Deletion** removes entirely (for cancelled registrations).

### Implementation

```python
# app/services/data_cleanup_service.py
class DataCleanupService:
    def identify_expired_registrations(self) -> list:
        """Find registrations past retention period"""

    def anonymize_registration(self, registration: Registration):
        """Replace PII with anonymous values"""

    def delete_old_email_logs(self, days: int = 365):
        """Remove email logs older than retention"""

    def process_deletion_request(self, email: str):
        """Complete GDPR deletion request"""

    def generate_cleanup_report(self) -> dict:
        """Report on cleanup actions taken"""
```

### CLI Command

```bash
# Run manually or via cron
flask cleanup-data --dry-run  # Preview what would be deleted
flask cleanup-data            # Execute cleanup
flask cleanup-data --report   # Generate cleanup report
```

### Configuration

```python
# config.py
RETENTION_REGISTRATION_DAYS = 90  # Days after webinar
RETENTION_CANCELLED_DAYS = 30
RETENTION_EMAIL_LOG_DAYS = 365
RETENTION_ADMIN_LOG_DAYS = 730
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/services/data_cleanup_service.py` | Create | Cleanup logic |
| `app/cli/cleanup_commands.py` | Create | CLI commands |
| `app/models/cleanup_log.py` | Create | Cleanup audit trail |
| `app/services/data_rights_service.py` | Modify | Add deletion logic |
| `config.py` | Modify | Add retention settings |
| `docs/DATA-RETENTION-POLICY.md` | Create | Policy documentation |

### Test Requirements

```python
# tests/test_cleanup.py (new)
def test_expired_registrations_identified():
    """Old registrations flagged for cleanup"""

def test_anonymization_removes_pii():
    """Anonymized records contain no PII"""

def test_anonymization_preserves_statistics():
    """Webinar counts remain accurate after anonymization"""

def test_deletion_request_removes_all_data():
    """GDPR deletion removes all user data"""

def test_cleanup_logged():
    """Cleanup actions recorded for audit"""

def test_dry_run_no_changes():
    """Dry run doesn't modify database"""
```

### Acceptance Criteria

- [ ] Retention periods configurable
- [ ] Automatic identification of expired data
- [ ] Anonymization preserves statistics
- [ ] Deletion removes all PII
- [ ] CLI command for manual/scheduled cleanup
- [ ] Dry-run mode for preview
- [ ] Cleanup actions logged
- [ ] GDPR deletion request workflow complete
- [ ] Data retention policy documented

---

## Phase 12: Production Readiness

**Theme:** Performance, security audit, and operational excellence

### Business Context

Before considering the platform "production ready," ensure:
- Performance is acceptable
- Security has been audited
- Operational procedures documented
- Monitoring in place

### Enhanced Health Checks

```python
# app/routes/api.py
@api_bp.route('/health')
def health_check():
    """Comprehensive health check"""
    checks = {
        'database': check_database(),
        'email': check_email_config(),
        'disk_space': check_disk_space(),
        'memory': check_memory()
    }

    status = 'healthy' if all(c['status'] == 'ok' for c in checks.values()) else 'degraded'

    return jsonify({
        'status': status,
        'checks': checks,
        'version': app.config.get('VERSION', 'unknown'),
        'timestamp': datetime.utcnow().isoformat()
    })
```

### Performance Optimization

1. **Database Query Analysis**
   - Add query logging in development
   - Identify N+1 queries
   - Add indexes where needed

2. **Caching Strategy**
   - Cache webinar listings (5 min TTL)
   - Cache speaker profiles (10 min TTL)
   - Cache dashboard statistics (1 min TTL)

3. **Response Optimization**
   - Gzip compression
   - Static file caching headers
   - Minified CSS/JS

### Security Audit Checklist

```markdown
## Security Audit Checklist

### Authentication & Authorization
- [ ] Passwords hashed with strong algorithm (PBKDF2/bcrypt)
- [ ] Session tokens secure and httponly
- [ ] CSRF protection on all forms
- [ ] Rate limiting on login endpoint
- [ ] Account lockout after failed attempts

### Input Validation
- [ ] All user input validated server-side
- [ ] SQL injection prevented (ORM usage)
- [ ] XSS prevented (template escaping, CSP)
- [ ] File upload validation (if applicable)

### Data Protection
- [ ] HTTPS enforced
- [ ] Sensitive data encrypted at rest
- [ ] Database credentials secured
- [ ] No secrets in code repository

### Headers & Configuration
- [ ] Security headers present (CSP, X-Frame-Options, etc.)
- [ ] Debug mode disabled in production
- [ ] Error messages don't leak information
- [ ] Server version headers removed

### Logging & Monitoring
- [ ] Authentication attempts logged
- [ ] Admin actions logged
- [ ] Errors logged (without sensitive data)
- [ ] Log retention policy defined
```

### Operational Documentation

1. **Incident Response Plan**
   - Contact list
   - Severity definitions
   - Response procedures
   - Communication templates

2. **Backup Procedures**
   - Database backup schedule
   - Backup verification process
   - Restore procedures
   - Recovery time objectives

3. **Deployment Procedures**
   - Pre-deployment checklist
   - Rollback procedures
   - Post-deployment verification

### Dependency Security

```yaml
# .github/workflows/security-scan.yml
name: Security Scan
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run pip-audit
        run: |
          pip install pip-audit
          pip-audit -r requirements.txt
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/routes/api.py` | Modify | Enhanced health check |
| `app/middleware/logging.py` | Create | Structured logging |
| `app/middleware/caching.py` | Create | Simple caching |
| `docs/SECURITY-AUDIT-CHECKLIST.md` | Create | Security checklist |
| `docs/INCIDENT-RESPONSE.md` | Create | Incident procedures |
| `docs/BACKUP-PROCEDURES.md` | Create | Backup documentation |
| `docs/DEPLOYMENT-PROCEDURES.md` | Create | Deployment guide |
| `.github/workflows/security-scan.yml` | Create | Dependency scanning |

### Test Requirements

```python
# tests/test_production.py (new)
def test_health_check_comprehensive():
    """Health check reports all components"""

def test_no_debug_in_production():
    """Debug mode off in production config"""

def test_security_headers_complete():
    """All security headers present"""

def test_error_pages_no_leak():
    """Error pages don't expose internals"""
```

### Acceptance Criteria

- [ ] Enhanced health check endpoint
- [ ] Query performance analyzed and optimized
- [ ] Caching implemented for read-heavy endpoints
- [ ] Security audit checklist completed
- [ ] Incident response plan documented
- [ ] Backup procedures documented
- [ ] Dependency scanning in CI
- [ ] All security headers present
- [ ] No sensitive data in error responses
- [ ] Production configuration hardened

---

## Implementation Guidelines

### Standard Phase Workflow

Each phase should follow this workflow:

1. **Planning**
   - Create `docs/PHASE-X-IMPLEMENTATION-GUIDE.md`
   - Define acceptance criteria
   - Identify all files to create/modify

2. **Database First**
   - Create migration
   - Test migration up/down
   - Verify no data loss

3. **Backend Implementation**
   - Models
   - Services
   - Routes
   - Forms
   - Write tests alongside code

4. **Frontend Implementation**
   - Templates
   - Static files
   - Test rendering

5. **Integration Testing**
   - End-to-end tests
   - Update verification tests

6. **Documentation**
   - Update README.md
   - Update CLAUDE.md
   - Update PRD.md if scope changed

### Commit Strategy

Atomic commits per phase:

```
Phase X: Add database models and migrations
Phase X: Implement service layer
Phase X: Add routes and forms
Phase X: Create templates
Phase X: Add tests
Phase X: Update documentation
```

### Testing Standards

Each phase must:
- Maintain all existing tests passing
- Add unit tests for new features
- Add integration tests for critical paths
- Update deployment verification tests

### Definition of Done

A phase is complete when:
- [ ] All acceptance criteria met
- [ ] All tests passing (existing + new)
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Deployed to staging/production
- [ ] Verification tests pass

---

## Success Metrics

By Phase 12 completion:

| Category | Target |
|----------|--------|
| **Features** | Multi-webinar, email, speakers, dashboard |
| **GDPR Compliance** | Consent, access, erasure, retention |
| **Security** | CSP, rate limiting, audit logs, security audit |
| **Operations** | Health checks, monitoring, documented procedures |
| **Testing** | >200 tests, >80% coverage |
| **Documentation** | Complete operational documentation |

---

## Educational Notes for Students

This roadmap demonstrates key principles of professional software development:

### 1. Compliance is Not Optional

GDPR affects every feature that touches user data. You can't add it later - it must be designed in from the start. Notice how:
- Phase 5 establishes consent before Phase 6 adds more data collection
- Phase 8 adds data access rights before Phase 10 adds analytics
- Phase 11 completes with retention/erasure

### 2. Security is Continuous

Security isn't a phase you do once. Each phase adds security measures:
- Phase 5: Consent validation
- Phase 7: Audit logging
- Phase 9: CSP headers, rate limiting, input sanitization
- Phase 12: Security audit checklist

### 3. Features Enable Compliance

Some features exist primarily to enable compliance:
- Email system (Phase 7) enables data access verification (Phase 8)
- Admin logging (Phase 10) enables GDPR accountability
- Cleanup jobs (Phase 11) enable retention compliance

### 4. Operations Matter

Users never see:
- Health check endpoints
- Audit logs
- Backup procedures
- Incident response plans

But these are essential for a production system. Phase 12 dedicates entirely to operational excellence.

### 5. Iteration is Normal

Notice that we don't "perfect" anything in one phase:
- Basic consent in Phase 5 → Full data rights in Phase 8 → Retention in Phase 11
- Basic security headers in Phase 4 → CSP in Phase 9 → Full audit in Phase 12

Real software evolves incrementally. "Good enough now, better later" is pragmatic.

### 6. The 50/50 Split

Roughly half of development effort is "invisible" work:
- 50% Features (what users see)
- 50% Compliance + Security + Operations (what users don't see)

This is normal and expected. Plan for it.

---

## Appendix: Technology Decisions

### Email Service Options

| Option | Pros | Cons |
|--------|------|------|
| SendGrid | Easy setup, free tier | Third-party dependency |
| Mailgun | Good deliverability | Cost at scale |
| Azure Communication Services | Azure integration | Learning curve |
| Self-hosted SMTP | Full control | Deliverability challenges |

**Recommendation:** SendGrid for learning, Azure Communication Services for production Azure integration.

### Analytics Options

| Option | Pros | Cons |
|--------|------|------|
| Custom (database) | Full control, no cookies | More development work |
| Plausible | Privacy-focused, simple | Third-party, cost |
| Matomo | Self-hosted, feature-rich | Complex setup |
| Google Analytics | Free, powerful | Privacy concerns |

**Recommendation:** Custom database analytics for GDPR compliance and learning value.

### Caching Options

| Option | Pros | Cons |
|--------|------|------|
| Flask-Caching (simple) | Easy, no dependencies | Single-server only |
| Redis | Scalable, feature-rich | Additional infrastructure |
| Memcached | Fast, simple | Additional infrastructure |

**Recommendation:** Flask-Caching with simple backend for learning, Redis for production scale.
