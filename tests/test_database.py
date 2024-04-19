import pytest
from app.database import Database
from pymysql.err import OperationalError

def test_database_connection():
    db = Database('localhost', 'root', 'root', 'accountDB')

    # Test connect method
    try:
        db.connect()
    except OperationalError:
        pytest.fail("Database connection failed")

    assert db.connection is not None, "Connection should be established"
    assert db.connection.open, "Connection should be open"

    # Test disconnect method
    db.disconnect()

    assert db.connection is None, "Connection should be closed"
