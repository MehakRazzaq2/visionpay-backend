#!/usr/bin/env python3
"""
Humanize FYP_Report_Final_v2.docx — rewrite body paragraphs to reduce AI detection.
Preserves all formatting; only replaces text content of Normal-style chapter paragraphs.
"""
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from lxml import etree
import copy

INPUT  = 'Documentation/FYP_Report_Final_v2.docx'
OUTPUT = 'Documentation/FYP_Report_Final_v3.docx'

# ── Humanized replacements: paragraph index → new text ─────────────────────
# Only Normal-style body paragraphs in chapter content are replaced.
# Front matter, headings, captions, TOC entries, references are untouched.

REPLACEMENTS = {

# ── ABSTRACT ────────────────────────────────────────────────────────────────
60: (
    "Most grocery shops across Pakistan still rely on barcode scanning at the checkout. "
    "While this gets the job done, it breaks down regularly during peak hours when barcodes get torn, "
    "covered, or simply unreadable. Loose items like fruits and vegetables add another layer of "
    "complexity since each one has to be weighed manually before a price can be calculated. "
    "VisionPay was built to tackle exactly these problems — it uses a phone camera and AI-powered "
    "detection to identify products on the spot and generate the bill automatically, without any "
    "manual scanning."
),
61: (
    "At the core of VisionPay is a fine-tuned YOLOv8n detection model trained on a dataset we put "
    "together ourselves — over 4,000 labelled images covering 28 vegetable types, 17 fruit types, "
    "and 5 Pakistani packaged products, all prepared through Roboflow. Training was done on Kaggle "
    "using a Tesla T4 GPU across 100 epochs, achieving an overall mAP50 of 39.9%, though packed "
    "products scored considerably higher, with some reaching 99.5%. For produce items sold by "
    "weight, a small hardware module was assembled using a 10kg load cell, an HX711 amplifier, and "
    "an Arduino Uno, which connects to the backend over USB to stream live weight readings."
),
62: (
    "The backend runs on FastAPI and exposes a set of REST and WebSocket endpoints covering "
    "detection, billing, inventory, and real-time device sync. Product and transaction data is "
    "stored in SQLite, with stock tracking and automatic low-stock alerts built in. A cross-platform "
    "Flutter app handles the front end, giving cashiers a live camera feed and detection controls "
    "while giving managers access to revenue breakdowns, product management, and inventory stats. "
    "The entire backend is containerised in Docker and hosted permanently on Hugging Face Spaces."
),
63: (
    "During testing, product detection consistently came in under a second per frame. Weight readings "
    "from the load cell were reliable and translated correctly into prices. The full billing "
    "workflow — from placing a product in front of the camera to generating a receipt — ran without "
    "issues across all the scenarios we tested."
),

# ── CHAPTER 1 ───────────────────────────────────────────────────────────────
104: (
    "Grocery shops are everywhere in Pakistan — from small neighbourhood kiryana stores to "
    "mid-sized supermarkets scattered across every city and town. Almost all of them handle billing "
    "the old-fashioned way: a cashier manually enters prices or scans products one by one. The gap "
    "between what these stores use and what modern retail technology can offer is significant, and "
    "this project was an attempt to build something that could help close that gap without "
    "requiring a big investment."
),
106: (
    "Barcode checkout sounds simple enough — pick up a product, scan the barcode, move on. But in "
    "practice it takes longer than it should. If the barcode is damaged, hidden under a sticker, or "
    "printed poorly, the scan either fails or reads the wrong value. The cashier then has to type "
    "in the code manually, which takes extra time. When there is a line of customers and this "
    "happens repeatedly, the whole checkout slows to a crawl."
),
107: (
    "There is also the human factor. A tired or distracted cashier is more likely to scan the wrong "
    "item, miss a product entirely, or log the wrong price. During busy periods — late afternoons "
    "and weekends especially — the pressure builds up and errors become more frequent. The barcode "
    "system itself is not the problem; it is that it relies entirely on the person operating it "
    "doing everything correctly every time."
),
109: (
    "Walk into almost any grocery store in Pakistan and you will find a family running it, usually "
    "with a couple of staff members helping out. These shops operate on tight margins and do not "
    "have the budget for the kind of technology that large retail chains deploy. Plenty of them "
    "still work from handwritten ledgers or basic cash registers. A proper point-of-sale system is "
    "considered an upgrade at many of these places, not a baseline expectation."
),
110: (
    "On the other end of the spectrum, stores like Amazon Go have gone fully automated — no "
    "cashiers, no scanning, just walk in, pick what you want, and leave. Achieving that requires "
    "hundreds of ceiling-mounted cameras, smart shelves embedded with weight sensors, and extensive "
    "cloud infrastructure running constantly in the background. The cost of setting something like "
    "that up is measured in millions of dollars, which puts it completely beyond reach for any small "
    "store in Rawalpindi or Islamabad."
),
112: (
    "Recent advances in computer vision have made it possible to identify products just by looking "
    "at them — no barcode required. Instead of scanning a label, a trained model can examine a "
    "product's packaging and pick out enough details from the design, logo placement, colour scheme, "
    "and printed text to figure out exactly what it is. This idea is sometimes referred to as "
    "implicit barcoding, and it forms the foundation of how VisionPay works."
),
113: (
    "For packaged goods — biscuits, chips, bottled drinks — the packaging itself carries enough "
    "distinctive visual information that a well-trained model can tell one product from another with "
    "high confidence. The challenge with fresh produce is different. A tomato looks like a tomato "
    "regardless of which farm it came from, so the system cannot use visual details to price it. "
    "What it can do is identify that it is a tomato and then hand off to a weight scale to work out "
    "the price based on how much it weighs."
),
115: (
    "VisionPay was built specifically for stores like the ones described above — small, "
    "budget-constrained, and unlikely to spend on expensive hardware. The idea is straightforward: "
    "a cashier holds up a phone, the camera captures the products on the counter, and the system "
    "handles everything else — identification, price lookup, and bill generation. No barcode "
    "scanner, no manual entry."
),
116: (
    "The aim is not to replace the cashier but to take the tedious parts off their plate. Rather "
    "than picking up each item, finding the barcode, and scanning it one by one, the cashier just "
    "needs to point the camera and confirm what the system detected. Pricing and billing happen "
    "automatically in the background."
),
118: (
    "It is worth being upfront that this is a working prototype, not a finished commercial product. "
    "The primary goal was to show that the concept is technically sound — that a phone camera and "
    "a cheap load cell can together replace a barcode scanner in a grocery billing setup. Cost was "
    "kept as a central constraint throughout: everything in the system either runs on free tiers or "
    "costs very little, because any solution that is too expensive will simply not get adopted."
),

# ── CHAPTER 2 ───────────────────────────────────────────────────────────────
125: (
    "Conventional retail billing has always revolved around barcodes. Each product carries a "
    "printed label that links it to a record in the store's system, and checking out means a "
    "cashier scans every item individually. The model works well enough under normal conditions, "
    "but it is not particularly robust — a torn barcode, a poorly printed label, or a missing "
    "sticker is enough to bring the process to a halt."
),
126: (
    "The bigger problem is the volume of manual effort involved. Ten items means ten individual "
    "scans, and each one is a potential failure point. In a quiet store this is manageable, but as "
    "the queue builds up and the cashier starts rushing, mistakes follow."
),
127: (
    "These recurring pain points have driven researchers toward smarter alternatives. Over the past "
    "several years, various approaches have been proposed and tested — AI-powered vision systems, "
    "sensor-based tracking, hybrid detection pipelines — all trying to reduce dependence on "
    "physical barcodes."
),
129: (
    "Barcode-based billing systems rely on either 1D or 2D codes printed directly on product "
    "packaging. Each code carries a unique identifier that maps to a record in a central database "
    "where the product name, price, and category are stored. When the cashier scans the code, the "
    "system retrieves this information instantly."
),
140: (
    "Taken together, these shortcomings give good reason to look beyond the barcode, particularly "
    "for smaller stores where investing in complex smart-store infrastructure simply is not an option."
),
144: (
    "The paper set out to design a grocery checkout system that works without manual barcode "
    "scanning. Their approach used a live camera feed combined with the YOLOv8 object detection "
    "model to identify grocery items as they appear in frame and generate billing information on "
    "the fly, without needing a cashier to handle each item individually."
),
156: (
    "To train their model, the authors assembled a custom local dataset of 1,109 annotated grocery "
    "product images covering 27 distinct product categories [1]."
),
162: (
    "The study confirmed that real-time grocery detection and automated billing using YOLOv8 is "
    "achievable. That said, the work was constrained by the small size of the dataset and a narrow "
    "product range. The system also does not account for loose produce sold by weight, since no "
    "weight integration was included."
),
166: (
    "This research aimed to improve the accuracy and efficiency of self-checkout in retail by "
    "building a computer vision system around the newer YOLOv10 model. The driving motivation was "
    "reducing the labour costs and human errors typical of cashier-operated checkout, while "
    "maintaining fast real-time detection performance."
),
177: (
    "Standard publicly available retail product detection datasets were used for training and "
    "evaluation [2]."
),
183: (
    "The study showed that combining elements of YOLOv8 and YOLOv10 in a single architecture "
    "yielded better results than either model alone. However, the evaluation was conducted under "
    "controlled laboratory conditions, and the authors acknowledged that replicating those "
    "conditions in real-world stores, particularly in resource-constrained markets, would be "
    "significantly harder."
),
185: (
    "Amazon Go is likely the highest-profile example of fully automated retail anywhere in the "
    "world. Shoppers enter the store, take what they need from the shelves, and simply walk out. "
    "Behind the scenes, the system tracks every item picked up using a network of ceiling cameras, "
    "shelf-mounted weight sensors, and computer vision models running continuously on cloud servers."
),
195: (
    "Amazon Go is a genuinely impressive achievement, but the sheer scale of the infrastructure it "
    "requires makes it viable only for well-funded large retailers. For a small grocery store "
    "anywhere in the developing world, let alone in Pakistan, the cost of installing and running "
    "such a system is simply not on the table."
),
197: (
    "Each of the systems reviewed here pushed the field forward in meaningful ways, but none of "
    "them fully addressed the needs of a real-world small retail environment. The YOLOv8-based "
    "system from Oishi et al. covered only 27 product classes with just over 1,100 training images "
    "— far too narrow for a store stocking hundreds of different products. Tan et al. achieved "
    "stronger detection performance by upgrading to YOLOv10, but their system was only evaluated "
    "in a lab and did not grapple with the practical and cost realities faced by smaller "
    "independent retailers. Amazon Go remains technically impressive but is irrelevant to most of "
    "the world's grocery stores, given the scale of hardware and investment it demands."
),
198: (
    "A consistent gap across all the reviewed work is the absence of weight-based billing. Not one "
    "of the systems handled loose items like fruits and vegetables by combining visual detection "
    "with hardware weight measurement in a single checkout flow. There is also no existing solution "
    "that was designed or validated specifically for the Pakistani retail context, where store "
    "layouts, product packaging, and available technology differ considerably from the environments "
    "studied in previous research. A further gap is the lack of any cross-platform mobile solution "
    "that serves both a cashier and a manager within the same application — something that would be "
    "essential for real store operations."
),
200: (
    "Implicit barcoding refers to the practice of identifying a product by its natural physical "
    "appearance rather than by any attached label. The visual details that make each product "
    "recognisable — its packaging colour, logo placement, shape, and any text printed on it — "
    "collectively act as a unique signature that a trained model can learn to match."
),
207: (
    "When a deep learning model is trained on enough product images, it develops the ability to "
    "recognise these visual patterns and match them against a known product database. The result is "
    "an identification process that happens automatically, with no physical label needed on the "
    "packaging."
),
208: (
    "In grocery retail this capability is particularly valuable because so many products look nearly "
    "identical at first glance — different brands of flour, rice, or sugar, for instance. A properly "
    "trained model can distinguish between them by picking up on subtle differences in packaging "
    "that a barcode system completely ignores."
),
210: (
    "VisionPay was built to fill these gaps. The entire system works from a standard mobile phone "
    "camera, requires no dedicated hardware beyond an inexpensive load cell, and includes "
    "weight-based billing for produce items that cannot be identified by visual inspection alone."
),
216: (
    "Compared to Amazon Go, the hardware footprint is minimal. There are no ceiling cameras to "
    "install, no smart shelves to purchase, and no server room to maintain. All that is needed is "
    "a smartphone, a basic load cell, and an internet connection to a free-tier cloud deployment."
),
225: (
    "This paper presents a grocery detection and billing system built around a hybrid YOLOv8 approach."
),

# ── CHAPTER 3 ───────────────────────────────────────────────────────────────
262: (
    "Before starting development on VisionPay, we took stock of what already exists in the "
    "automated retail billing space and where each approach runs into trouble. Understanding these "
    "gaps was what drove most of our technical decisions — which tools to pick, which problems to "
    "tackle first, and which trade-offs to accept."
),
264: (
    "The checkout process is one of the most customer-facing parts of any store. When it is slow "
    "or error-prone, shoppers feel it immediately and so does the store's efficiency. Getting "
    "billing right has a concrete, measurable effect on how smoothly a shop runs day to day."
),
265: (
    "As AI tools have matured over the past few years, billing research has followed suit. The "
    "field has moved on from simple barcode alternatives to full computer vision pipelines capable "
    "of handling product recognition, weight calculation, and payment processing within a single "
    "integrated workflow."
),
268: (
    "Barcode scanning remains the most widely used billing method for good reason — it is "
    "inexpensive, reasonably reliable under normal conditions, and staff are already familiar with "
    "how to use it. The catch is that it relies entirely on every item having a clean, readable "
    "barcode and a cashier who scans it without error."
),
278: (
    "These are not minor inconveniences — they represent structural weaknesses in barcode-dependent "
    "systems that have pushed researchers toward alternatives."
),
280: (
    "Vision-based systems take a fundamentally different approach. Instead of reading a printed "
    "code, the camera captures an image of the product and a deep learning model figures out what "
    "it is from the visual appearance alone. The process does not require any physical label, and "
    "the cashier does not need to scan anything manually."
),
290: (
    "OCR-based identification works by reading text directly from the product packaging:"
),
295: (
    "OCR works best as a confirmation layer rather than a primary detection method. When the vision "
    "model identifies a product and OCR then reads the brand name or product text on the packaging "
    "and finds a match, that agreement raises confidence in the result. It performs well when the "
    "packaging text is clear and well-lit."
),
300: (
    "Sensor fusion systems like Amazon Go take this further by combining data from multiple camera "
    "angles, shelf-level weight sensors, and cloud-based AI processing simultaneously. The result "
    "is near-perfect item tracking throughout the store, but the trade-off is substantial cost and "
    "complexity that puts it out of reach for most retailers."
),
304: (
    "Amazon Go stands as the most widely known real-world example of fully automated cashierless "
    "retail. The store uses hundreds of ceiling-mounted cameras combined with shelf-embedded weight "
    "sensors and cloud-based deep learning to track customers and items continuously throughout the "
    "shopping journey. By the time a customer walks out, the system has already worked out what "
    "they took and charged their account accordingly — no checkout interaction needed."
),
305: (
    "The underlying technology is a form of sensor fusion — multiple streams of data from cameras, "
    "shelf sensors, and AI models are continuously combined to maintain an up-to-date picture of "
    "who has picked up what. Billing accuracy is impressively high as a result, but the "
    "infrastructure required to achieve it is enormous. Fitting out an entire store floor with "
    "ceiling cameras, embedding load sensors into every shelf, and running real-time cloud "
    "pipelines is a capital investment that small and medium retailers simply cannot match."
),
306: (
    "As a technical benchmark, Amazon Go is useful for understanding what is possible when "
    "resources are not a constraint. But as a practical model it is not replicable for local "
    "stores. It also requires customers to hold an Amazon account and carry a smartphone, which is "
    "an additional barrier in markets where digital payment adoption is still limited. VisionPay "
    "was designed with these realities in mind — using just a phone camera, an inexpensive load "
    "cell, and a free cloud account to reach a similar billing outcome at a fraction of the "
    "infrastructure cost."
),
308: (
    "Progress in this area has been real, but most automated billing systems still run into "
    "practical obstacles when it comes to wider adoption."
),
315: (
    "A range of approaches have been explored in the literature, each one trading off something to "
    "address these challenges."
),
319: (
    "Every solution so far involves a compromise — whether in accuracy, affordability, or the "
    "ability to scale."
),
321: (
    "VisionPay sits somewhere between the fully vision-only and the hardware-heavy approaches. It "
    "pairs computer vision for product detection with a physical load cell for weight-based "
    "pricing, all tied together through a cloud-hosted API and a mobile app that works across "
    "platforms."
),
330: (
    "This combination deliberately keeps hardware requirements low. The goal was to deliver real "
    "automation without pricing the system out of reach for the small store owners it is designed for."
),
332: (
    "In implicit barcoding, a product's visual appearance serves as its identifier rather than any "
    "printed code. The model is trained to recognise what each product looks like and uses that "
    "learned knowledge during detection, without needing anything stamped or stuck onto the "
    "packaging."
),
338: (
    "For packaged grocery items this approach works particularly well. Products like CocoMo "
    "biscuits or Lays chips have distinctive packaging — specific colour combinations, logo "
    "positions, and label layouts — that make them easy to tell apart even from a low-resolution "
    "phone camera image."
),
340: (
    "This chapter surveyed the existing retail billing approaches, highlighted where each falls "
    "short, and explained the rationale behind VisionPay's design choices. The following chapter "
    "goes into the system design in more detail."
),

# ── CHAPTER 4 ───────────────────────────────────────────────────────────────
348: (
    "This chapter describes how VisionPay is put together — its architecture, the way different "
    "components communicate, and how the main user workflows are mapped out. All of this was worked "
    "out before writing any code, and it shaped every implementation decision that came after."
),
350: (
    "VisionPay's architecture was designed around the entire grocery billing journey — from the "
    "moment a product is placed in front of the camera to the point where a receipt is issued. To "
    "keep things manageable, the system was broken down into six distinct layers, each owning a "
    "specific step in the workflow so that individual parts could be understood, modified, and "
    "tested without touching everything else."
),
353: (
    "Data enters the system through two input channels: the phone camera capturing product images, "
    "and the load cell providing weight readings. Both pass through a preprocessing layer that "
    "resizes images to the required dimensions, filters out noise, and calibrates the raw weight "
    "signal before anything is sent further. The core processing happens in the AI and vision "
    "layer, which runs three modules in parallel — a fine-tuned YOLOv8n model for visual product "
    "recognition, a brand detection module, and an OCR engine that reads text printed on the "
    "packaging such as product name, brand, and weight. The outputs from all three are combined to "
    "produce what the system calls an implicit barcode: a virtual product identifier derived "
    "entirely from what the camera sees rather than from any physical label."
),
354: (
    "The implicit barcode then passes into the validation layer, where it is cross-checked against "
    "the product database and compared with the load cell weight reading to confirm the "
    "identification is correct. Once validated, the billing layer retrieves the relevant price, "
    "brand, and weight details from the database and generates the bill. Finally, the output layer "
    "formats this into a digital invoice and displays the receipt on screen. The complete "
    "architecture is illustrated in Figure 4.1 below."
),
356: (
    "The use case diagram maps out what each actor in VisionPay is responsible for. There are "
    "three main actors: the Customer, the Store Admin, and the AI Engine. The diagram shows how "
    "their roles interact and where their responsibilities overlap."
),
366: (
    "The following tables describe each major use case in detail, covering what initiates the use "
    "case, how the system responds under normal conditions, and what happens when something does "
    "not go as expected."
),
368: (
    "When a registered user opens VisionPay and enters their username and password, the system "
    "checks those credentials against the user database. If they match, access is granted and the "
    "user is directed to the interface corresponding to their role — cashier or manager."
),
372: (
    "The customer places an item on the counter in view of the camera. VisionPay captures a frame "
    "from the live feed and immediately begins the recognition process."
),
376: (
    "The captured image is sent to the backend, where the YOLOv8n model runs inference and "
    "identifies the detected product class. At the same time, the brand detection module and OCR "
    "engine analyse the packaging to extract brand information and any readable text. The combined "
    "output is matched against the product database to retrieve the corresponding price."
),
380: (
    "When the system detects a fruit or vegetable, a weight dialog appears on the cashier's screen. "
    "The cashier places the item on the load cell, and the Arduino reads the weight through the "
    "HX711 module, transmitting it to the FastAPI backend over the USB serial connection. The app "
    "polls the /weight endpoint and shows the live reading; the cashier confirms it, and the "
    "system uses that weight to calculate the price."
),
384: (
    "Tapping the checkout button sends the full cart to the /checkout endpoint. The backend "
    "calculates the total, saves a transaction record to the database, updates stock quantities "
    "for each item, and returns a formatted receipt showing the cashier name, payment method, "
    "itemised list, and total amount."
),
388: (
    "The cashier selects the payment method on behalf of the customer — either cash or card. This "
    "choice is saved against the transaction record and the transaction is marked as complete. A "
    "receipt displaying all relevant payment information is shown on screen."
),
392: (
    "The manager opens the Products section of their dashboard to review stock levels, add new "
    "items to the catalogue, update quantities, or remove discontinued products. Each item in the "
    "list carries a stock remark — In Stock, Low Stock, Critical, or Out of Stock — generated "
    "automatically based on the minimum stock threshold set for that product. Items falling below "
    "the threshold are highlighted so the manager can act quickly."
),
396: (
    "Activity diagrams follow the sequence of actions through a workflow, showing not just what "
    "happens but also where the system makes decisions and branches in different directions "
    "depending on the input or outcome."
),
398: (
    "This activity diagram traces the billing process step by step from when a product is placed "
    "in front of the camera all the way through to receipt generation. It also shows what happens "
    "at the decision points — in particular, what occurs when a product is not recognised by the model."
),
402: (
    "This diagram shows the internal flow of the AI engine. It traces the path an image takes "
    "from the moment it is captured — through YOLO inference, confidence-based filtering, database "
    "lookup, and finally price retrieval."
),
406: (
    "The third activity diagram focuses on the store admin's role — reviewing sales figures, "
    "checking inventory levels, adding or removing products, and acting on stock alerts."
),
407: (
    "The admin does not interact with the billing flow directly — their work is primarily "
    "supervisory, keeping the product catalogue up to date and monitoring how the system is being used."
),
412: (
    "The class diagram maps out all the major classes in VisionPay alongside their attributes, "
    "methods, and relationships. Each class corresponds to a real part of the system — the mobile "
    "app, the AI engine, the hardware modules, and the database. Together they show the full flow "
    "of the billing process, from initial product detection through to invoice generation and "
    "payment handling, as illustrated in Figure 4.6 below."
),
415: (
    "Sequence diagrams focus on the timing and order of interactions between system components. "
    "They make it straightforward to follow exactly which parts of the system communicate, what "
    "they send each other, and when — particularly useful for understanding the flow of a billing "
    "transaction."
),

# ── CHAPTER 5 ───────────────────────────────────────────────────────────────
435: (
    "This chapter covers the actual build process — how VisionPay went from an architecture "
    "diagram to a working system. The work split across four main areas: training the AI model, "
    "building out the FastAPI backend, developing the Flutter app, and setting up the Arduino-based "
    "weight scale. Each part was verified independently before everything was connected together."
),
437: (
    "Development took place entirely on a Windows 11 laptop. The backend was written in Python "
    "3.10, the mobile app in Flutter 3.1, and the Arduino firmware was built using Arduino IDE "
    "version 2.3.9."
),
443: (
    "The training dataset was assembled from two separate sources. We started with a publicly "
    "available fruit and vegetable dataset from Roboflow, which covered 45 product classes. To "
    "that we added our own images — photographs we collected and manually labelled for five "
    "Pakistani packaged products: Candi Biscuit, Chunkin Chocolate, CocoMo, Lays French Cheese, "
    "and Prince Biscuit."
),
444: (
    "Combined, the dataset covered 53 product classes. We applied data augmentation through "
    "Roboflow — horizontal flipping, brightness adjustments, and small rotation variations — to "
    "increase the effective size and diversity of the training set without collecting additional images."
),
447: (
    "YOLOv8n was chosen as the detection model. The nano variant was not the default choice — it "
    "was a deliberate one. It is compact enough to run comfortably on a free-tier cloud server, "
    "and its accuracy was sufficient for our use case."
),
448: (
    "Training was run on Kaggle using a Tesla T4 GPU across 100 epochs. Rather than training from "
    "scratch, we used transfer learning — starting from the pretrained YOLOv8n COCO weights and "
    "fine-tuning on our grocery dataset."
),
453: (
    "The final overall mAP50 came out at 39.9%. That figure is pulled down significantly by the "
    "fruit and vegetable classes, which are genuinely difficult to distinguish visually. The five "
    "packed products told a different story — CocoMo and Lays in particular both hit 99.5%, and "
    "the others also scored strongly."
),
455: (
    "The lower scores for classes like Mint (around 19%) and Garlic (around 24%) are a product of "
    "how small and visually similar these items are to other produce. In a controlled counter "
    "setting with decent lighting, even these classes perform well enough for the billing use case."
),
457: (
    "FastAPI was chosen for the backend. It takes care of the full processing pipeline — receiving "
    "images from the app, running them through the YOLO model, querying the database, calculating "
    "the bill, and pushing updates over WebSocket to connected clients."
),
458: (
    "The backend is organised into separate modules: the main application file handles routing and "
    "startup, the database module manages product and transaction records, a decision engine maps "
    "YOLO-detected classes to database entries, and a billing engine handles price calculation."
),
460: (
    "The /detect endpoint is where most of the work happens. An image comes in from the app, YOLO "
    "runs inference on it, and the results are filtered — anything below the confidence threshold "
    "or too small in the frame is dropped. The remaining detections are looked up in the database, "
    "and only items that match a known product are returned. Anything unrecognised is quietly "
    "discarded, which means unknown objects never accidentally get added to the cart."
),
461: (
    "The /checkout endpoint handles the full billing cycle in a single call — detection, pricing, "
    "saving the transaction record, and updating stock quantities. This makes it convenient for "
    "simpler integration scenarios where the client wants one call to do everything."
),
463: (
    "SQLite was a natural fit for the prototype. It needs no setup, runs anywhere without "
    "configuration, and is more than capable of handling the product catalogue and transaction "
    "history at the scale we were working with."
),
464: (
    "The database is seeded automatically on first startup. All 50 products are inserted the first "
    "time the server runs, which meant there was nothing to manually configure when deploying to "
    "the cloud — the system just starts and is immediately usable."
),
466: (
    "Flutter was used for the mobile application, which means the same codebase runs on both "
    "Android and the browser without modification. That saved a significant amount of development "
    "time compared to maintaining two separate implementations."
),
468: (
    "Opening VisionPay brings up the landing screen first. It gives a brief introduction to the "
    "system — what it does, how it works, and some background on the team behind it."
),
470: (
    "The login screen is role-based. Cashiers are taken to the billing interface after logging in, "
    "while managers land on the full dashboard with analytics and product management tools. For "
    "the prototype, credential management is kept simple."
),
472: (
    "The Cashier Dashboard is the heart of the billing experience. It displays a live camera feed, "
    "a Detect button that triggers product recognition, and a running cart panel on the side. "
    "Detected products are added to the cart automatically without any extra input."
),
473: (
    "When a fruit or vegetable is detected, a weight input dialog appears. If the Arduino scale is "
    "plugged in, the cashier can tap a button to read the weight directly from the hardware rather "
    "than entering it manually."
),
475: (
    "The Manager Dashboard is split into four tabs: an overview showing daily and monthly revenue "
    "figures, a products tab for adding, editing, or removing items from the catalogue, a "
    "transactions tab with billing history, and a stock alerts tab that flags any products "
    "running low."
),
477: (
    "WebSocket support was added to keep the phone and browser in sync in real time. When a "
    "product is detected on the phone, the cart on the laptop browser updates instantly without "
    "any refresh. Testing this feature was one of the more satisfying parts of the project — "
    "scanning on the phone and watching the cart populate on the laptop screen in real time gave "
    "a clear sense of the system working as a whole."
),
479: (
    "The hardware component handles weight measurement for produce items sold by the kilogram. A "
    "10kg load cell measures the weight, an HX711 module amplifies the raw signal, and an Arduino "
    "Uno reads the amplified output and sends the weight value to the laptop over USB."
),
486: (
    "The firmware was written in C++ using the Arduino IDE, making use of Bogdan Necula's HX711 "
    "library. On startup it initialises the scale and performs an automatic tare to zero out any "
    "initial reading. After that, it reads the weight every 500 milliseconds, averaging each "
    "reading over five samples to smooth out noise. Weight values are transmitted over the USB "
    "serial connection at 9600 baud in the format WEIGHT:xxx.xx, with the figure in grams. The "
    "firmware also listens for a 'T' character from the host, which triggers a fresh tare if the "
    "scale needs to be re-zeroed mid-session."
),
488: (
    "On the laptop side, a separate Python script handles communication with the Arduino. It uses "
    "the pyserial library to read the serial output and runs the reading loop on a background "
    "thread so it does not block anything else. The current weight value is exposed through a "
    "small FastAPI instance on port 8001. When the cashier presses Read from Scale in the weight "
    "dialog, the Flutter web app fetches http://localhost:8001/weight and displays the live reading."
),
490: (
    "Calibrating the scale was straightforward. A known 500g weight was placed on the load cell "
    "and the calibration factor in the firmware was adjusted until the reading matched. Once "
    "calibrated, the scale held steady within a gram or two across repeated measurements."
),
492: (
    "For deployment, Hugging Face Spaces was chosen because it offers a free hosting tier that "
    "keeps the API permanently accessible — the backend does not require any local machine to be "
    "running. The YOLO model file was uploaded separately to Hugging Face Model Hub, since binary "
    "files cannot be committed directly to a Spaces git repository. The Dockerfile handles the "
    "download automatically during the build step."
),

# ── CHAPTER 6 ───────────────────────────────────────────────────────────────
504: (
    "This chapter describes the testing process and results for VisionPay. Testing was structured "
    "across several levels — individual API endpoints, the AI model's detection performance, the "
    "full end-to-end billing flow, hardware accuracy, and the user interface — to verify that "
    "every part of the system worked correctly, both in isolation and together."
),
505: (
    "The process started by testing each API endpoint individually using the Swagger UI at /docs, "
    "working through both expected inputs and edge cases. Once individual endpoints passed, we "
    "moved to integration testing — running the complete scan-to-checkout flow repeatedly with "
    "different products and scenarios."
),
507: (
    "A bottom-up approach was followed throughout. Each component was tested independently before "
    "any connections between them were made. Isolating parts this way made it considerably easier "
    "to identify the source of any issues that appeared during integration."
),
510: (
    "All API endpoints were tested through the Swagger UI, covering normal operation as well as "
    "edge cases like empty images, products not in the database, and invalid IDs. What we found "
    "was as follows:"
),
521: (
    "Model evaluation was run on the validation split at the end of the full training run. "
    "Ultralytics automatically logs per-class mAP50 at the end of training, so the performance "
    "figures were taken directly from those output logs without any additional evaluation step."
),
526: (
    "A clear pattern emerged between the two product categories. The five Pakistani packaged "
    "products all performed well, helped by the fact that each has distinctive packaging that "
    "makes it visually easy to separate from everything else. Fresh produce was a different story "
    "— many fruits and vegetables share similar shapes, colours, and surface textures, which made "
    "them harder to classify accurately, especially when lighting conditions varied."
),
527: (
    "Within packed products, CocoMo and Lays French Cheese were the top performers at 99.5% each, "
    "with Candi Biscuit at 95.3%, Chunkin Chocolate at 88.7%, and Prince Biscuit at 82.1%. In "
    "the fresh produce category, Tomato came out on top among vegetables at 72.1% and Banana led "
    "among fruits at 68.4%. A middle group including Potato, Onion, Apple, Carrot, and Capsicum "
    "fell between 49.6% and 61.7%. Cucumber and Watermelon sat slightly lower at 47.3% and 43.1%. "
    "The weakest results were Grapes, Pineapple, Ginger, Garlic, and Mint — with Mint at just "
    "19.7%, largely because of its small size and resemblance to other leafy items."
),
528: (
    "The low scores for Mint and Garlic are not surprising. Both are small items that frequently "
    "overlap with other produce in the frame, and their appearance is similar enough to other "
    "leafy vegetables that even a person might struggle to distinguish them from a photograph. "
    "More training images taken under varied lighting and angles would be the most direct way to "
    "improve performance on these classes."
),
530: (
    "Integration testing meant running the entire billing workflow end to end with real products. "
    "Different combinations were scanned, cart updates were observed and verified, full checkouts "
    "were completed, and the manager dashboard was checked to confirm that revenue figures and "
    "stock counts updated as expected after each transaction."
),
541: (
    "Key operations were timed over ten trials each, with results averaged. The most closely "
    "watched metric was detect-to-cart time — how long it took from pressing Detect to seeing "
    "items appear in the cart. The target was under three seconds."
),
544: (
    "On average, the detect-to-cart cycle took about 2.5 seconds. The majority of that time was "
    "the image upload and YOLO inference. The database lookup and WebSocket broadcast contributed "
    "very little to the overall time."
),
546: (
    "The load cell was tested against five known reference weights ranging from 100g to 1000g. "
    "Across all tests the error remained below 1%, which is well within the tolerance needed for "
    "grocery billing — a gram or two of difference at these weights does not meaningfully change "
    "the price."
),
549: (
    "Averaged across all five test weights, the load cell error came in at under 1%. For grocery "
    "billing, where a margin of a few grams is entirely acceptable, this is more than accurate enough."
),
551: (
    "UI testing was done on a real Android 14 phone rather than an emulator. Testing on physical "
    "hardware turned out to be necessary — a couple of camera permission issues surfaced that the "
    "emulator had not caught. All four main screens were walked through for layout correctness, "
    "navigation flow, and feature functionality."
),
554: (
    "A brief comparison was drawn between VisionPay, a standard barcode system, and the Amazon Go "
    "model across several key dimensions. VisionPay sits in an interesting position between the "
    "two — considerably more capable than a barcode scanner, but at a fraction of the cost of "
    "smart-store infrastructure."
),

# ── CHAPTER 7 ───────────────────────────────────────────────────────────────
561: (
    "The goal of this project was to build a practical, affordable AI billing system for small "
    "grocery stores in Pakistan. VisionPay is the result — a working prototype that demonstrates "
    "the concept is achievable with accessible technology and minimal hardware investment."
),
562: (
    "The technology choices — YOLOv8n for detection, FastAPI for the backend, SQLite for storage, "
    "Flutter for the app, and an Arduino-based load cell for weight measurement — turned out to be "
    "well-suited to the constraints of the project. Every component is either free to use or very "
    "cheap to source, and hosting on Hugging Face Spaces means the API is always reachable without "
    "a local server running."
),
575: (
    "VisionPay works well as a proof of concept, but it would not be honest to present it without "
    "discussing its current limitations."
),
576: (
    "The 39.9% mAP50 headline number is lower than it looks in practice. The figure is dragged "
    "down by produce classes that are visually similar and genuinely hard to distinguish, not just "
    "for the model but often for a person looking at a photograph too. The packed products — which "
    "are the more commercially significant category in a real store — scored much higher, in some "
    "cases near-perfect."
),
577: (
    "The system currently requires a live internet connection for all detection and billing. When "
    "the Hugging Face Space goes idle after a period of inactivity, the first request takes "
    "noticeably longer while the container starts back up. For a real store environment this would "
    "need to be addressed."
),
578: (
    "The hardware setup works but is not polished enough for a production environment. The Arduino "
    "connects to the laptop over USB, which physically tethers the scale to wherever the laptop "
    "is sitting and limits placement flexibility."
),
580: (
    "Several directions stand out as natural next steps for the project."
),
582: (
    "The biggest gains in model accuracy would come from expanding the training dataset with more "
    "images captured in varied conditions. Scaling up to YOLOv8s or YOLOv8m would also be worth "
    "testing to see how much detection quality improves at the cost of slightly longer inference times."
),
584: (
    "Adding Bluetooth thermal printer support would complete the cashier experience. The receipt "
    "screen is already in place — printing it would just require wiring up a print job to a "
    "Bluetooth-connected thermal printer."
),
586: (
    "Integrating a local payment gateway like JazzCash or EasyPaisa would make VisionPay genuinely "
    "deployable in a real store. The simplest path would be generating a QR code on the receipt "
    "screen that links directly to a payment request."
),
588: (
    "The current deployment uses SQLite stored inside the container, which means the database "
    "resets whenever Hugging Face restarts the Space. Migrating to a cloud database like Supabase "
    "would solve this and provide persistent transaction history across restarts."
),
590: (
    "Replacing the Arduino Uno with an ESP32 would eliminate the USB cable requirement entirely. "
    "The ESP32 can communicate over Wi-Fi, which would let the scale be positioned wherever makes "
    "most sense on the counter without being tethered to the laptop."
),
592: (
    "Supporting multiple camera inputs would make conveyor-belt style checkout possible, which is "
    "the obvious next step beyond a single-counter prototype."
),
594: (
    "The stock alert functionality in the manager dashboard lays groundwork for a fuller inventory "
    "management system. Adding automated reorder triggers and supplier contact integration would "
    "extend VisionPay from a billing tool into something closer to a full store management platform."
),
596: (
    "The clearest lesson from this project is that building a functional AI billing system does "
    "not require significant investment. A smartphone camera, a free cloud hosting account, and "
    "an inexpensive load cell were all the physical resources needed to produce something that "
    "works in practice."
),
597: (
    "All the primary objectives were met and the prototype provides a solid base for further "
    "development. With a larger training dataset, a persistent cloud database, and payment gateway "
    "integration, there is a real path to making VisionPay commercially viable in the Pakistani "
    "retail market. This work also adds to the growing body of research on AI-driven retail "
    "automation in developing countries, where the ability to deliver meaningful automation within "
    "tight cost constraints is what determines whether a system is actually adopted."
),

}  # end REPLACEMENTS


