import pytest
from fastapi.testclient import TestClient
from pymysql.connections import Connection
from pymysql.cursors import DictCursor
from app.routes import app

client = TestClient(app)
db = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')

def check_input_validation(url):
    response = client.post(url, json={"username": "te", "password": "testPASSWORD123"})
    assert response.status_code == 422, "Should return 422 for invalid username"
    assert response.json() == {"success": False, "reason": "Username must be between 3 and 32 characters"}

    response = client.post(url, json={"username": "t"*33, "password": "testPASSWORD123"})
    assert response.status_code == 422, "Should return 422 for invalid username"
    assert response.json() == {"success": False, "reason": "Username must be between 3 and 32 characters"}

    response = client.post(url, json={"username": "testuser", "password": "testPAS"})
    assert response.status_code == 422, "Should return 422 for invalid password"
    assert response.json() == {"success": False, "reason": "Password must be between 8 and 32 characters"}

    response = client.post(url, json={"username": "testuser", "password": "t"*33})
    assert response.status_code == 422, "Should return 422 for invalid password"
    assert response.json() == {"success": False, "reason": "Password must be between 8 and 32 characters"}

    response = client.post(url, json={"username": "testuser", "password": "testpassword123"})
    assert response.status_code == 422, "Should return 422 for invalid password"
    assert response.json() == {"success": False, "reason": "Password must contain at least one lowercase letter, one uppercase letter, and one number"}

    response = client.post(url, json={"username": "testuser", "password": "TESTPASSWORD123"})
    assert response.status_code == 422, "Should return 422 for invalid password"
    assert response.json() == {"success": False, "reason": "Password must contain at least one lowercase letter, one uppercase letter, and one number"}

    response = client.post(url, json={"username": "testuser", "password": "testPassword"})
    assert response.status_code == 422, "Should return 422 for invalid password"
    assert response.json() == {"success": False, "reason": "Password must contain at least one lowercase letter, one uppercase letter, and one number"}


@pytest.fixture(scope="session", autouse=True)
def cleanup():
    yield  # This is where the test function will run
    # Cleanup
    db = Connection(host='localhost', user='root', password='root', db='accountDB', cursorclass=DictCursor, charset='utf8mb4')
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM accounts WHERE username = 'testuser'")
        db.commit()
    db.close()

def test_create_account():

    check_input_validation("/create_account")
    
    response = client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 201, "Should return 201 for new user"
    assert response.json() == {"success": True, "reason": "Account created"}

    response = client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 409, "Should return 400 for existing user"
    assert response.json() == {"success": False, "reason": "Username already exists"}

def test_verify_account():

    check_input_validation("/verify_account")

    client.post("/create_account", json={"username": "testuser", "password": "testPASSWORD123"})
    response = client.post("/verify_account", json={"username": "testuser", "password": "testPASSWORD123"})
    assert response.status_code == 200, "Should return 200 for existing user"
    assert response.json() == {"success": True, "reason": "Account verified"}

    response = client.post("/verify_account", json={"username": "nonexisttestuser", "password": "testPASSWORD123"})
    assert response.status_code == 404, "Should return 404 for nonexistent user"
    assert response.json() == {"success": False, "reason": "Username not found"}
    
    response = client.post("/verify_account", json={"username": "testuser", "password": "testPASSWORD1"})
    assert response.status_code == 401, "Should return 401 for invalid password"
    assert response.json() == {"success": False, "reason": "Invalid password"}

    for _ in range(5):
        response = client.post("/verify_account", json={"username": "testuser", "password": "testPASSWORD1"})
    assert response.status_code == 429, "Should return 429 for too many requests"
    assert response.json() == {"success": False, "reason": "Too many failed attempts. Try again in 60 seconds"}