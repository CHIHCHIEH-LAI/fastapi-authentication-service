from pymysql.connections import Connection

class CRUD:

    def __init__(self, db: Connection):
        self.db = db

    def create_account(self, username: str, password: str) -> bool:
        with self.db.cursor() as cursor:
            # Check if the username already exists
            cursor.execute("SELECT * FROM accounts WHERE username = %s", (username,))
            if cursor.fetchone():
                return False # Username already exists
            
            # Create the account
            cursor.execute("INSERT INTO accounts (username, password) VALUES (%s, %s)", (username, password))
            db.commit()
        return True

    def verify_account(self, username: str, password: str) -> bool:
        with self.db.cursor() as cursor:
            cursor.execute("SELECT * FROM accounts WHERE username = %s", (username,))

            result = cursor.fetchone()

            if not result:
                return (False, False) # Username doesn't exist
            
            if result['password'] != password:
                return (True, False) # Password is incorrect

            return (True, True)