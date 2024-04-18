import pymysql
from pymysql.cursors import DictCursor
import os
from dotenv import load_dotenv

load_dotenv()

class Database:
    def __init__(self):
        self.connection = None
        self.host = os.getenv('MYSQL_HOST', 'localhost')
        self.user = os.getenv('MYSQL_USER', 'root')
        self.password = os.getenv('MYSQL_PASSWORD', '')
        self.db = os.getenv('MYSQL_DB', 'test')

    def connect(self):
        if not self.connection or not self.connection.open:
            self.connection = pymysql.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.db,
                cursorclass=DictCursor,
                charset='utf8mb4'
            )

    def disconnect(self):
        if self.connection and self.connection.open:
            self.connection.close()
            self.connection = None