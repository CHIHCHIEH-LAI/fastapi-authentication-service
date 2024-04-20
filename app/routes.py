from fastapi import FastAPI, Depends
from fastapi.responses import JSONResponse
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
        return JSONResponse(status_code=400, content={"success": False, "reason": "Username already exists"})
    
    return {"success": True, "reason": "Account created"}

@app.post("/verify_account", status_code=200)
async def verify_account(account: Account):
    crud = CRUD(db)
    result = crud.read_account(account.username)
    
    if not result:
        return JSONResponse(status_code=404, content={"success": False, "reason": "Username not found"})
    
    current_time = datetime.now().replace(microsecond=0)
    failed_attempts = result['failed_attempts']

    if failed_attempts >= 5 and result['last_attempt_time'] and (current_time - result['last_attempt_time']).seconds < 60:
        return JSONResponse(status_code=429, content={"success": False, "reason": "Too many failed attempts. Try again in 60 seconds"})
    
    if result['password'] != account.password:
        crud.update_verify_status(account.username, failed_attempts+1, current_time)
        return JSONResponse(status_code=401, content={"success": False, "reason": "Invalid password"})
    
    crud.update_verify_status(account.username, 0, current_time)
    return {"success": True, "reason": "Account verified"}