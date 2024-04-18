import pymysql
from pymysql.cursors import DictCursor

class Database:
    def __init__(self, host='localhost', user='root', password='', db='test'):
        self.connection = None
        self.host = host
        self.user = user
        self.password = password
        self.db = db

    def connect(self):
        if not self.connection or not self.connection.open:
            self.connection = pymysql.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.db,
                cursorclass=DictCursor,
                charset='utf8mb4',
                autocommit=True
            )

    def disconnect(self):
        if self.connection and self.connection.open:
            self.connection.close()
            self.connection = None