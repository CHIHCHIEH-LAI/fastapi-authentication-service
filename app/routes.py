from fastapi import FastAPI, HTTPException, Depends
from datetime import datetime
from app.model import Account
from app.dependencies import get_db
from app.crud import CRUD

db = get_db()

app = FastAPI()

@app.post("/create_account", status_code=201)
async def create_account(account: Account):
    crud = CRUD(db)
    if not crud.create_account(account.username, account.password):
        raise HTTPException(status_code=400, detail="Username already exists")
    
    return {"message": "Account created"}

@app.post("/verify_account", status_code=200)
async def verify_account(account: Account):
    crud = CRUD(db)
    result = crud.read_account(account.username)
    
    if not result:
        raise HTTPException(status_code=404, detail="Username not found")
    
    current_time = datetime.now().replace(microsecond=0)
    failed_attemps = result['failed_attempts']

    if failed_attemps >= 5 and result['last_attempt_time'] and (current_time - result['last_attempt_time']).seconds < 60:
        raise HTTPException(status_code=429, detail="Too many failed attempts. Please wait for one minute before trying again.")
    
    if result['password'] != account.password:
        crud.update_verify_status(account.username, failed_attemps+1, current_time)
        raise HTTPException(status_code=401, detail="Invalid password")
    
    crud.update_verify_status(account.username, 0, current_time)
    return {"message": "Account verified"}