"""
Humanize body text in Ch5, Ch6, Ch7 of FYP Report - Copy.docx
- Active voice, vary sentence lengths, use 'we/our', natural hedges
- Does NOT touch headings, captions, tables, Ch1-4
"""
import re
from docx import Document
from docx.oxml.ns import qn

DOC_PATH = r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx"
doc = Document(DOC_PATH)
paras = doc.paragraphs

# ── Find Ch5 start ─────────────────────────────────────────────────────────
ch5_start = None
for i, p in enumerate(paras):
    if p.text.strip() == "Chapter 5":
        ch5_start = i
        break

# ── Specific paragraph rewrites (most AI-sounding ones) ────────────────────
# Key: first ~60 chars of the paragraph, Value: full replacement text
REWRITES = {

# ───────── CHAPTER 5 ─────────────────────────────────────────────────────────
"This chapter describes the complete implementation of Vision":
"Chapter 5 walks through how we built VisionPay from scratch. The project combined four main areas: training the AI model, building the FastAPI backend, developing the Flutter app, and wiring up the Arduino scale. Each part was tested on its own first, then connected into one working system.",

"The development process was iterative. Each component was first":
"We followed an iterative approach throughout. When one module was ready and tested, we moved on to the next, eventually linking everything together in the final integration phase.",

"The development environment was set up on a Windows 11 machine with":
"All development was done on a Windows 11 laptop. Python 3.10 was used for the backend, Flutter 3.x for the app, and Arduino IDE 2.3.9 for the microcontroller firmware. VS Code served as the main code editor.",

"The dataset used for training the YOLOv8n model was prepared by combining":
"We put together the training dataset from two sources. The first was a public fruits and vegetables dataset from Roboflow covering 45 classes. The second was a set of images we collected and labelled ourselves for five Pakistani packaged products — Candi Biscuit, Chunkin Chocolate, CocoMo, Lays French Cheese, and Prince Biscuit.",

"The combined dataset contained images across 53 classes. Data augmentation":
"In total, the combined dataset had images across 53 classes. We ran data augmentation through Roboflow — horizontal flipping, brightness changes, and small rotations — to get more variety out of the existing images.",

"The object detection model selected for VisionPay was You Only Look Once":
"We chose YOLOv8n as the detection model. The nano variant was a deliberate choice — it is small enough to run on a free cloud server while still being accurate enough for our use case.",

"Training was carried out on Kaggle using a Tesla T4 Graphics Processing":
"Training ran on Kaggle with a Tesla T4 GPU over 100 epochs. We used transfer learning, starting from the pretrained YOLOv8n COCO weights and fine-tuning on our 53-class grocery dataset.",

"The overall mean Average Precision at 50% Intersection over Union (mAP50) achieved":
"The model ended up with an overall mAP50 of 39.9%. That number looks modest, but it is pulled down by the fruit and vegetable classes which are naturally hard to tell apart. The five packed products — CocoMo and Lays in particular — hit near-perfect scores of 99.5%.",

"The lower mAP50 values for some fruits and vegetables are attributed":
"The weaker scores on things like Mint (around 19%) and Garlic (around 24%) come down to how small and visually similar they are in the images. Under controlled counter conditions these classes still perform adequately for a billing prototype.",

"The backend was developed using FastAPI, a modern Python web framework known":
"We built the backend in FastAPI. It handles everything — receiving images from the app, running YOLO detection, querying the database, calculating bills, and pushing real-time updates over WebSocket.",

"The backend application is structured into three main modules: the main":
"The backend code is split across a few modules: the main app file, the database module, the decision engine that maps detected classes to database products, and the billing engine that calculates final prices.",

"The /detect endpoint is the most critical endpoint in the system. When the mobile":
"The /detect endpoint does the heavy lifting. The app sends a captured image, the backend runs YOLO on it, filters out low-confidence and tiny detections, looks up each class in the database, and returns the product list. Anything not found in the database is quietly dropped so unknown items never end up in the cart.",

"The /checkout endpoint combines detection, bill generation, transaction saving":
"The /checkout endpoint wraps the whole billing cycle in one call — detect, price, save the transaction, and deduct stock — which is useful for simpler integration flows.",

"SQLite was chosen as the database for its simplicity and zero-configuration":
"We went with SQLite because there is nothing to configure and it works out of the box on any machine. It is lightweight enough for a prototype and handled all our product and transaction storage without any issues.",

"An auto-seeding mechanism was implemented in the database module. On first":
"We added auto-seeding so the database fills itself with all 50 products the very first time the server starts. This made cloud deployment much smoother since we did not need a separate setup step.",

"The mobile application was developed using Flutter, Google's open-source":
"The app was built in Flutter so the same codebase runs on both Android and the browser. This saved a lot of time compared to building two separate apps.",

"The landing screen serves as the entry point of the application and presents":
"The landing screen is the first thing you see when you open VisionPay. It gives a quick overview of the system — what it does, how it works, and some basic stats about the team.",

"The login screen implements role-based authentication. Users can log in as":
"Login is role-based. Cashiers get the billing interface and managers get the full dashboard with analytics and product management. The credentials are kept simple for the prototype.",

"The Cashier Dashboard is the primary working screen for billing staff. It":
"The Cashier Dashboard is where most of the action happens. It shows the live camera feed, a Detect button, and a running cart on the side. When products are detected they appear in the cart automatically.",

"Detected products are displayed in a cart list on the right side of the":
"Weight-based items like fruits and vegetables trigger a dialog where the cashier enters the weight. If the Arduino scale is connected, pressing the button reads the weight directly from the hardware.",

"The Manager Dashboard provides store management functionality through multiple":
"The Manager Dashboard is split into tabs — an overview tab with daily and monthly revenue, a products tab for managing the catalogue, a transactions tab for billing history, and a stock alerts tab that flags anything running low.",

"A WebSocket connection was implemented in the cashier dashboard to enable":
"We added WebSocket support so that when the mobile phone detects a product, the result shows up on the laptop browser in real time. This was one of the more interesting features to test — scanning on the phone and watching the cart update on the laptop felt quite satisfying.",

"The hardware component of VisionPay handles weight measurement for produce":
"The hardware side handles weight measurement for items like fruits and vegetables that are sold by the kilo. The load cell measures the weight, the HX711 amplifies the signal, and the Arduino reads it and sends the value to the laptop over USB.",

"The calibration process involved placing a known weight on the load cell":
"Calibration was straightforward — we placed a 500g weight on the scale and adjusted the calibration factor in the firmware until the reading matched. After that the scale was consistently accurate to within a gram or two.",

"The backend was deployed on Hugging Face Spaces using Docker containerization":
"We deployed the backend on Hugging Face Spaces using Docker. The main reason was cost — Spaces has a free tier and the deployment is permanent, meaning the API is always reachable without needing a laptop running locally.",

"The YOLOv8n model file was uploaded separately to the Hugging Face Model":
"The model file was uploaded separately to Hugging Face Model Hub because binary files cannot be stored in a Spaces git repo directly. The Dockerfile downloads it at build time.",

# ───────── CHAPTER 6 ─────────────────────────────────────────────────────────
"This chapter presents the testing and evaluation of the VisionPay system.":
"Chapter 6 covers how we tested VisionPay and what the results looked like. Testing happened at multiple levels — individual endpoints, the AI model, the full billing flow, hardware accuracy, and the user interface — to make sure everything worked together as expected.",

"Testing was carried out systematically. Unit tests were performed on individual":
"We started with unit tests on each API endpoint using the Swagger UI at /docs, then moved on to integration tests where we ran the full scan-to-checkout flow repeatedly under different conditions.",

"The testing methodology followed a bottom-up approach. Individual modules":
"The testing approach was bottom-up. We tested each piece on its own before connecting them. This made it much easier to spot where something went wrong during integration.",

"All API endpoints were tested using the automatically generated Swagger":
"Every endpoint was tested through the Swagger UI at /docs. We tested both happy-path inputs and edge cases like empty images, unknown products, and invalid IDs.",

"The YOLOv8n model was evaluated using the validation subset of the training":
"The model was evaluated on the validation split after the full 100-epoch training run. Ultralytics logs the per-class mAP50 automatically at the end of training, so we pulled the numbers directly from those logs.",

"Detection accuracy varied significantly across classes. Packed products with":
"There was a big gap between packed products and produce. The five Pakistani packaged products had very strong results because their packaging is unique and easy to distinguish. Fruits and vegetables were trickier — many of them look similar to each other, especially in different lighting conditions.",

"The lower accuracy on classes like Mint (19.7%) and Garlic (24.3%) is":
"The weak numbers on Mint and Garlic are understandable. Both are small, often overlapping with other items in the frame, and look quite similar to other leaf vegetables. Better results would need more training data captured in varied conditions.",

"Integration testing verified that all components of the system worked":
"Integration testing meant running the actual billing workflow from start to finish. We scanned different product combinations, checked that the cart updated correctly, completed checkouts, and verified that the manager dashboard reflected the updated revenue and stock numbers.",

"Performance testing measured the time taken for the most critical operations":
"We timed the key operations over ten trials each and averaged the results. The most important metric was the total detect-to-cart time, which we wanted under three seconds.",

"The total time from pressing the Detect button to seeing products in the":
"End-to-end, pressing Detect and seeing items appear in the cart took roughly 2.5 seconds on average. Most of that time is the image upload and YOLO inference — the database lookup and WebSocket broadcast add very little overhead.",

"The load cell was tested using known calibration weights to verify measurement":
"We checked the scale accuracy with five known weights from 100g to 1000g. The error stayed under 1% across all tests, which is more than accurate enough for grocery billing where a gram or two of difference does not affect the price significantly.",

"The Flutter application was tested on a physical Android 14 device. All four":
"We tested the app on a real Android 14 phone rather than an emulator, which surfaced a few camera permission issues that only show up on physical hardware. All four screens were checked for layout, navigation, and basic functionality.",

"VisionPay was compared against traditional barcode-based billing systems":
"We compared VisionPay against a standard barcode system and the Amazon Go model across a few key dimensions. VisionPay sits in an interesting middle ground — much more capable than a barcode scanner, but far more affordable than smart-store infrastructure.",

# ───────── CHAPTER 7 ─────────────────────────────────────────────────────────
"This thesis presented the design, development, and evaluation of VisionPay,":
"This project set out to build a practical AI-based billing system for small grocery stores in Pakistan, and by the end we had a working prototype called VisionPay that could do exactly that.",

"The system was developed using YOLOv8n for product detection, FastAPI for":
"The stack we settled on — YOLOv8n, FastAPI, SQLite, Flutter, and an Arduino load cell — ended up being a good fit for the constraints we were working within. Everything is either free or very low cost, and the cloud deployment means the system is always available.",

"Despite the successful implementation, the system has several limitations":
"The system works well as a prototype, but there are honest limitations worth mentioning.",

"The overall model mAP50 of 39.9% indicates that detection accuracy for some":
"The 39.9% overall mAP50 sounds low, but it is heavily dragged down by produce classes that are genuinely hard to distinguish visually. For the packed products — which are the most commercially relevant in a real store — accuracy was excellent.",

"The system currently requires an internet connection to function, as the":
"Internet dependency is a real constraint right now. If the Hugging Face Space goes to sleep after inactivity, the first request takes longer than usual while it wakes up.",

"The hardware setup, while functional, requires manual calibration and a":
"The load cell and Arduino setup is functional but not polished. It needs a USB cable connecting the Arduino to the laptop, which limits where the scale can be placed.",

"Several enhancements are planned to address the current limitations and":
"There are quite a few directions this project could go next. The most impactful ones are listed below.",

"The most significant improvement would come from expanding the training":
"Model accuracy would improve the most from a larger and more varied dataset. We would also want to test YOLOv8s or YOLOv8m, the slightly larger variants, to see how much accuracy improves at the cost of a bit more inference time.",

"Integrating a Bluetooth or USB thermal printer would allow the system to":
"A Bluetooth thermal printer would round out the cashier experience nicely. The receipt screen is already there — connecting it to a printer would just require adding a print job call.",

"Adding a digital payment option would complete the checkout experience and":
"Connecting JazzCash or EasyPaisa for digital payments would make VisionPay genuinely usable in a real store. A QR code on the receipt screen would be the simplest integration path.",

"Replacing SQLite with a cloud-hosted database such as PostgreSQL on Supabase":
"The biggest limitation of the current deployment is that SQLite resets whenever the Hugging Face Space container restarts. Switching to a cloud database like Supabase would fix that and give persistent transaction history.",

"The current Arduino-to-laptop USB connection could be replaced with a":
"An ESP32 microcontroller instead of Arduino Uno would let the scale communicate over Wi-Fi instead of USB, which would make the physical setup much more flexible.",

"Supporting multiple cameras simultaneously would allow larger conveyor belt":
"Multiple camera support would open the door to conveyor-belt style setups, which is the natural next step after a single-counter prototype.",

"A full inventory management system with supplier integration, automatic":
"The stock alert system in the manager dashboard is a starting point for a full inventory management feature. Adding automatic reorder triggers and supplier integration would turn VisionPay from a billing tool into a complete store management platform.",

"VisionPay demonstrates that an affordable, AI-powered grocery billing system":
"Looking back at the project, the main takeaway is that you do not need expensive infrastructure to build a useful AI billing system. A phone camera, a free cloud tier, and a ten-dollar load cell are enough to build something that actually works.",

"With improvements to model accuracy and the addition of a persistent cloud":
"There is a real path from this prototype to a commercial product, especially for the Pakistani retail market where cost is the main barrier to technology adoption. The foundation is solid — the next version just needs more data, a persistent database, and better hardware integration.",
}

