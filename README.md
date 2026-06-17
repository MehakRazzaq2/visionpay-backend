# VisionPay — AI-Powered Grocery Billing System

> Final Year Project — KICSIT, Batch 2022–2026

VisionPay is a cross-platform grocery billing application that eliminates the need for traditional barcodes by using computer vision to detect products and generate bills automatically. A cashier simply points the phone camera at grocery items, the AI identifies them instantly, and a complete bill is generated — including weight-based products using a hardware load cell scale.

---

## Features

### Cashier App (Flutter — Android)
- **AI Product Detection** — YOLOv8 model detects 53+ grocery product classes via mobile camera
- **Real Barcode Scanning** — Camera-based barcode scanner (no manual typing)
- **Manual Entry** — Search and add products by name
- **Weight Scale Integration** — Arduino + HX711 load cell reads weight automatically; fills the weight field in real time
- **Smart Cart** — Supports both fixed-price and weight-based products
- **Payment Methods** — Cash, Card, JazzCash, EasyPaisa
- **Receipt Generation** — Bill ID, cashier name, items, payment method, status
- **Real-time Sync** — WebSocket keeps laptop dashboard updated live

### Manager Dashboard (Flutter — Android/Web)
- Revenue stats: today, monthly
- Full transaction history with cashier, payment method, status
- Product management: add, delete, restock
- Low stock alerts
- Staff overview

### Backend (FastAPI — Hugging Face Spaces)
- `/detect` — YOLO product detection from image
- `/products` — Full product catalogue
- `/transactions` — Transaction history
- `/save-transaction` — Save bill with cashier + payment info
- `/weight` — Live weight from Arduino scale
- `/weight/tare` — Tare (zero) the scale
- SQLite database with automatic migration

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| AI Model | YOLOv8n — 53 Classes |
| Backend API | FastAPI (Python) |
| Database | SQLite |
| Hosting | Hugging Face Spaces (Docker) |
| Weight Scale | Arduino + HX711 + Load Cell |
| Local Service | FastAPI on port 8001 |
| Real-time | WebSocket |
| Barcode | mobile_scanner (Flutter) |

---

## Project Structure

```
VisionPay/
├── backend/
│   ├── main.py              # FastAPI app — all API endpoints
│   ├── database.py          # SQLite database + migrations
│   ├── billing_engine.py    # Bill calculation logic
│   └── decision_engine.py   # YOLO result processing
├── ai_engine/
│   └── ocr_module.py        # Optional OCR support
├── visionpay_app/           # Flutter mobile app
│   └── lib/
│       ├── screens/
│       │   ├── landing_screen.dart
│       │   ├── login_screen.dart
│       │   ├── cashier/cashier_dashboard.dart
│       │   └── manager/manager_dashboard.dart
│       ├── config/app_config.dart   # API base URLs
│       └── theme/colors.dart
├── weight_service.py         # Standalone weight scale service (port 8001)
├── requirements.txt
└── visionpay_combined_best.pt  # Trained YOLOv8 model
```

---

## Getting Started

### Prerequisites
- Python 3.10+
- Flutter 3.19+
- Android phone (for mobile app)
- Arduino with HX711 + Load Cell (optional — for weight scale)

### 1. Backend Setup (Local)

```bash
pip install -r requirements.txt
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

Or deploy to Hugging Face Spaces via Docker (see `Dockerfile`).

### 2. Weight Scale Service (Local — optional)

Connect Arduino via USB, then:

```bash
python weight_service.py
```

Runs on `http://0.0.0.0:8001`. Auto-detects Arduino COM port.

### 3. Flutter App

Update `visionpay_app/lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBase = 'https://your-hf-space.hf.space'; // or local IP
  static const String weightBase = 'http://192.168.x.x:8001';     // laptop IP
}
```

Then build:

```bash
cd visionpay_app
flutter pub get
flutter build apk --release
```

---

## Login Credentials

| Role | Username | Password |
|---|---|---|
| Manager | `manager` | `manager123` |
| Cashier 1 | `cashier1` | `cashier123` |
| Cashier 2 | `cashier2` | `cashier456` |

---

## Hardware Setup (Weight Scale)

```
Load Cell → HX711 Module → Arduino (USB) → Laptop
```

Arduino sketch sends serial output in format:
```
WEIGHT:250.5
```

The weight service reads this and exposes it via `/weight` endpoint. Flutter app polls every second in Live mode and auto-fills the weight field.

**Tare:** Send `T\n` to Arduino serial port via `/weight/tare` POST endpoint.

---

## AI Model

- **Architecture:** YOLOv8n (nano)
- **Classes:** 53 grocery product categories
- **Includes:** Pakistani packaged snacks, fresh fruits, vegetables
- **Confidence threshold:** 0.55
- **Training dataset:** Custom labelled grocery dataset

### Detected Products (sample)
Candi Biscuit, CocoMo, Lays French Cheese, Tomato, Onion, Garlic, Apple, Banana, Cucumber, Capsicum, Eggplant, Spinach, and 40+ more.

---

## Key Stats

| Metric | Value |
|---|---|
| Product Classes | 53+ |
| Best Accuracy | 99.5% |
| Detection Time | 1–30 seconds |
| Full Checkout | ~60 seconds |

---

## Database Schema

**products**
```
id, name, brand, category, price_per_unit, weight_based,
price_per_kg, barcode, unit, quantity, min_stock_alert
```

**transactions**
```
id, bill_id, cashier, total, items_count, timestamp,
items_json, payment_method, status
```

---

## Team

| Name | Role |
|---|---|
| Naveed | Team Member |
| Nimrah | Team Member |
| Mehak | Team Member |

**Institute:** Khan Institute of Computer Science & Information Technology (KICSIT)
**Batch:** 2022–2026

---

## License

This project was developed as a Final Year Project for academic purposes.
