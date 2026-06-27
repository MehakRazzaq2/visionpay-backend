# VisionPay FYP Documentation Guide

## Project Information
- **Title:** Cross-Platform Grocery Billing Application using Artificial Intelligence
- **Team:** Naveed Hayat (222201006), Nimrah Khan (222201008), Mehak Razzaq (222201025)
- **Supervisor:** Dr. Sehrish Khan Tayyaba
- **Co-Supervisor:** Dr. Altaf Hussain
- **Institute:** KICSIT 2026

---

## Formatting Rules (STRICT)
| Element | Spec |
|---------|------|
| Font | Times New Roman throughout |
| Main Heading | 16pt Bold |
| Sub Heading (H2) | 14pt Bold |
| Sub-sub Heading (H3) | 12pt Bold |
| Paragraph | 12pt, Justified, 1.5 line spacing |
| Left Margin | 1.5 inch |
| Right/Top/Bottom | 1 inch |
| New Chapter | Always starts on new page |

## Page Numbering
- Title page: NO number
- Approval → List of Tables: Roman numerals (i, ii, iii...)
- Chapter 1 onwards: Arabic (1, 2, 3...)
- Chapter title pages: counted but number NOT shown
- Position: center bottom

---

## Front Matter Order
1. Title Page (no number)
2. Approval by Board of Examiners (i)
3. Declaration (ii)
4. Dedication (iii)
5. Acknowledgements (iv)
6. Abstract (v)
7. Table of Contents (vi)
8. List of Figures (vii)
9. List of Tables (viii) ← ADD THIS
10. List of Abbreviations (ix) ← ONLY abbreviations actually used

## Abbreviations Used in Document
| Abbreviation | Full Form |
|-------------|-----------|
| AI | Artificial Intelligence |
| ML | Machine Learning |
| CV | Computer Vision |
| OCR | Optical Character Recognition |
| YOLO | You Only Look Once |
| API | Application Programming Interface |
| REST | Representational State Transfer |
| JSON | JavaScript Object Notation |
| UI | User Interface |
| DB | Database |
| GPU | Graphics Processing Unit |
| mAP | Mean Average Precision |
| IoU | Intersection over Union |
| SDK | Software Development Kit |
| APK | Android Package |
| USB | Universal Serial Bus |
| HF | Hugging Face |
| IDE | Integrated Development Environment |

---

## Technical Reference

### AI Model
- Architecture: YOLOv8n (nano — lightweight, mobile-optimized)
- Training: 100 epochs, Kaggle Tesla T4 GPU
- Dataset: Roboflow (custom + public fruits/vegetables)
- Total classes: 53
  - Pakistani Packed Products (5): Candi Biscuit, Chunkin Chocolate, CocoMo, Lays French Cheese, Prince Biscuit
  - Fruits (17): Apple, Japanese Plum, Apricot, Banana, Cantaloupe, Dates, Grapes, Guava, Lemon, Peach, Pear, Plum, Strawberry, Watermelon, Yellow Watermelon, Pineapple, Pomegranate
  - Vegetables (28): Apple Gourd, Beans, Beetroot, Bitter Gourd, Cabbage, Capsicum, Carrot, Cauliflower, Chilli, Cucumber, Eggplant, Garlic, Ginger, Lady Finger, Lettuce, Luffa Gourd, Mint, Onion, Peas, Potato, Pumpkin, Purple Cabbage, Radish, Spinach, Taro Root, Tomato, Turnip, Zucchini
- Overall mAP50: 39.9%
- Best classes: CocoMo 99.5%, Lays French Cheese 99.5%, Candi Biscuit 95.3%
- Detection speed: < 1 second per frame
- Confidence threshold (production): 0.55
- IOU threshold: 0.45

### Backend (FastAPI)
- Language: Python 3.10
- Database: SQLite
- Deployment: Hugging Face Spaces (Docker)
- URL: https://mehakrazzaq2-visionpay-api.hf.space
- Model storage: HF Hub — mehakrazzaq2/visionpay-model

#### API Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /detect | YOLO detection only |
| POST | /checkout | Detect + bill + save + deduct stock |
| POST | /generate-bill | Generate bill from cart items |
| POST | /save-transaction | Save transaction to DB |
| GET | /products | All products |
| GET | /transactions | All transactions |
| GET | /stats | Revenue and transaction stats |
| GET | /low-stock | Products below minimum stock |
| GET | /product/barcode/{barcode} | Barcode lookup |
| GET | /product/search?name={} | Name search |
| POST | /product/add | Add new product |
| DELETE | /product/delete/{id} | Delete product |
| PUT | /product/stock/{id} | Update stock quantity |
| GET | /weight | Live weight from load cell |
| WS | /ws | WebSocket for real-time sync |

#### Database Schema
**Products Table:**
id, name, brand, category, price_per_unit, weight_based, price_per_kg, barcode, unit, quantity, min_stock_alert

**Transactions Table:**
id, bill_id, cashier, total, items_count, timestamp, items_json

**Stock Remarks:**
- Out of Stock (qty = 0)
- Critical — Restock Immediately (qty ≤ 2)
- Low Stock (qty ≤ 5)
- About to Run Low (qty ≤ 10)
- In Stock (qty > 10)
- Available (weight-based items)

### Flutter App
- Framework: Flutter (Dart)
- Platform: Android (cross-platform Web also enabled)
- Min SDK: Android 5.0

#### Screens
1. **Landing Screen** — hero section, stats, workflow, tech stack, team info
2. **Login Screen** — role-based login (Manager / Cashier)
3. **Manager Dashboard** — stats cards, product management, transaction history, stock alerts
4. **Cashier Dashboard** — camera preview, detect button, cart, weight dialog, manual entry, barcode scan, receipt generation

#### Color Scheme
- Primary: #0F766E (teal green)
- Gold: #F9A602
- Background: #F0FDFA

### Hardware
- Load Cell (5kg capacity) → HX711 Amplifier → Arduino Uno → USB → Laptop
- HX711 Wiring: E+ Red, E− Black, A+ Green, A− White
- Arduino Pins: DT → Pin 3, SCK → Pin 2
- Python `pyserial` reads serial port at 9600 baud
- Weight exposed via FastAPI /weight endpoint
- Flutter auto-fills weight in dialog when weight-based product detected

---

## Chapter Status
| Chapter | Title | Status |
|---------|-------|--------|
| 1 | Introduction | Written ✅ |
| 2 | Literature Review | Written ✅ |
| 3 | Methodology | Written ✅ |
| 4 | System Design | Written ✅ |
| 5 | Implementation | **To Write** |
| 6 | Testing and Evaluation | **To Write** |
| 7 | Conclusion and Future Work | **To Write** |

---

## Writing Style Rules
- Past tense for completed work: "The model was trained...", "The system was deployed..."
- Active voice preferred: "The team integrated..." not "Integration was performed by..."
- Each paragraph: minimum 4-5 sentences
- No excessive use of: "Furthermore", "Moreover", "It is worth noting", "In conclusion"
- Technical terms explained on first use
- Academic but readable — write as a CS student, not a robot
- Every claim backed by explanation or result