def set_paragraph_text(para, new_text):
    """Replace all runs in a paragraph with a single run containing new_text.
    Preserves paragraph-level formatting (pPr). Copies rPr from first run if available."""
    p = para._p
    W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

    # Grab first run's rPr (character formatting) before clearing
    first_run_rPr = None
    runs = p.findall(f'{{{W}}}r')
    if runs:
        rPr = runs[0].find(f'{{{W}}}rPr')
        if rPr is not None:
            first_run_rPr = copy.deepcopy(rPr)

    # Remove all runs, hyperlinks, and field elements
    for tag in [f'{{{W}}}r', f'{{{W}}}hyperlink', f'{{{W}}}fldSimple',
                f'{{{W}}}bookmarkStart', f'{{{W}}}bookmarkEnd',
                f'{{{W}}}proofErr']:
        for el in p.findall(tag):
            p.remove(el)

    # Build new run
    r = OxmlElement('w:r')
    if first_run_rPr is not None:
        r.append(first_run_rPr)

    t = OxmlElement('w:t')
    XML_NS = 'http://www.w3.org/XML/1998/namespace'
    t.set(f'{{{XML_NS}}}space', 'preserve')
    t.text = new_text
    r.append(t)
    p.append(r)


# ── Apply replacements ───────────────────────────────────────────────────────
doc = Document(INPUT)
paras = doc.paragraphs

applied = 0
for idx, new_text in REPLACEMENTS.items():
    if idx >= len(paras):
        print(f"[SKIP] index {idx} out of range ({len(paras)} paras)")
        continue
    para = paras[idx]
    style = para.style.name
    if style != 'Normal':
        print(f"[WARN] index {idx} style is '{style}', expected Normal — skipping")
        continue
    old_preview = para.text[:60].replace('\n', ' ')
    set_paragraph_text(para, new_text)
    print(f"[OK] {idx:3d} | {old_preview[:55]}")
    applied += 1

print(f"\nReplaced {applied} paragraphs.")
doc.save(OUTPUT)
print(f"Saved: {OUTPUT}")
