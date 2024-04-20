from pymysql.connections import Connection
from pymysql.cursors import DictCursor

class Database:
    def __init__(self, host, user, password, db):
        self.connection = None
        self.host = host
        self.user = user
        self.password = password
        self.db = db

    def connect(self):
        if not self.connection or not self.connection.open:
            self.connection = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')

    def disconnect(self):
        if self.connection and self.connection.open:
            self.connection.close()
            self.connection = None