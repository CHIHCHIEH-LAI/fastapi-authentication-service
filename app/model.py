from pydantic import BaseModel, field_validator
import re

class Account(BaseModel):
    username: str
    password: str

    @field_validator('username')
    def validate_username(cls, value):
        if not (3 <= len(value) <= 32):
            raise ValueError('Username must be between 3 and 32 characters')
        return value

    @field_validator('password')
    def validate_password(cls, value):
        if len(value) < 8 or len(value) > 32:
            raise ValueError('Password must be between 8 and 32 characters')
        if not re.search('[a-z]', value) or not re.search('[A-Z]', value) or not re.search('[0-9]', value):
            raise ValueError('Password must contain at least one lowercase letter, one uppercase letter, and one number')
        return value