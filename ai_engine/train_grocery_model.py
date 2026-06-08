from ultralytics import YOLO
import os

print("=" * 50)
print("VisionPay - AI Training Module")
print("=" * 50)

# Use ABSOLUTE path (Windows style)
dataset_path = r"C:\Users\Mehak Razzaq\Desktop\VisionPay\dataset\raw\grocery_store\dataset"
print(f"Checking dataset at: {dataset_path}")

if not os.path.exists(dataset_path):
    print(f"ERROR: Dataset not found!")
    print(f"Looking at: {dataset_path}")
    
    # Let's see what's actually there
    raw_path = r"C:\Users\Mehak Razzaq\Desktop\VisionPay\dataset\raw"
    if os.path.exists(raw_path):
        print(f"\nFound in raw folder:")
        for item in os.listdir(raw_path):
            print(f"  - {item}")
    exit(1)

print(f"✓ Dataset found!")
print("Loading YOLOv8 classification model...")

# Load pretrained model
model = YOLO("yolov8n-cls.pt")

print("Starting training...")
print("Note: This will take 40-90 minutes on CPU")
print("=" * 50)

# Train the model
results = model.train(
    data=dataset_path,
    epochs=20,
    imgsz=224,
    batch=16,
    device="cpu",
    project="runs",
    name="visionpay_grocery"
)

print("=" * 50)
print("Training finished!")
print(f"Best model saved at: runs/visionpay_grocery/weights/best.pt")
print("=" * 50)

print("All done! 🎉")