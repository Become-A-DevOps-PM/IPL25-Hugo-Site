# News Flash

A newsletter subscription application built with Flask, demonstrating three-tier architecture.

## Quick Start

```bash
# Navigate to application directory
cd application

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env

# Run the application
flask run
```

Visit http://localhost:5000 to see the landing page.

## Project Structure

```
application/
├── app/
│   ├── presentation/    # What users see (routes, templates)
│   ├── business/        # Business rules and logic
│   └── data/            # Database models and access
├── requirements.txt
└── tests/
```

## Features

- Landing page with hero section
- Newsletter subscription modal (placeholder)
- Responsive design with inline CSS
- Flask application factory pattern

## Development

```bash
# Run with debug mode
flask run --debug

# Run tests
pytest
```

## Architecture

This project uses **three-tier architecture** with folder names that match the architectural layers:

1. **Presentation** (`app/presentation/`) - Routes and templates
2. **Business** (`app/business/`) - Services and business logic
3. **Data** (`app/data/`) - Models and repositories

See `CLAUDE.md` for detailed documentation.
