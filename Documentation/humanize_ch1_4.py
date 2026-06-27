"""
Humanize Ch1-4 body text - pattern replacements + targeted paragraph rewrites
Formatting stays untouched.
"""
import re
from docx import Document

DOC_PATH = r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx"
doc = Document(DOC_PATH)
paras = doc.paragraphs

# Ch5 starts here — only touch before this
ch5_start = None
for i, p in enumerate(paras):
    if p.text.strip() == "Chapter 5":
        ch5_start = i
        break

# ── Targeted paragraph rewrites ────────────────────────────────────────────
REWRITES = {

# Abstract
"Traditional grocery billing systems rely heavily on barcode scanning, which":
"Grocery stores in Pakistan still depend almost entirely on barcode scanning at the checkout counter. It works, but it slows things down — especially when barcodes are damaged or missing, and cashiers have to manually enter product codes during busy hours. This project, VisionPay, was built to tackle that exact problem using AI-based product detection instead of traditional scanning.",

# Ch1 body
"Grocery retailing is the most universal and vital retailing business in the":
"Grocery retail is one of the most common businesses in developing countries like Pakistan. Most stores are small to medium in size and still rely on manual or semi-manual billing methods. The technology gap between local stores and modern automated retail is quite wide, and the goal of this project was to start bridging that gap with something affordable and practical.",

"In a standard barcode-based system of billing, the cashier would need to":
"In a normal barcode setup, the cashier picks up each product, finds the barcode, holds it up to the scanner, and waits for the beep. If the barcode is torn, covered, or printed at an awkward angle, the scan fails and they have to type the code in manually. During peak hours this adds up and slows the entire checkout line.",

"Secondly, barcode systems require human involvement to a great extent and":
"Barcode scanning also depends heavily on the cashier being attentive and careful. Fatigue or distraction causes mis-scans and billing errors. In high-traffic stores during lunch or evening rushes, the pressure on cashiers leads to slower service and more mistakes.",

"The grocery retail market In Pakistan, most of the grocery retail markets":
"Most grocery stores in Pakistan are small family-run shops or mid-sized marts. They generally cannot afford the kind of automated billing technology that big international chains use. Even basic POS systems are not universal, and many stores still use pen-and-paper records or simple cash registers.",

"Cashier-less or fully automated retail system is usually an expensive system":
"Fully cashier-less stores like Amazon Go use hundreds of cameras and smart shelves packed with sensors. That kind of setup costs millions to install and maintain — completely out of reach for a local grocery store in Rawalpindi or Islamabad.",

"New methods of product identification in the retail system have been proposed":
"Computer vision research in recent years has opened up new ways to identify products without needing a printed barcode. Instead of scanning a label, the system looks at the product itself — its packaging design, brand logo, color, shape, and any text on the packaging. This approach, sometimes called implicit barcoding, is what VisionPay is built around.",

"Computer vision-based systems can help eliminate the use of conventional":
"When a camera-based system looks at a product's packaging, it can extract enough visual information to uniquely identify the item. For packaged goods like biscuits and snacks, this works very well. For loose produce like tomatoes or onions, the system can still detect what the item is and then rely on a weight scale to calculate the price.",

"The proposed project is called VisionPay and is a practical solution to the":
"VisionPay was designed with small local grocery stores in mind. A cashier points a phone camera at the products on the counter, the system detects what they are, looks up the prices in a database, and builds the bill automatically — no barcode scanning needed.",

"The system will help enhance billing accuracy, minimize the time at the":
"The goal is to make checkout faster and less dependent on manual effort. The system handles detection and pricing automatically, so the cashier's job becomes confirming the items and processing the payment rather than manually scanning each product.",

"The main concern of this project is to build an intelligent billing system":
"This is a prototype-level project. The focus was on proving that the concept works — not on building a fully commercial product. The constraint was keeping hardware costs minimal so that even a small store owner could realistically consider adopting it.",

# Ch2 body
"The traditional retail billing systems are more so founded on the explicit":
"Traditional billing in retail is built around explicit barcodes. Every product has a printed barcode that maps to an entry in the store's system, and checkout means scanning each one individually. It is simple and it works, but it does not scale well and falls apart the moment a barcode is missing or unreadable.",

"Under the traditional barcode billing, the cashier or the customer has to":
"In a standard barcode checkout, every single item has to be scanned one at a time. If there are ten items in a basket, that is ten scans, ten potential scan failures, and ten opportunities for an error. When the store is busy, this slows everything down considerably.",

"Because of these restrictions, recent studies have turned to automated and":
"These limitations pushed researchers to look for smarter approaches. AI-based billing, vision systems, and sensor fusion are some of the directions that have been explored in recent years.",

"These disadvantages underscore the necessity of barcode-less or implicit":
"All of these drawbacks make a strong case for moving away from physical barcodes, at least in smaller retail settings where the cost of a full smart-store setup is not realistic.",

"The aim of the research is the automated billing system with the deep":
"The research objective was to build an automated billing system that does not need barcodes. Instead, it uses a camera and deep learning to figure out what each product is and generate the bill automatically.",

"This study shows the possibility of barcode-free billing, however, it is":
"The study did prove that barcode-free billing is possible, but the system was too narrow for real-world use. It only worked from specific camera angles and struggled with products that looked similar to each other.",

"ARC proposes a vision-based retail checkout system that removes the":
"ARC attempted to replace the traditional checkout entirely using computer vision. Multiple cameras captured the products from different angles and a deep learning model handled the recognition and billing.",

"Although ARC enhances automation, it is still reliant on the optimal":
"ARC was an improvement over barcode-only systems, but it still needed everything to be set up just right — correct lighting, fixed camera positions, no clutter. Real stores are messier than that.",

"Amazon Go is a fully automated retail design based on a Just Walk Out":
"Amazon Go is probably the most well-known example of cashier-less retail. Customers walk in, pick up what they want, and walk out. The system tracks everything using ceiling cameras, shelf sensors, and computer vision running on cloud servers.",

"In spite of Amazon Go being almost perfect automation, it cannot be":
"Amazon Go is impressive but impractical for most of the world. The cost of installing and maintaining that kind of infrastructure makes it viable only for large retailers with massive technology budgets. It is not a model that a small grocery store in Pakistan could ever adopt.",

"In accordance with the literature review and systems presently in place,":
"After reviewing the available research and existing systems, several clear gaps stand out.",

"A product that is identified by implicit barcoding is one that is not marked":
"Implicit barcoding means identifying a product through its own physical features rather than a printed label. Things like the packaging color, brand logo, shape, and any text on the wrapper act as a kind of virtual identity that the system can learn to recognize.",

"The models of computer vision and deep learning applied to extract":
"Deep learning models trained on product images can pick up on these visual features and match them to known products in a database. This makes the identification process automatic and does not require any special label to be attached to the product.",

"This is especially useful when dealing with grocery products that look alike":
"This matters a lot in grocery retail where many products look similar — different brands of rice, flour, or sugar, for example. A well-trained model can tell them apart based on subtle packaging differences that a barcode system would simply not care about.",

"VisionPay surpasses these constraints by offering a smart billing system":
"VisionPay was designed to address all of these gaps. It does not need expensive infrastructure, it can work with a mobile phone camera, and it adds weight validation for produce items that cannot be identified by packaging alone.",

"In contrast to Amazon Go, VisionPay does not require heavy infrastructure":
"Unlike Amazon Go, VisionPay does not need ceiling cameras, smart shelves, or a dedicated server room. A phone, a free cloud account, and a basic load cell is all the hardware required.",

# Ch3 body
"To create a smart, workable, and scalable smart billing solution, it is":
"Before designing VisionPay, we looked at what currently exists in automated retail billing and where each approach falls short. This review shaped the decisions we made about which technologies to use and which problems to prioritize.",

"Retail billing systems are very important in enhancing a smooth customer":
"Billing is one of the most visible parts of the shopping experience. Slow or error-prone checkout affects customer satisfaction and store efficiency equally. Improvements in this area have a direct and measurable impact on how a store operates.",

"As the artificial intelligence and smart retail ideas develop, automated":
"As AI has matured, smart billing systems have followed. The research space has moved from simple barcode alternatives toward full computer vision pipelines that can handle product recognition, weight validation, and payment in one flow.",

"The retail billing method is the most common method of billing that uses":
"Barcode-based billing is still the dominant approach. It is cheap, reliable under normal conditions, and well-understood. But it requires every item to have an intact, visible barcode and a cashier willing to scan it correctly.",

"Such constraints drive the desire of barcode-less or smart billing strategies.":
"These limitations are exactly why there is growing interest in smarter alternatives.",

"Vision-based billing systems are computer vision-based and deep learning-based":
"Vision-based systems use cameras and deep learning to identify products without any physical label. The camera captures the item, the model predicts what it is, and the system handles the rest. It removes the need for manual scanning entirely.",

"OCR also adds value to vision-based systems by adding a confirmation of":
"OCR is useful as a secondary check. If the model identifies a product and OCR confirms the brand name on the packaging matches what was expected, confidence in the result goes up. It works especially well for packaged goods where the text on the label is clear.",

"Sensors fusion, including: are used by advanced retail systems, like Amazon Go.":
"Advanced systems like Amazon Go combine multiple sensor types — cameras from multiple angles, smart shelves with built-in weight sensors, and cloud-based processing — to achieve near-perfect tracking. The tradeoff is enormous cost and complexity.",

"These systems are very costly, complicated and should not be used in small":
"Systems that rely on sensor fusion are accurate but require substantial investment. They make sense for high-revenue retailers but are not practical for the local grocery store context this project targets.",

"In spite of the improvements, automated billing systems have a number of":
"Despite progress in the field, most automated billing systems still have practical problems that limit their adoption.",

"A number of solutions have been suggested to counter these challenges:":
"Researchers have proposed several approaches to address these challenges, each with its own trade-offs.",

"These methods either undermine cheapness, precision or size.":
"Each of these approaches gives up something — either accuracy, cost, or scalability.",

"VisionPay suggests hybrid intelligent billing system, which combines both":
"VisionPay takes a hybrid approach. It combines computer vision for product identification with a physical load cell for weight validation, backed by a cloud-deployed API and a cross-platform mobile application.",

"This is an effective combination of a strong, affordable and smart billing":
"The combination keeps hardware costs minimal while still delivering meaningful automation. That balance is what makes it a practical option for the small store setting.",

"The Implicit barcoding is a technology that does not require physical":
"Implicit barcoding treats the product's own visual characteristics as its identifier. The system learns what each product looks like and uses that knowledge during detection instead of relying on any printed label.",

"Implicit barcoding especially works well with grocery products whose":
"This approach works particularly well for packaged grocery products whose branding and packaging design are distinctive enough to tell apart. CocoMo biscuits and Lays chips, for example, have very specific color schemes and logo placements that make them easy to identify even from a phone camera.",

"This chapter has talked about the current methods of retail billing, the":
"This chapter reviewed the existing approaches to retail billing, looked at where each one falls short, and explained how VisionPay addresses those gaps. The next chapter covers the system design in detail.",

# Ch4 body
"In this chapter the design, functions and operations are described in detail.":
"Chapter 4 covers the design of VisionPay — how the system is structured, how the components interact, and how the main workflows are laid out. The design phase came before any actual development and shaped all the implementation decisions that followed.",

"The Use Case Diagram illustrates the functional behavior of the VisionPay":
"The use case diagram maps out what each actor in the system can do. VisionPay has three main actors — the Customer, the Store Admin, and the AI Engine — and the diagram shows how their responsibilities overlap and connect.",

"In this section, all the major use cases of the VisionPay system are":
"Each major use case is described in detail below. The tables cover what triggers the use case, what the system does in response, and what happens if something goes wrong.",

"Activity diagrams shows the flow of control and how actions are taking":
"Activity diagrams trace the sequence of actions through each workflow. They are useful for showing decision points — places where the system branches based on input or detection results.",

"This activity diagram illustrates the complete customer billing workflow in":
"This diagram follows the billing process from the moment a product is placed on the counter to the point where the receipt is generated. It shows where the AI detection step fits in and what happens if a product is not recognized.",

"This activity diagram represents the internal working of the VisionPay AI":
"This diagram zooms in on the AI engine's processing flow. It shows how a captured image moves through YOLO detection, confidence filtering, database lookup, and finally price retrieval.",

"This activity diagram describes the role of the store administrator in":
"This diagram covers what the store admin can do within the system — reviewing sales data, checking inventory, adding or removing products, and responding to stock alerts.",

"It focuses on system supervision tasks such as viewing sales reports,":
"The admin's tasks are mostly supervisory — they monitor how the system is performing and make adjustments to the product catalogue and stock levels as needed.",

"A Class Diagram helps to determine the static relations between objects.":
"The class diagram shows the main components of the system and how they relate to each other. It covers the ProductDatabase, DecisionEngine, BillingEngine, and the main FastAPI application class.",

"The sequence diagram shows the interaction between the objects and the":
"Sequence diagrams show how the system components communicate with each other during a specific operation. They make it easier to understand the order of calls and responses during a billing transaction.",
}

