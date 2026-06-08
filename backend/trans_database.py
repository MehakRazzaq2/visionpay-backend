from datetime import datetime
import sqlite3


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
            unit TEXT DEFAULT 'piece'
        )
    ''')
    
    # Transactions table add karo
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bill_id TEXT,
            cashier TEXT,
            total REAL,
            items_count INTEGER,
            timestamp TEXT,
            items_json TEXT
        )
    ''')
    
    conn.commit()
    conn.close()
    print("Database initialized! ✅")

def save_transaction(self, bill_id, cashier, total, items_count, items_json):
    conn = sqlite3.connect(self.db_path)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO transactions (bill_id, cashier, total, items_count, timestamp, items_json)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (bill_id, cashier, total, items_count, 
          datetime.now().strftime("%d-%m-%Y %H:%M:%S"), items_json))
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
    cursor.execute("SELECT SUM(total) FROM transactions WHERE timestamp LIKE ?", 
                   (f"{today}%",))
    result = cursor.fetchone()[0]
    conn.close()
    return result or 0

def get_today_transactions(self):
    conn = sqlite3.connect(self.db_path)
    cursor = conn.cursor()
    today = datetime.now().strftime("%d-%m-%Y")
    cursor.execute("SELECT COUNT(*) FROM transactions WHERE timestamp LIKE ?", 
                   (f"{today}%",))
    result = cursor.fetchone()[0]
    conn.close()
    return result or 0