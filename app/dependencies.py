from contextlib import contextmanager
import os
from pymysql.connections import Connection
from pymysql.cursors import DictCursor
from app.database import Database

host = os.environ.get('MYSQL_HOST', 'localhost')
user = os.environ.get('MYSQL_USER', 'root')
password = os.environ.get('MYSQL_PASSWORD', 'root')
db_name = os.environ.get('MYSQL_DB', 'accountDB')

def get_db():
    db = Connection(host=host, user=user, password=password, db=db_name, cursorclass=DictCursor, charset='utf8')
    return db

# @contextmanager
# def get_db():
#     try:
#         db = Database(host, user, password, db_name)
#         db.connect()
#         yield db.connection
#     finally:
#         db.disconnect()

