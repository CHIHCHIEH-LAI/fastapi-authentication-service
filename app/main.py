from fastapi import FastAPI, HTTPException, Depends
from app.schemas import Account
from app.dependencies import get_db
from app.crud import CRUD

app = FastAPI()

@app.post("/create_account")
async def create_account(account: Account, db = Depends(get_db)):
    crud = CRUD(db)
    if not crud.create_account(account.username, account.password):
        raise HTTPException(status_code=400, detail="Username already exists")
    return {"message": "Account created"}

@app.post("/verify-account/")
async def verify_account(account: Account, db = Depends(get_db)):
    crud = CRUD(db)
    accountExist, passwordMatch = crud.verify_account(account.username, account.password)
    if not accountExist:
        raise HTTPException(status_code=400, detail="Account does not exist")
    if not passwordMatch:
        raise HTTPException(status_code=400, detail="Invalid password")
    return {"message": "Account verified"}