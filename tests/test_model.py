import pytest
from app.model import Account

def test_account_username_validation():
    with pytest.raises(ValueError) as e:
        Account(username='ab', password='Password123')
    assert 'Username must be between 3 and 32 characters' in str(e.value)

    with pytest.raises(ValueError) as e:
        Account(username='a'*33, password='Password123')
    assert 'Username must be between 3 and 32 characters' in str(e.value)

def test_account_password_validation():
    with pytest.raises(ValueError) as e:
        Account(username='abc', password='pass')
    assert 'Password must be between 8 and 32 characters' in str(e.value)

    with pytest.raises(ValueError) as e:
        Account(username='abc', password='a'*33)
    assert 'Password must be between 8 and 32 characters' in str(e.value)

    with pytest.raises(ValueError) as e:
        Account(username='abc', password='password')
    assert 'Password must contain at least one lowercase letter, one uppercase letter, and one number' in str(e.value)

    with pytest.raises(ValueError) as e:
        Account(username='abc', password='PASSWORD123')
    assert 'Password must contain at least one lowercase letter, one uppercase letter, and one number' in str(e.value)

    with pytest.raises(ValueError) as e:
        Account(username='abc', password='Password')
    assert 'Password must contain at least one lowercase letter, one uppercase letter, and one number' in str(e.value)