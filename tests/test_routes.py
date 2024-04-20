import pytest
from fastapi.testclient import TestClient
from pymysql.connections import Connection
from pymysql.cursors import DictCursor
from app.routes import app

client = TestClient(app)

def test_create_account():
    response = client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 201, "Should return 201 for new user"
    assert response.json() == {"message": "Account created"}

    response = client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 400, "Should return 400 for existing user"
    assert response.json() == {"detail": "Username already exists"}

    # Cleanup
    db = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM accounts WHERE username = 'testuser'")
        db.commit()
    db.close()

def test_verify_account():

    response = client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    response = client.post("/verify_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 200, "Should return 200 for existing user"

    response = client.post("/verify_account", json={"username": "nonexisttestuser", "password": "testPASSWORD123"})
    assert response.status_code == 404, "Should return 404 for nonexistent user"
    assert response.json() == {"detail": "Username not found"}
    
    # Cleanup
    db = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM accounts WHERE username = 'testuser'")
        db.commit()
    db.close()