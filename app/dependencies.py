from contextlib import contextmanager
from app.database import Database

@contextmanager
def get_db():
    db = Database()
    try:
        db.connection()
        yield db.connection
    finally:
        db.disconnect()