# Hello Flask

The simplest possible Flask application - a "Hello World" example with no dependencies beyond Flask itself.

## Quick Start

```bash
# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install Flask
pip install -r requirements.txt

# Run the application with debug mode
flask run --debug
```

<details>
<summary>Windows instructions</summary>

```cmd
# Create and activate virtual environment
python -m venv .venv
.venv\Scripts\activate

# Install Flask
pip install -r requirements.txt

# Run the application with debug mode
flask run --debug
```

</details>

The `--debug` flag enables hot reload - the server automatically restarts when you modify the code.

> **Tip:** If port 5000 is already in use (common on macOS), use a different port:
> `flask run --debug --port 5001`

Open http://localhost:5000 in your browser. You should see:

```
Hello, World!
```

## What's Included

| File | Purpose |
|------|---------|
| `app.py` | Complete Flask application (~10 lines) |
| `requirements.txt` | Single dependency: Flask |

## What's NOT Included (By Design)

This reference is intentionally minimal:

- No database or SQLAlchemy
- No HTML templates
- No configuration classes
- No deployment scripts
- No tests
- No Docker/containerization
