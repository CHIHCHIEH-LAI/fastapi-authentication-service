import pytest
from pymysql.connections import Connection
from pymysql.cursors import DictCursor
from datetime import datetime
from app.crud import CRUD

def test_crud_operations():
    # Assuming a connection object is available
    db = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')
    crud = CRUD(db)

    # Test create_account method
    assert crud.create_account('testuser', 'testpassword'), "Should return True for new user"
    assert not crud.create_account('testuser', 'testpassword'), "Should return False for existing user"

    # Test read_account method
    account = crud.read_account('testuser')
    assert account is not None, "Should return a dictionary for existing user"
    assert account['username'] == 'testuser', "Username should match"
    assert account['password'] == 'testpassword', "Password should match"

    # Test update_failed_attempts method
    current_time = datetime.now().replace(microsecond=0)
    crud.update_failed_attempts('testuser', 3, current_time)
    account = crud.read_account('testuser')
    assert account['failed_attempts'] == 3, "Failed attempts should be updated"
    assert account['last_attempt_time'] == current_time, "Last attempt time should be updated"

    # Cleanup
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM accounts WHERE username = 'testuser'")
        db.commit()