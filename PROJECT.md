# VisionPay — Cross-Platform Grocery Billing Application Using Artificial Intelligence

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Problem Statement](#problem-statement)
3. [Solution Architecture](#solution-architecture)
4. [Tech Stack](#tech-stack)
5. [Project Structure](#project-structure)
6. [AI Model Details](#ai-model-details)
7. [Database Schema](#database-schema)
8. [FastAPI Backend](#fastapi-backend)
9. [Flutter App](#flutter-app)
10. [Android Build Configuration](#android-build-configuration)
11. [Hardware Integration Plan](#hardware-integration-plan)
12. [Pending Issues & Known Bugs](#pending-issues--known-bugs)
13. [Demo Preparation Notes](#demo-preparation-notes)

---

## Project Overview

| Field | Details |
|---|---|
| **Project Name** | VisionPay |
| **Type** | Final Year Project (FYP) |
| **Institute** | KICSIT (Khan Institute of Computer Science and Information Technology) |
| **Year** | 2026 |
| **Supervisor** | Dr. Sehrish Khan Tayyaba |
| **Co-Supervisor** | Dr. Altaf Hussain |

### Team Members

| Name | Registration | Role |
|---|---|---|
| Naveed Hayat | 222201006 | AI & Backend Developer |
| Nimrah Khan | 222201008 | Frontend & UI Developer |
| Mehak Razzaq | 222201025 | AI & System Integration |

---

## Problem Statement

Traditional grocery stores rely on manual barcode scanning, which introduces several pain points:

- **Slow checkout** — manual scanning creates long queues, especially during rush hours
- **Error-prone** — human mistakes in scanning and pricing
- **Fresh produce gap** — fruits and vegetables have no barcodes and require manual weight measurement
- **Inefficient stock tracking** — updates are delayed and often inaccurate

VisionPay addresses all of these by combining AI-powered computer vision with a digital weighing system to automate the entire billing workflow.

---

## Solution Architecture

```
Camera captures products
        ↓
YOLOv8 AI model detects products
        ↓
Packed items → added directly to cart
Fresh produce → weight measured via load cell
        ↓
Price calculated automatically
        ↓
Bill generated instantly
        ↓
Transaction saved to database + stock updated in real time
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **AI Model** | YOLOv8n (Ultralytics) |
| **Backend** | FastAPI (Python) + SQLite |
| **Frontend** | Flutter (Dart) — Android |
| **OCR** | EasyOCR |
| **Hardware** | Phone Camera + Load Cell 5kg + HX711 Module + Arduino Uno *(pending integration)* |
| **Training Platform** | Kaggle (Tesla T4 GPU) |
| **Dataset** | Roboflow (custom Pakistani products + fruits/vegetables) |

---

## Project Structure

```
C:\Users\Mehak Razzaq\Desktop\VisionPay\
├── backend/
│   ├── main.py              ← FastAPI server (all endpoints)
│   ├── database.py          ← SQLite + ProductDatabase class
│   ├── decision_engine.py   ← Routes products to billing/weight
│   ├── billing_engine.py    ← Bill calculation logic
│   └── ocr_module.py        ← EasyOCR for text extraction
├── ai_engine/               ← AI related modules
├── visionpay_app/           ← Flutter mobile app
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── config.dart      ← API base URL config
│       ├── theme/
│       │   └── colors.dart  ← AppColors class
│       └── screens/
│           ├── landing_screen.dart
│           ├── login_screen.dart
│           ├── manager/
│           │   └── manager_dashboard.dart
│           └── cashier/
│               └── cashier_dashboard.dart
├── visionpay_combined_best.pt  ← Trained YOLOv8 model
└── visionpay.db               ← SQLite database
```

---

## AI Model Details

### Model Summary

| Property | Value |
|---|---|
| **Base Model** | YOLOv8n (fine-tuned) |
| **Total Classes** | 53 |
| **Training Epochs** | 100 |
| **Training Hardware** | Tesla T4 GPU (Kaggle) |
| **Training Duration** | ~1.5 hours |
| **Overall mAP50** | 39.9% |
| **Detection Speed** | <1 second |
| **Detection Config** | conf=0.15, iou=0.45 |

### Top Performing Classes

| Class | Accuracy |
|---|---|
| CocoMo | 99.5% |
| Lays French Cheese | 99.5% |
| Candi Biscuit | 95.3% |

### Datasets

| Dataset | Roboflow Slug | Train | Validation |
|---|---|---|---|
| Fruits & Vegetables | amna-7f8ad/fruits-vegetables-z1glt | 4065 | 387 |
| Pakistani Products | mehak-razzaq/final-visionpay v2 | 133 | 33 |

### 53 Detected Classes

**Pakistani Packed Products (5)**

| # | Class |
|---|---|
| 1 | Candi Biscuit |
| 2 | Chunkin Chocolate |
| 3 | CocoMo |
| 4 | Lays French Cheese |
| 5 | Prince Biscuit |

**Fruits (17)**

| # | Class | # | Class |
|---|---|---|---|
| 1 | APPLE | 10 | Peach |
| 2 | Japanese Plum | 11 | Pear |
| 3 | Apricot | 12 | Plum |
| 4 | Banana | 13 | Strawberry |
| 5 | Cantaloupe | 14 | Watermelon |
| 6 | Dates | 15 | Yellow Watermelon |
| 7 | Grapes | 16 | Pineapple |
| 8 | Guava | 17 | Pomegranate |
| 9 | Lemon | | |

**Vegetables (28)**

| # | Class | # | Class |
|---|---|---|---|
| 1 | Apple Gourd | 15 | Lettuce |
| 2 | Beans | 16 | Luffa Gourd |
| 3 | Beetroot | 17 | Mint |
| 4 | Bitter Gourd | 18 | Onion |
| 5 | Cabbage | 19 | Peas |
| 6 | Capsicum | 20 | Potato |
| 7 | Carrot | 21 | Pumpkin |
| 8 | Cauliflower | 22 | Purple Cabbage |
| 9 | Chilli | 23 | Radish |
| 10 | Cucumber | 24 | Spinach |
| 11 | Eggplant | 25 | Taro Root |
| 12 | Garlic | 26 | Tomato |
| 13 | Ginger | 27 | Turnip |
| 14 | Lady Finger | 28 | Zucchini |

---

## Database Schema

**File:** `visionpay.db` (SQLite)

### Products Table

| Column | Type | Description |
|---|---|---|
| id | INTEGER | Primary key |
| name | TEXT | Product name |
| brand | TEXT | Brand name |
| category | TEXT | Category (packed/fruit/vegetable) |
| price_per_unit | REAL | Price per unit (packed items) |
| weight_based | BOOLEAN | True if sold by weight |
| price_per_kg | REAL | Price per kilogram (fresh produce) |
| barcode | TEXT | Barcode string (optional) |
| unit | TEXT | Unit type |
| quantity | INTEGER | Current stock quantity |
| min_stock_alert | INTEGER | Threshold for low stock alert |

### Transactions Table

| Column | Type | Description |
|---|---|---|
| id | INTEGER | Primary key |
| bill_id | TEXT | Unique bill identifier |
| cashier | TEXT | Cashier name |
| total | REAL | Total bill amount |
| items_count | INTEGER | Number of items |
| timestamp | TEXT | ISO timestamp |
| items_json | TEXT | JSON array of all items |

### Stock Status Remarks

| Symbol | Status | Condition |
|---|---|---|
| ⛔ | Out of Stock | quantity = 0 |
| 🔴 | Critical — Restock Immediately | quantity ≤ 3 |
| 🟡 | Low Stock — Restock Needed | quantity ≤ 8 |
| 🟠 | About to Run Low | quantity ≤ 15 |
| 🟢 | In Stock | quantity > 15 |
| ✅ | Available | weight-based items |

### Notable Stock States

| Product | Quantity | Remark | Reason |
|---|---|---|---|
| Chunkin Chocolate | 0 | ⛔ Out of Stock | 0% detection accuracy |
| Prince Biscuit | 0 | ⛔ Out of Stock | 0% detection accuracy |
| Lays French Cheese | 8 | 🟡 Low Stock | — |
| Grapes | 5 | 🟡 Low Stock | — |
| Strawberry | 3 | 🔴 Critical | — |
| Lettuce | 2 | 🔴 Critical | — |
| Beans | 4 | 🟡 Low Stock | — |

---

## FastAPI Backend

### Running the Server

```bash
# Run from: C:\Users\Mehak Razzaq\Desktop\VisionPay\
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

- **Swagger UI:** `http://127.0.0.1:8000/docs`
- Use `--host 0.0.0.0` so the Flutter app on the phone can reach the server over WiFi.

### All Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Health check |
| POST | `/detect` | YOLO detection — returns products + stock_remark |
| POST | `/checkout` | Detect + bill + save transaction + deduct stock |
| POST | `/generate-bill` | Generate bill from cart items |
| POST | `/save-transaction` | Save transaction to database |
| GET | `/products` | All products with price_display and stock_remark |
| GET | `/transactions` | All transactions |
| GET | `/stats` | today_revenue, today_transactions, monthly_revenue, low_stock_count |
| GET | `/low-stock` | Low stock products with remarks |
| GET | `/product/barcode/{barcode}` | Lookup product by barcode |
| GET | `/product/search?name={}` | Search product by name |
| POST | `/product/add` | Add new product |
| DELETE | `/product/delete/{id}` | Delete product by id |
| PUT | `/product/stock/{id}` | Update stock quantity |

---

## Flutter App

### Running the App

```bash
# Run from: C:\Users\Mehak Razzaq\Desktop\VisionPay\visionpay_app\
flutter run -d hmxcdanvr8n7rkay
```

### API Base URL

Configured in `lib/config.dart`. **Must be updated whenever the WiFi network changes.**

```dart
// lib/config.dart
const String baseUrl = 'http://192.168.0.113:8000';
```

> Run `ipconfig` on the laptop to find the current local IP, then update this value in both dashboards.

### Dependencies (`pubspec.yaml`)

| Package | Version |
|---|---|
| http | ^1.1.0 |
| camera | ^0.10.6 |
| permission_handler | ^11.3.1 |

### Color Scheme (`lib/theme/colors.dart` — `AppColors`)

| Name | Hex | Usage |
|---|---|---|
| primary | `#0F766E` | Main teal color |
| accent | `#14B8A6` | Lighter teal accents |
| gold | `#F9A602` | Highlights, borders |
| background | `#F0FDFA` | Screen backgrounds |
| textPrimary | `#134E4A` | Main text |
| textSecondary | `#6B7280` | Subtitles, hints |
| success | `#16A34A` | Success states |
| error | `#DC2626` | Error states |
| white | `#FFFFFF` | Cards, surfaces |
| border | `#F9A602` | Border color (gold) |

### Credentials

| Role | Username | Password |
|---|---|---|
| Manager | `manager` | `manager123` |
| Cashier | `cashier` | `cashier123` |

### Screens

#### 1. Landing Screen (`landing_screen.dart`)
Hero section with animations and a stats bar showing key metrics:
- 53+ product classes
- 99.5% accuracy
- <1s detection
- ~30s checkout

Sections: System Workflow, Why VisionPay, Tech Stack, Demo Preview, Team section, Footer.

#### 2. Login Screen (`login_screen.dart`)
- Teal animated background
- White centered card
- Username field with a dropdown (autofills `manager` or `cashier`)
- Password field

#### 3. Manager Dashboard (`screens/manager/manager_dashboard.dart`)
Bottom navigation with 4 tabs:

| Tab | Contents |
|---|---|
| Home | 4 clickable stat cards (teal/orange gradient), product overview, recent transactions |
| Products | Packed / weight-based / low-stock sections with add, delete, and stock update actions |
| Transactions | Transaction list with detail bottom sheet |
| Staff | Staff management |
| Profile | Expandable "About App" section |

#### 4. Cashier Dashboard (`screens/cashier/cashier_dashboard.dart`)
Split layout: **Camera feed** (top, `flex:3`) + **Cart panel** (bottom, `flex:2`) on mobile.

| Feature | Description |
|---|---|
| Camera feed | Live phone camera via `camera` package |
| Capture & Detect | Sends image to `/detect` endpoint |
| Weight dialog | Appears for fresh produce; supports kg/g unit selector |
| Manual entry | Searches database by product name |
| Barcode lookup | Queries `/product/barcode/{barcode}` endpoint |
| Receipt dialog | Teal header, itemized bill, Print + New Sale buttons |

---

## Android Build Configuration

### `gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```

### `settings.gradle`

```gradle
id "com.android.application" version "8.1.0"   // AGP
id "org.jetbrains.kotlin.android" version "1.9.0"
```

### `app/build.gradle`

```gradle
compileSdk 34
minSdkVersion 21
targetSdkVersion 34
JavaVersion.VERSION_17
jvmTarget '17'
```

### `build.gradle` (project level)

```gradle
classpath 'com.android.tools.build:gradle:8.1.0'
```

### `AndroidManifest.xml` Permissions

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Hardware Integration Plan

> **Status: Pending hardware delivery**

### Wiring Diagram

```
Load Cell (5kg)
    Red   → E+  ─┐
    Black → E-  ─┤  HX711 Module
    White → A+  ─┤      │
    Green → A-  ─┘      │
                    DT → Arduino Pin 2
                   SCK → Arduino Pin 3
                        │
                   USB Cable
                        │
                      Laptop
```

### Integration Flow

```
Arduino reads HX711 weight sensor
        ↓
Sends reading via Serial (9600 baud)
        ↓
Python reads: serial.Serial('COM3', 9600)
        ↓
FastAPI exposes: GET /weight
        ↓
Flutter polls /weight endpoint
        ↓
Weight dialog auto-fills with live reading
```

### Arduino Sketch Config

```cpp
// HX711 pins
#define DT_PIN  2
#define SCK_PIN 3
```

### Python Serial Reader

```python
import serial
ser = serial.Serial('COM3', 9600)
weight = float(ser.readline().decode().strip())
```

---

## Pending Issues & Known Bugs

### Pending Issues

| # | Issue | Details |
|---|---|---|
| 1 | `flutter run` jlink.exe error | Java 21 + Gradle 8.9 + jlink.exe incompatibility. Last error: `JdkImageTransform failed for core-for-system-modules.jar` |
| 2 | Load Cell + Arduino integration | Hardware pending delivery. See [Hardware Integration Plan](#hardware-integration-plan) |
| 3 | Responsive design (laptop layout) | Mobile layout done (top/bottom split). Laptop layout (side-by-side) needs `MediaQuery width > 600` breakpoint |
| 4 | KICSIT name consistency | Some places still display `IQAST` — must be replaced with `KICSIT` throughout the app |

### Known Bugs

| Bug | Severity | Notes |
|---|---|---|
| `source value 8` obsolete warnings in Gradle | Cosmetic | No functional impact |
| Class name mismatch in DB vs dataset | Minor | e.g., `'lady-s finger'` (dataset) vs `'Lady Finger'` (DB) |
| Chunkin Chocolate — 0% detection | Intentional | Kept in DB as Out of Stock (quantity=0) |
| Prince Biscuit — 0% detection | Intentional | Kept in DB as Out of Stock (quantity=0) |

---

## Demo Preparation Notes

### Pre-Demo Checklist

1. Start the backend server with `--host 0.0.0.0` so the phone can reach it over WiFi
2. Ensure phone and laptop are connected to the **same WiFi network**
3. Run `ipconfig` on the laptop to get the current local IP address
4. Update `lib/config.dart` (`baseUrl`) with the new IP if it has changed
5. Rebuild/restart the Flutter app after any config change

### Best Products for Demo

| Product | Type | Why |
|---|---|---|
| CocoMo | Packed | 99.5% accuracy |
| Lays French Cheese | Packed | 99.5% accuracy |
| Candi Biscuit | Packed | 95.3% accuracy |
| Tomato | Vegetable | Reliable detection |
| Banana | Fruit | Reliable detection |
| Onion | Vegetable | Reliable detection |

### Products to Avoid

| Product | Reason |
|---|---|
| Chunkin Chocolate | 0% detection accuracy |
| Prince Biscuit | 0% detection accuracy |

### Timing

A full checkout demo (detect → cart → bill → save) takes approximately **30 seconds**.

---

*Last updated: June 2026 — VisionPay FYP, KICSIT*
