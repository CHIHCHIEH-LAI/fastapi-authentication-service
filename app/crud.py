from pymysql.connections import Connection

def create_account(db: Connection, username: str, password: str) -> bool:
    with db.cursor() as cursor:
        # Check if the username already exists
        cursor.execute("SELECT * FROM accounts WHERE username = %s", (username,))
        if cursor.fetchone():
            return False # Username already exists
        
        # Create the account
        cursor.execute("INSERT INTO accounts (username, password) VALUES (%s, %s)", (username, password))
        db.commit()
    return True

def verify_account(db: Connection, username: str, password: str) -> bool:
    with db.cursor() as cursor:
        cursor.execute("SELECT * FROM accounts WHERE username = %s", (username,))

        result = cursor.fetchone()

        if not result:
            return (False, False) # Username doesn't exist
        
        if result['password'] != password:
            return (True, False) # Password is incorrect

        return (True, True)