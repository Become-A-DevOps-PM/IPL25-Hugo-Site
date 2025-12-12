import os
from flask import Flask, request, render_template_string, jsonify, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)

# Use PostgreSQL if DATABASE_URL is set, otherwise SQLite for local development
database_url = os.environ.get('DATABASE_URL')
if database_url:
    app.config['SQLALCHEMY_DATABASE_URI'] = database_url
else:
    # SQLite fallback for local development (no PostgreSQL required)
    basedir = os.path.abspath(os.path.dirname(__file__))
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(basedir, "local.db")}'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


class Entry(db.Model):
    __tablename__ = 'entries'  # Explicit table name
    id = db.Column(db.Integer, primary_key=True)
    value = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# Create tables on startup
with app.app_context():
    db.create_all()


# HTML Templates
INDEX_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flask App</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        form { margin: 20px 0; }
        input[type="text"] { padding: 10px; width: 300px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
        button:hover { background: #0056b3; }
        .entries { margin-top: 30px; }
        .entry { padding: 10px; border-bottom: 1px solid #eee; }
        .meta { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Flask Demo Application</h1>
    <p>Running on: {{ db_type }}</p>

    <form method="POST" action="/">
        <input type="text" name="value" placeholder="Enter a value..." required>
        <button type="submit">Add Entry</button>
    </form>

    <div class="entries">
        <h2>Recent Entries ({{ count }} total)</h2>
        {% for entry in entries %}
        <div class="entry">
            <strong>{{ entry.value }}</strong>
            <div class="meta">ID: {{ entry.id }} | Created: {{ entry.created_at.strftime('%Y-%m-%d %H:%M:%S') }}</div>
        </div>
        {% else %}
        <p>No entries yet. Add one above!</p>
        {% endfor %}
    </div>

    <p><a href="/entries">View all entries as JSON</a> | <a href="/health">Health check</a></p>
</body>
</html>
'''


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        value = request.form.get('value')
        if value:
            entry = Entry(value=value)
            db.session.add(entry)
            db.session.commit()
        return redirect(url_for('index'))

    entries = Entry.query.order_by(Entry.created_at.desc()).limit(10).all()
    count = Entry.query.count()
    db_type = 'PostgreSQL' if os.environ.get('DATABASE_URL') else 'SQLite (local)'
    return render_template_string(INDEX_TEMPLATE, entries=entries, count=count, db_type=db_type)


@app.route('/entries')
def list_entries():
    entries = Entry.query.order_by(Entry.created_at.desc()).all()
    return jsonify([{
        'id': e.id,
        'value': e.value,
        'created_at': e.created_at.isoformat()
    } for e in entries])


@app.route('/health')
def health():
    """Health check endpoint - returns JSON with status 'ok'"""
    return jsonify({"status": "ok"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
