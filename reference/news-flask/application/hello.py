# hello.py - From Script to Web Application
#
# Step 1a: Run as Python script
#   python hello.py
#
# Step 1b: Run as Flask app
#   flask --app hello run
#   Then visit http://localhost:5000

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello World"


# This only runs when executed as a script (python hello.py)
# When using `flask run`, Flask handles the server
if __name__ == "__main__":
    print("Hello World")
    print("\nTo run as a web app, use: flask --app hello run")