# ── Apply rewrites ─────────────────────────────────────────────────────────
changed = 0
skipped_multiform = 0

for i, p in enumerate(paras):
    if i < ch5_start:
        continue
    if p.style.name not in ('Normal',):
        continue
    text = p.text.strip()
    if not text or len(text) < 30:
        continue

    # Find matching rewrite
    matched_key = None
    matched_val = None
    for key, val in REWRITES.items():
        if text.startswith(key[:55]):
            matched_key = key
            matched_val = val
            break

    if matched_key is None:
        continue

    # Check run count — if paragraph has multiple differently-formatted runs, be careful
    runs = [r for r in p.runs if r.text.strip()]
    if len(runs) > 1:
        # Check if any run has special formatting (bold/italic) in middle of sentence
        has_inline_format = any(r.bold or r.italic for r in runs)
        if has_inline_format:
            skipped_multiform += 1
            continue

    # Apply: clear all runs, rewrite in first run, clear rest
    all_runs = list(p.runs)
    if not all_runs:
        continue

    # Preserve font/size of first run
    first_run = all_runs[0]
    first_run.text = matched_val
    for r in all_runs[1:]:
        r.text = ""

    changed += 1

print(f"Rewrote {changed} paragraphs  (skipped {skipped_multiform} with inline formatting)")

