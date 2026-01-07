"""Flask extensions initialization.

Extensions are instantiated here without being bound to an application.
They are initialized with the app in the application factory.
"""

from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

# Database ORM
db = SQLAlchemy()

# Database migrations
migrate = Migrate()
