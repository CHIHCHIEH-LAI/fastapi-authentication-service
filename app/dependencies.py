from contextlib import contextmanager
import os
from .database import Database

@contextmanager
def get_db():

    host = os.environ.get('MYSQL_HOST', 'localhost')
    user = os.environ.get('MYSQL_USER', 'root')
    password = os.environ.get('MYSQL_PASSWORD', 'root')
    db_name = os.environ.get('MYSQL_DB', 'accountDB')

    db = Database(host, user, password, db_name)
    try:
        db.connect()
        yield db.connection
    finally:
        db.disconnect()