
from ultralytics import YOLO

# Model load karo
model = YOLO(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\visionpay_best.pt")

print("Model loaded successfully!")
print(f"Total Classes: {len(model.names)}")
print(f"Sample classes: {list(model.names.values())[:5]}")

# Test image pe run karo
results = model.predict(
    source=r"C:\Users\Mehak Razzaq\Desktop\VisionPay\test.jpg",
    conf=0.25,
    show=True
)

for r in results:
    print(f"\nDetected {len(r.boxes)} objects:")
    for box in r.boxes:
        cls = int(box.cls)
        conf = float(box.conf)
        print(f"  → {model.names[cls]}: {conf:.2f}")