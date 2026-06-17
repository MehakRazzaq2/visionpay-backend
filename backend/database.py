import sqlite3
import os
from datetime import datetime

class ProductDatabase:
    def __init__(self, db_path="visionpay.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                brand TEXT,
                category TEXT,
                price_per_unit REAL,
                weight_based BOOLEAN DEFAULT 0,
                price_per_kg REAL,
                barcode TEXT UNIQUE,
                unit TEXT DEFAULT 'piece',
                quantity INTEGER DEFAULT 100,
                min_stock_alert INTEGER DEFAULT 10
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                bill_id TEXT,
                cashier TEXT,
                total REAL,
                items_count INTEGER,
                timestamp TEXT,
                items_json TEXT,
                payment_method TEXT DEFAULT 'Cash',
                status TEXT DEFAULT 'Paid'
            )
        ''')

        # Migration: add new columns to existing databases
        for col, default in [("payment_method", "'Cash'"), ("status", "'Paid'")]:
            try:
                cursor.execute(f"ALTER TABLE transactions ADD COLUMN {col} TEXT DEFAULT {default}")
            except Exception:
                pass  # column already exists

        conn.commit()
        conn.close()
        print("Database initialized! ✅")

        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        conn.close()
        if count == 0:
            print("Empty database — seeding default products...")
            self.seed_sample_data()
    
    def add_product(self, name, brand, category, price, weight_based=False, 
                    price_per_kg=None, barcode=None, unit='piece', 
                    quantity=100, min_stock_alert=10):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO products (name, brand, category, price_per_unit, 
                weight_based, price_per_kg, barcode, unit, quantity, min_stock_alert)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (name, brand, category, price, weight_based, 
                  price_per_kg, barcode, unit, quantity, min_stock_alert))
            conn.commit()
            print(f"Product added: {name}")
        except sqlite3.IntegrityError:
            print(f"Product already exists: {name}")
        finally:
            conn.close()
    
    def get_product_by_name(self, name):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products WHERE name LIKE ?", (f"%{name}%",))
        result = cursor.fetchone()
        conn.close()
        return result
    
    def get_product_by_barcode(self, barcode):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products WHERE barcode=?", (barcode,))
        result = cursor.fetchone()
        conn.close()
        return result

    def get_all_products(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products")
        results = cursor.fetchall()
        conn.close()
        return results

    def get_product_by_id(self, product_id):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products WHERE id=?", (product_id,))
        result = cursor.fetchone()
        conn.close()
        return result

    def deduct_stock(self, product_id, quantity=1):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            UPDATE products 
            SET quantity = MAX(0, quantity - ?) 
            WHERE id = ?
        ''', (quantity, product_id))
        conn.commit()
        conn.close()

    def get_low_stock_products(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            SELECT * FROM products 
            WHERE quantity <= min_stock_alert 
            AND weight_based = 0
        ''')
        results = cursor.fetchall()
        conn.close()
        return results

    def update_stock(self, product_id, add_quantity):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE products SET quantity = MAX(0, quantity + ?) WHERE id=?",
            (add_quantity, product_id)
        )
        conn.commit()
        conn.close()

    def get_stock_remark(self, product_id):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(
            "SELECT quantity, min_stock_alert, weight_based FROM products WHERE id=?",
            (product_id,)
        )
        result = cursor.fetchone()
        conn.close()
        
        if not result:
            return "Unknown"
        
        quantity, min_stock, is_weight = result
        
        if is_weight:
            return "✅ Available"
        
        if quantity == 0:
            return "⛔ Out of Stock"
        elif quantity <= min_stock * 0.3:
            return "🔴 Critical — Restock Immediately"
        elif quantity <= min_stock:
            return "🟡 Low Stock — Restock Needed"
        elif quantity <= min_stock * 2:
            return "🟠 About to Run Low"
        else:
            return "🟢 In Stock"

    def save_transaction(self, bill_id, cashier, total, items_count, items_json,
                         payment_method='Cash', status='Paid'):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO transactions (bill_id, cashier, total, items_count, timestamp,
                                      items_json, payment_method, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (bill_id, cashier, total, items_count,
              datetime.now().strftime("%d-%m-%Y %H:%M:%S"), items_json,
              payment_method, status))
        conn.commit()
        conn.close()

    def get_transactions(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM transactions ORDER BY id DESC")
        results = cursor.fetchall()
        conn.close()
        return results

    def get_today_revenue(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        today = datetime.now().strftime("%d-%m-%Y")
        cursor.execute(
            "SELECT SUM(total) FROM transactions WHERE timestamp LIKE ?",
            (f"{today}%",)
        )
        result = cursor.fetchone()[0]
        conn.close()
        return result or 0

    def get_today_transactions(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        today = datetime.now().strftime("%d-%m-%Y")
        cursor.execute(
            "SELECT COUNT(*) FROM transactions WHERE timestamp LIKE ?",
            (f"{today}%",)
        )
        result = cursor.fetchone()[0]
        conn.close()
        return result or 0

    def get_monthly_revenue(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        month = datetime.now().strftime("%m-%Y")
        cursor.execute(
            "SELECT SUM(total) FROM transactions WHERE timestamp LIKE ?",
            (f"%-{month}%",)
        )
        result = cursor.fetchone()[0]
        conn.close()
        return result or 0

    def update_product(self, pid, name, brand, category, price, 
                       weight_based, price_per_kg, unit, quantity, min_stock_alert):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            UPDATE products SET name=?, brand=?, category=?, price_per_unit=?,
            weight_based=?, price_per_kg=?, unit=?, quantity=?, min_stock_alert=?
            WHERE id=?
        ''', (name, brand, category, price, weight_based, 
              price_per_kg, unit, quantity, min_stock_alert, pid))
        conn.commit()
        conn.close()

    def delete_product(self, product_id):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM products WHERE id=?", (product_id,))
        conn.commit()
        conn.close()

    def clear_and_reseed(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM products")
        conn.commit()
        conn.close()
        print("Database cleared!")
        self.seed_sample_data()
    
    def seed_sample_data(self):

        # ── Pakistani Packaged Products ───────────────────────────────
        # Format: name, brand, category, price_per_unit, weight_based, price_per_kg, barcode, unit, quantity, min_stock_alert
        # Prince & Chunkin weak detection → out of stock
        pakistani_products = [
            ("Candi Biscuit",      "LU",   "Snacks", 45,  False, None, "3000000001", "piece", 50, 10),
            ("Chunkin Chocolate",  "Gibs", "Snacks", 10,  False, None, "3000000002", "piece", 0,  10),  # Out of Stock — weak detection
            ("CocoMo",             "LU",   "Snacks", 20,  False, None, "3000000003", "piece", 60, 10),
            ("Lays French Cheese", "Lays", "Snacks", 20,  False, None, "3000000004", "piece", 8,  10),  # Low Stock
            ("Prince Biscuit",     "LU",   "Snacks", 30,  False, None, "3000000005", "piece", 0,  10),  # Out of Stock — weak detection
        ]

        # ── Fruits — Weight Based ─────────────────────────────────────
        # Format: name, brand, category, price_per_unit, weight_based, price_per_kg, barcode, unit, quantity, min_stock_alert
        fruits = [
            ("APPLE",             "Local", "Fruits", 0, True, 250, None, "kg", 999, 0),
            ("Japanese Plum",     "Local", "Fruits", 0, True, 300, None, "kg", 999, 0),
            ("Apricot",           "Local", "Fruits", 0, True, 280, None, "kg", 999, 0),
            ("Banana",            "Local", "Fruits", 0, True, 120, None, "kg", 999, 0),
            ("Cantaloupe",        "Local", "Fruits", 0, True, 80,  None, "kg", 999, 0),
            ("Dates",             "Local", "Fruits", 0, True, 400, None, "kg", 999, 0),
            ("Grapes",            "Local", "Fruits", 0, True, 350, None, "kg", 5,   5),  # Low Stock
            ("Guava",             "Local", "Fruits", 0, True, 150, None, "kg", 999, 0),
            ("Lemon",             "Local", "Fruits", 0, True, 200, None, "kg", 999, 0),
            ("Peach",             "Local", "Fruits", 0, True, 280, None, "kg", 999, 0),
            ("Pear",              "Local", "Fruits", 0, True, 250, None, "kg", 999, 0),
            ("Plum",              "Local", "Fruits", 0, True, 300, None, "kg", 999, 0),
            ("Strawberry",        "Local", "Fruits", 0, True, 400, None, "kg", 3,   5),  # Critical Low
            ("Watermelon",        "Local", "Fruits", 0, True, 60,  None, "kg", 999, 0),
            ("Yellow Watermelon", "Local", "Fruits", 0, True, 80,  None, "kg", 999, 0),
            ("Pineapple",         "Local", "Fruits", 0, True, 180, None, "kg", 999, 0),
            ("Pomegranate",       "Local", "Fruits", 0, True, 350, None, "kg", 999, 0),
        ]

        # ── Vegetables — Weight Based ─────────────────────────────────
        vegetables = [
            ("Apple Gourd",    "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Beans",          "Local", "Vegetables", 0, True, 120, None, "kg", 4,   5),  # Low Stock
            ("Beetroot",       "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Bitter Gourd",   "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Cabbage",        "Local", "Vegetables", 0, True, 60,  None, "kg", 999, 0),
            ("Capsicum",       "Local", "Vegetables", 0, True, 150, None, "kg", 999, 0),
            ("Carrot",         "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Cauliflower",    "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Chilli",         "Local", "Vegetables", 0, True, 120, None, "kg", 999, 0),
            ("Cucumber",       "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Eggplant",       "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Garlic",         "Local", "Vegetables", 0, True, 300, None, "kg", 999, 0),
            ("Ginger",         "Local", "Vegetables", 0, True, 250, None, "kg", 999, 0),
            ("Lady Finger",    "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Lettuce",        "Local", "Vegetables", 0, True, 120, None, "kg", 2,   5),  # Critical Low
            ("Luffa Gourd",    "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Mint",           "Local", "Vegetables", 0, True, 200, None, "kg", 999, 0),
            ("Onion",          "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Peas",           "Local", "Vegetables", 0, True, 150, None, "kg", 999, 0),
            ("Potato",         "Local", "Vegetables", 0, True, 60,  None, "kg", 999, 0),
            ("Pumpkin",        "Local", "Vegetables", 0, True, 80,  None, "kg", 999, 0),
            ("Purple Cabbage", "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Radish",         "Local", "Vegetables", 0, True, 60,  None, "kg", 999, 0),
            ("Spinach",        "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Taro Root",      "Local", "Vegetables", 0, True, 120, None, "kg", 999, 0),
            ("Tomato",         "Local", "Vegetables", 0, True, 100, None, "kg", 999, 0),
            ("Turnip",         "Local", "Vegetables", 0, True, 60,  None, "kg", 999, 0),
            ("Zucchini",       "Local", "Vegetables", 0, True, 120, None, "kg", 999, 0),
        ]

        for p in pakistani_products + fruits + vegetables:
            self.add_product(*p)

        print(f"\nAll products added! ✅")
        print(f"Pakistani Products: {len(pakistani_products)}")
        print(f"Fruits: {len(fruits)}")
        print(f"Vegetables: {len(vegetables)}")
        print(f"Total: {len(pakistani_products) + len(fruits) + len(vegetables)}")


if __name__ == "__main__":
    db = ProductDatabase("visionpay.db")
    db.clear_and_reseed()
    
    print("\n=== All Products ===")
    products = db.get_all_products()
    for p in products:
        weight_type = "Weight-based" if p[5] else "Fixed price"
        qty = p[9] if len(p) > 9 else "N/A"
        price = f"Rs.{p[6]}/kg" if p[5] else f"Rs.{p[4]}/piece"
        remark = db.get_stock_remark(p[0])
        print(f"  {p[1]:<25} | {price:<15} | Stock: {qty:<5} | {remark}")