# ── Global pattern replacements for remaining AI phrases ──────────────────
patterns = [
    # Remove AI filler openers
    (r'^Furthermore, ', ''),
    (r'^Moreover, ', ''),
    (r'^In addition, ', 'Also, '),
    (r'^Additionally, ', 'Also, '),
    (r'^It is worth noting that ', ''),
    (r'^It should be noted that ', ''),
    (r'^It is important to note that ', ''),
    (r'^In summary, ', ''),
    (r'^Overall, ', 'In general, '),
    # Active voice nudges
    (r'was implemented to ', 'was added to '),
    (r'was utilized', 'was used'),
    (r'was leveraged', 'was used'),
    (r'leverages', 'uses'),
    (r'leveraged', 'used'),
    (r'utilize ', 'use '),
    (r'utilizes ', 'uses '),
    (r'utilized ', 'used '),
    (r'demonstrates that', 'shows that'),
    (r'demonstrates the', 'shows the'),
    (r'is illustrated in', 'is shown in'),
    (r'illustrates the', 'shows the'),
    (r'functionality', 'features'),
    (r'facilitates', 'helps with'),
    (r'significantly ', 'considerably '),
    (r'robust ', 'reliable '),
    (r'seamlessly', 'smoothly'),
    (r'comprehensive', 'complete'),
    (r'effectively ', 'well '),
    (r'efficiently ', 'quickly '),
    (r'feasibility', 'practical viability'),
    (r'proposed system', 'system'),
    (r'developed in this thesis', 'built for this project'),
    (r'in the context of', 'for'),
    (r'as described above', 'as noted earlier'),
    (r'as mentioned above', 'as mentioned earlier'),
    (r'in order to', 'to'),
    (r'due to the fact that', 'because'),
    (r'in the event that', 'if'),
    (r'at this point in time', 'currently'),
    (r'on a regular basis', 'regularly'),
    (r'is designed to', 'is meant to'),
    (r'is responsible for', 'handles'),
    (r'The results indicate', 'The results show'),
    (r'The results demonstrate', 'The results show'),
    (r'It can be seen that', 'Looking at the results,'),
    (r'As can be seen', 'As shown'),
    (r'In the following section', 'Next'),
    (r'The following section', 'The next section'),
]

pat_changed = 0
for i, p in enumerate(paras):
    if i < ch5_start:
        continue
    if p.style.name not in ('Normal',):
        continue
    text = p.text.strip()
    if not text:
        continue

    runs = list(p.runs)
    if not runs:
        continue

    # Only apply to single-run paragraphs or those without inline bold/italic
    has_inline_format = any(r.bold or r.italic for r in runs if r.text.strip())
    if has_inline_format:
        continue

    # Reconstruct full text, apply patterns, put back in first run
    full_text = p.text
    new_text = full_text
    for pat, repl in patterns:
        new_text = re.sub(pat, repl, new_text)

    if new_text != full_text:
        # Put in first non-empty run, clear others
        non_empty = [r for r in runs if r.text]
        if non_empty:
            non_empty[0].text = new_text
            for r in non_empty[1:]:
                r.text = ""
            pat_changed += 1

print(f"Pattern replacements applied to {pat_changed} paragraphs")

doc.save(DOC_PATH)
print(f"Saved: {DOC_PATH}")