# ── Apply targeted rewrites ────────────────────────────────────────────────
changed = 0
for i, p in enumerate(paras):
    if i >= ch5_start:
        break
    t = p.text.strip()
    if not t or len(t) < 30:
        continue
    if p.style.name not in ('Normal',):
        continue
    runs = [r for r in p.runs if r.text.strip()]
    if not runs:
        continue
    is_all_bold = all(r.bold for r in runs)
    if is_all_bold:
        continue

    for key, val in REWRITES.items():
        if t.startswith(key[:55]):
            first_run = p.runs[0]
            first_run.text = val
            for r in p.runs[1:]:
                r.text = ""
            changed += 1
            break

print(f"Rewrote {changed} paragraphs in Ch1-4")

# ── Pattern replacements ───────────────────────────────────────────────────
patterns = [
    (r'^Furthermore, ', ''),
    (r'^Moreover, ', ''),
    (r'^Additionally, ', 'Also, '),
    (r'^In addition, ', 'Also, '),
    (r'^It is worth noting that ', ''),
    (r'^It should be noted that ', ''),
    (r'^It is important to note that ', ''),
    (r'^In summary, this chapter', 'This chapter'),
    (r'^Overall, ', ''),
    (r'demonstrates that', 'shows that'),
    (r'demonstrates the', 'shows the'),
    (r'\butilizes\b', 'uses'),
    (r'\butilize\b', 'use'),
    (r'\butilized\b', 'used'),
    (r'\bleverages\b', 'uses'),
    (r'\bleveraged\b', 'used'),
    (r'\bleveraging\b', 'using'),
    (r'\bfacilitates\b', 'helps'),
    (r'\bfacilitate\b', 'help'),
    (r'\bseamlessly\b', 'smoothly'),
    (r'\brobust\b', 'reliable'),
    (r'\bcomprehensive\b', 'complete'),
    (r'\bfunctionality\b', 'features'),
    (r'\beffectively\b', 'well'),
    (r'\bfeasibility\b', 'viability'),
    (r'in order to ', 'to '),
    (r'due to the fact that ', 'because '),
    (r'is designed to ', 'is meant to '),
    (r'is responsible for ', 'handles '),
    (r'As can be seen', 'As shown'),
    (r'is illustrated', 'is shown'),
    (r'illustrates', 'shows'),
    (r'It can be observed that ', ''),
    (r'proposed system', 'system'),
    (r'proposed project', 'project'),
]

pat_changed = 0
for i, p in enumerate(paras):
    if i >= ch5_start:
        break
    if p.style.name not in ('Normal',):
        continue
    t = p.text.strip()
    if not t:
        continue
    runs = list(p.runs)
    if not runs:
        continue
    has_inline = any(r.bold or r.italic for r in runs if r.text.strip())
    if has_inline:
        continue
    full_text = p.text
    new_text = full_text
    for pat, repl in patterns:
        new_text = re.sub(pat, repl, new_text)
    if new_text != full_text:
        non_empty = [r for r in runs if r.text]
        if non_empty:
            non_empty[0].text = new_text
            for r in non_empty[1:]:
                r.text = ""
            pat_changed += 1

print(f"Pattern replacements: {pat_changed} paragraphs")

doc.save(DOC_PATH)
print(f"Saved: {DOC_PATH}")
