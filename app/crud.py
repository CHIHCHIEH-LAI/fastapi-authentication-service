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
            self.db.commit()
        return True

    def read_account(self, username: str) -> bool:
        with self.db.cursor() as cursor:
            cursor.execute("SELECT * FROM accounts WHERE username = %s", (username,))
            return cursor.fetchone()
        
    def update_verify_status(self, username: str, failed_attempts: int, current_time) -> None:
        with self.db.cursor() as cursor:
            cursor.execute("UPDATE accounts SET failed_attempts = %s, last_attempt_time = %s WHERE username = %s", (failed_attempts, current_time, username))
            self.db.commit()