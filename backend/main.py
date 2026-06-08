from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sys
import os
import cv2
import numpy as np
import shutil
import json
from datetime import datetime

sys.path.append('ai_engine')
sys.path.append('backend')

from database import ProductDatabase
from decision_engine import DecisionEngine
from billing_engine import BillingEngine
try:
    from ocr_module import OCRModule
except Exception:
    OCRModule = None
from ultralytics import YOLO

app = FastAPI(title="VisionPay API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class ProductItem(BaseModel):
    name: str
    brand: Optional[str] = ""
    weight_based: bool = False
    price_per_unit: Optional[float] = 0
    price_per_kg: Optional[float] = 0
    weight_kg: Optional[float] = None
    quantity: Optional[int] = 1

class BillRequest(BaseModel):
    products: List[ProductItem]

print("Loading modules...")
model_path = os.environ.get("MODEL_PATH", "visionpay_combined_best.pt")
model = YOLO(model_path)

try:
    ocr = OCRModule()
    print("OCR loaded! ✅")
except Exception as e:
    print(f"OCR not available (running without it): {e}")
    ocr = None

db_path = os.environ.get("DB_PATH", "visionpay.db")
db = ProductDatabase(db_path)
decision_engine = DecisionEngine(db)
billing = BillingEngine()
print("All modules loaded! ✅")


@app.get("/")
def home():
    return {"message": "VisionPay API Running!", "status": "ok"}


@app.post("/detect")
async def detect_products(file: UploadFile = File(...)):
    temp_path = f"temp_{file.filename}"
    with open(temp_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    
    try:
        results = model.predict(temp_path, conf=0.15, iou=0.45, verbose=False)
        image = cv2.imread(temp_path)
        
        detected_products = []
        for r in results:
            for box in r.boxes:
                cls = int(box.cls)
                conf = float(box.conf)
                class_name = model.names[cls]
                
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cropped = image[y1:y2, x1:x2]
                ocr_data = ocr.extract_text(cropped) if ocr else None
                
                detected_products.append({
                    'class_name': class_name,
                    'confidence': round(conf, 2),
                    'ocr_data': ocr_data,
                    'bbox': [x1, y1, x2, y2]
                })
        
        processed = decision_engine.process_detected_products(detected_products)
        
        # Stock remark add karo
        for product in processed:
            if product.get('id'):
                product['stock_remark'] = db.get_stock_remark(product['id'])
        
        return {
            "status": "success",
            "detected_count": len(processed),
            "products": processed
        }
    
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


@app.post("/generate-bill")
async def generate_bill(request: BillRequest):
    products = [p.dict() for p in request.products]
    bill = billing.generate_bill(products)
    return {"status": "success", "bill": bill}


@app.post("/checkout")
async def checkout(file: UploadFile = File(...)):
    temp_path = f"temp_{file.filename}"
    with open(temp_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    
    try:
        # Step 1 - YOLO detect
        results = model.predict(temp_path, conf=0.15, verbose=False)
        image = cv2.imread(temp_path)
        
        detected_products = []
        for r in results:
            for box in r.boxes:
                cls = int(box.cls)
                conf = float(box.conf)
                class_name = model.names[cls]
                
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cropped = image[y1:y2, x1:x2]
                ocr_data = ocr.extract_text(cropped) if ocr else None
                
                detected_products.append({
                    'class_name': class_name,
                    'confidence': round(conf, 2),
                    'ocr_data': ocr_data,
                })
        
        # Step 2 - Decision engine
        processed = decision_engine.process_detected_products(detected_products)
        
        # Step 3 - Generate bill
        bill = billing.generate_bill(processed)
        
        # Step 4 - Save transaction + realtime stock deduction
        if processed:
            bill_id = f"VP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            db.save_transaction(
                bill_id=bill_id,
                cashier="cashier",
                total=bill['total'],
                items_count=len(processed),
                items_json=json.dumps(processed)
            )
            # Realtime stock deduction
            for product in processed:
                if not product.get('weight_based') and product.get('id'):
                    db.deduct_stock(product['id'], 1)

        # Step 5 - Stock remark add karo
        for product in processed:
            if product.get('id'):
                product['stock_remark'] = db.get_stock_remark(product['id'])

        return {
            "status": "success",
            "detected_count": len(processed),
            "products": processed,
            "bill": bill
        }
    
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


@app.get("/products")
def get_all_products():
    products = db.get_all_products()
    # Har product ka stock remark bhi do
    result = []
    for p in products:
        product_dict = {
            "id": p[0],
            "name": p[1],
            "brand": p[2],
            "category": p[3],
            "price_per_unit": p[4],
            "weight_based": bool(p[5]),
            "price_per_kg": p[6],
            "barcode": p[7],
            "unit": p[8],
            "quantity": p[9],
            "min_stock_alert": p[10],
            "price_display": f"Rs.{p[6]}/kg" if p[5] else f"Rs.{p[4]}/piece",
            "stock_remark": db.get_stock_remark(p[0])
        }
        result.append(product_dict)
    return {"products": result}


@app.get("/transactions")
def get_transactions():
    transactions = db.get_transactions()
    result = []
    for t in transactions:
        result.append({
            "id": t[0],
            "bill_id": t[1],
            "cashier": t[2],
            "total": t[3],
            "items_count": t[4],
            "timestamp": t[5],
            "items_json": t[6]
        })
    return {"transactions": result}


@app.get("/stats")
def get_stats():
    today_revenue = db.get_today_revenue()
    today_transactions = db.get_today_transactions()
    monthly_revenue = db.get_monthly_revenue()
    low_stock = db.get_low_stock_products()
    return {
        "today_revenue": today_revenue,
        "today_transactions": today_transactions,
        "monthly_revenue": monthly_revenue,
        "low_stock_count": len(low_stock)
    }


@app.get("/low-stock")
def get_low_stock():
    products = db.get_low_stock_products()
    result = []
    for p in products:
        result.append({
            "id": p[0],
            "name": p[1],
            "brand": p[2],
            "category": p[3],
            "price_per_unit": p[4],
            "weight_based": bool(p[5]),
            "price_per_kg": p[6],
            "quantity": p[9],
            "min_stock_alert": p[10],
            "stock_remark": db.get_stock_remark(p[0])
        })
    return {"low_stock": result}


@app.get("/product/barcode/{barcode}")
def get_product_by_barcode(barcode: str):
    product = db.get_product_by_barcode(barcode)
    if product:
        return {
            "product": {
                "id": product[0],
                "name": product[1],
                "brand": product[2],
                "category": product[3],
                "price_per_unit": product[4],
                "weight_based": bool(product[5]),
                "price_per_kg": product[6],
                "barcode": product[7],
                "unit": product[8],
                "quantity": product[9],
                "price_display": f"Rs.{product[6]}/kg" if product[5] else f"Rs.{product[4]}/piece",
                "stock_remark": db.get_stock_remark(product[0])
            }
        }
    return {"product": None}

@app.post("/product/add")
def add_product_api(data: dict):
    db.add_product(
        name=data.get('name', ''),
        brand=data.get('brand', ''),
        category=data.get('category', 'General'),
        price=data.get('price', 0),
        weight_based=data.get('weight_based', False),
        quantity=data.get('quantity', 100),
    )
    return {"status": "success"}

@app.delete("/product/delete/{product_id}")
def delete_product_api(product_id: int):
    db.delete_product(product_id)
    return {"status": "success"}

@app.put("/product/stock/{product_id}")
def update_stock_api(product_id: int, data: dict):
    db.update_stock(product_id, data['quantity'])
    return {"status": "success"}

@app.post("/save-transaction")
def save_transaction_api(data: dict):
    db.save_transaction(
        bill_id=data['bill_id'],
        cashier=data['cashier'],
        total=data['total'],
        items_count=data['items_count'],
        items_json=data['items_json'],
    )
    return {"status": "success"}

@app.get("/product/search")
def search_product(name: str):
    product = db.get_product_by_name(name)
    if product:
        return {
            "product": {
                "id": product[0],
                "name": product[1],
                "brand": product[2],
                "category": product[3],
                "price_per_unit": product[4],
                "weight_based": bool(product[5]),
                "price_per_kg": product[6],
                "unit": product[8],
                "quantity": product[9],
                "stock_remark": db.get_stock_remark(product[0])
            }
        }
    return {"product": None}