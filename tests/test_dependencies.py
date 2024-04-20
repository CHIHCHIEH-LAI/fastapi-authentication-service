import pytest
from app.dependencies import get_db
from pymysql.connections import Connection

def test_get_db_context_manager():
    db = get_db()
    with db as connection:
        assert isinstance(connection, Connection), "Should return a pymysql Connection object"
        assert connection.open, "Connection should be open"

    assert not connection.open, "Connection should be closed after exiting the context manager"