# Components (C3)

## Components (C4 Model Level 3)

This document zooms into the Application Server container to show its internal structure and how components collaborate to fulfill the system's responsibilities.

### Flask Application Components

![](embed:C3-Components)

### Component Inventory

#### Infrastructure Components

| Component | Technology | Responsibility |
|-----------|------------|----------------|
| **nginx Reverse Proxy** | nginx | SSL termination, request forwarding to Flask |
| **SSL Certificate** | OpenSSL | Self-signed TLS certificate for HTTPS |

#### Application Components

| Component | Technology | Responsibility | Source |
|-----------|------------|----------------|--------|
| **WSGI Server** | Gunicorn | Production HTTP server, process management | `wsgi.py` |
| **Main Blueprint** | Flask | Landing page route (`/`) | `app/routes/main.py` |
| **Demo Blueprint** | Flask | Demo form and entry management (`/demo`) | `app/routes/demo.py` |
| **API Blueprint** | Flask | Health and entries endpoints (`/api/*`) | `app/routes/api.py` |
| **Template Engine** | Jinja2 | HTML rendering with data binding | `app/templates/` |
| **Data Models** | SQLAlchemy | Object-relational mapping | `app/models/entry.py` |
| **Service Layer** | Python | Business logic, data access | `app/services/entry_service.py` |

### Component Details

#### 1. Application Factory

The application uses Flask's factory pattern for configuration flexibility:

**Entry Point** (`app/__init__.py`):

```python
def create_app(config_class=None):
    app = Flask(__name__)
    app.config.from_object(config_class or Config)

    # Initialize extensions
    db.init_app(app)

    # Register blueprints
    from app.routes.main import main_bp
    from app.routes.demo import demo_bp
    from app.routes.api import api_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(demo_bp)
    app.register_blueprint(api_bp)

    return app
```

#### 2. Blueprints (Route Handlers)

The application organizes routes into three blueprints:

| Blueprint | Prefix | Routes | Purpose |
|-----------|--------|--------|---------|
| `main_bp` | `/` | `GET /` | Landing page |
| `demo_bp` | `/demo` | `GET /demo`, `POST /demo` | Demo form |
| `api_bp` | `/api` | `GET /api/health`, `GET /api/entries` | JSON API |

**API Endpoints**:

| Route | Method | Purpose | Response |
|-------|--------|---------|----------|
| `/` | GET | Landing page | HTML |
| `/demo` | GET | Display form + entries | HTML |
| `/demo` | POST | Create new entry | Redirect |
| `/api/health` | GET | Health check | `{"status": "ok"}` |
| `/api/entries` | GET | List all entries | JSON array |

#### 3. Service Layer

Business logic is encapsulated in service classes:

**EntryService** (`app/services/entry_service.py`):

```python
class EntryService:
    @staticmethod
    def get_all_entries():
        return Entry.query.order_by(Entry.created_at.desc()).all()

    @staticmethod
    def create_entry(value):
        entry = Entry(value=value)
        db.session.add(entry)
        db.session.commit()
        return entry
```

#### 4. Data Models

Single model representing a demo entry:

**Entry Model** (`app/models/entry.py`):

```python
class Entry(db.Model):
    __tablename__ = 'entries'

    id = db.Column(db.Integer, primary_key=True)
    value = db.Column(db.String(500), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self):
        return {
            'id': self.id,
            'value': self.value,
            'created_at': self.created_at.isoformat()
        }
```

#### 5. Configuration

Environment-specific configuration:

| Class | DATABASE_URL | Use |
|-------|--------------|-----|
| `DevelopmentConfig` | SQLite (`local.db`) | Local development |
| `ProductionConfig` | From environment | Azure deployment |
| `TestingConfig` | SQLite in-memory | pytest |

#### 6. WSGI Server

**Entry Point** (`wsgi.py`):

```python
from app import create_app
app = create_app()
```

**Gunicorn Configuration** (via systemd):

```bash
gunicorn --bind 0.0.0.0:5001 --workers 2 wsgi:app
```

| Setting | Value | Purpose |
|---------|-------|---------|
| `--bind` | `0.0.0.0:5001` | Listen on all interfaces |
| `--workers` | `2` | Worker processes |
| Module | `wsgi:app` | Import `app` from `wsgi.py` |

### Data Flow

#### Entry Creation Flow

```
1. User submits form at /demo
   POST /demo {value: "test entry"}
        |
        v
2. nginx receives HTTPS request
   SSL termination, forward to 127.0.0.1:5001
        |
        v
3. Gunicorn routes to demo_bp
   @demo_bp.route('/demo', methods=['POST'])
        |
        v
4. Demo route calls EntryService
   EntryService.create_entry(value)
        |
        v
5. EntryService creates Entry model
   entry = Entry(value=value)
   db.session.add(entry)
   db.session.commit()
        |
        v
6. Redirect to GET /demo
   return redirect(url_for('demo.demo'))
        |
        v
7. Demo route queries entries
   EntryService.get_all_entries()
        |
        v
8. Render template with data
   render_template('demo.html', entries=entries)
```

#### Request/Response Cycle

```
+---------+     +---------+     +---------+     +---------+
| Browser |---->| nginx   |---->| Gunicorn|---->| Flask   |
+---------+     +---------+     +---------+     +---------+
                                                     |
                    +--------------------------------+
                    v
              +---------+     +---------+
              | Service |---->| Model   |
              +---------+     +---------+
                                   |
                                   v
                             +-----------+
                             | PostgreSQL|
                             +-----------+
```

### Dependencies

#### Python Packages (`requirements.txt`)

| Package | Purpose |
|---------|---------|
| `Flask` | Web framework |
| `Flask-SQLAlchemy` | ORM integration |
| `gunicorn` | Production WSGI server |
| `psycopg2-binary` | PostgreSQL driver |

#### External Dependencies

| Dependency | Source | Purpose |
|------------|--------|---------|
| `DATABASE_URL` | `/etc/flask-app/app.env` | PostgreSQL connection string |
| PostgreSQL | Azure PaaS | Data persistence |
| nginx | Same VM | Reverse proxy, SSL |

### Testing

The application includes comprehensive tests:

```bash
cd application
pytest tests/ -v              # Run all tests
pytest --cov=app tests/       # With coverage
```

**Test Coverage**:

| Area | Tests |
|------|-------|
| Entry Model | `__repr__`, `to_dict` |
| Health Endpoint | Status 200, JSON response |
| Landing Page | Status 200, content verification |
| Demo Page | GET, POST, form handling |
| Entries API | JSON response, entry listing |

### Next Level

See [Deployment](05-deployment.md) for how this system is deployed on Azure infrastructure.
