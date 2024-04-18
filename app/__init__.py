from flask import Flask
from .database import init_db
from .auth.routes import auth_blueprint

def create_app():
    app = Flask(__name__)
    app.config.from_pyfile('config.py')
    init_db(app) # Initialize DB connection

    app.register_blueprint(auth_blueprint, url_prefix='/auth')

    return app