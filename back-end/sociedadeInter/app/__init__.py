from flask import Flask
from .config import Config
from .database import init_db

from flask_cors import CORS

app = Flask(__name__)
app.config.from_object(Config)

init_db(app)

from .routes import api_blueprint
app.register_blueprint(api_blueprint)

CORS(app)