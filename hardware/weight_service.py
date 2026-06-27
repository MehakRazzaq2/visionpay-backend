import serial
import threading
import time
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# ── Config ────────────────────────────────────────────────────────────────────
ARDUINO_PORT = "COM3"    # Change to your actual port (check Device Manager)
BAUD_RATE    = 9600
HOST         = "0.0.0.0"
PORT         = 8001

# ── State ─────────────────────────────────────────────────────────────────────
current_weight = 0.0
arduino_connected = False
lock = threading.Lock()

# ── Serial Reader Thread ───────────────────────────────────────────────────────
def read_serial():
    global current_weight, arduino_connected
    while True:
        try:
            ser = serial.Serial(ARDUINO_PORT, BAUD_RATE, timeout=2)
            print(f"Arduino connected on {ARDUINO_PORT}")
            arduino_connected = True

            while True:
                line = ser.readline().decode('utf-8').strip()
                if line.startswith("WEIGHT:"):
                    try:
                        val = float(line.split(":")[1])
                        with lock:
                            current_weight = val
                    except ValueError:
                        pass

        except Exception as e:
            arduino_connected = False
            print(f"Serial error: {e} — retrying in 3s...")
            time.sleep(3)

# ── FastAPI ───────────────────────────────────────────────────────────────────
app = FastAPI(title="VisionPay Weight Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/weight")
def get_weight():
    with lock:
        w = current_weight
    return {
        "weight_kg": round(w / 1000, 3),   # grams → kg
        "weight_g": round(w, 1),
        "connected": arduino_connected
    }

@app.get("/health")
def health():
    return {"status": "ok", "arduino": arduino_connected}

# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    t = threading.Thread(target=read_serial, daemon=True)
    t.start()
    print(f"Weight service starting on http://{HOST}:{PORT}")
    uvicorn.run(app, host=HOST, port=PORT)
