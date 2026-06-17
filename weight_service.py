"""
VisionPay Weight Service — runs on laptop, port 8001
Reads Arduino serial and exposes /weight + /weight/tare over HTTP.
Start: python weight_service.py
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import serial
import serial.tools.list_ports
import threading
import time
import os

app = FastAPI(title="VisionPay Weight Service")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

_weight_g = 0.0
_scale_connected = False
_weight_lock = threading.Lock()
_arduino_serial = None


def _find_arduino_port():
    for p in serial.tools.list_ports.comports():
        desc = p.description or ''
        if any(k in desc for k in ('Arduino', 'CH340', 'USB Serial', 'USB-SERIAL')):
            print(f"Auto-detected Arduino on {p.device} ({desc})")
            return p.device
    fallback = os.environ.get("ARDUINO_PORT", "COM3")
    print(f"No Arduino found by name — trying {fallback}")
    return fallback


def _read_loop():
    global _weight_g, _scale_connected, _arduino_serial
    while True:
        try:
            port = _find_arduino_port()
            _arduino_serial = serial.Serial(port, 9600, timeout=2)
            print(f"Arduino connected on {port} ✅")
            _scale_connected = True
            while True:
                line = _arduino_serial.readline().decode('utf-8', errors='ignore').strip()
                if line.startswith("WEIGHT:"):
                    try:
                        with _weight_lock:
                            _weight_g = float(line.split(":")[1])
                    except ValueError:
                        pass
        except Exception as e:
            _scale_connected = False
            _arduino_serial = None
            print(f"Arduino disconnected: {e} — retrying in 5s")
            time.sleep(5)


threading.Thread(target=_read_loop, daemon=True).start()


@app.get("/weight")
def get_weight():
    with _weight_lock:
        w = _weight_g
    return {
        "weight_g": round(w, 1),
        "weight_grams": round(w, 1),
        "weight_kg": round(w / 1000, 3),
        "stable": _scale_connected and w > 0,
        "connected": _scale_connected,
        "scale_connected": _scale_connected,
    }


@app.post("/weight/tare")
def tare_scale():
    global _arduino_serial
    try:
        if _arduino_serial and _arduino_serial.is_open:
            _arduino_serial.write(b'T\n')
            return {"status": "tared", "success": True}
        return {"status": "Arduino not connected", "success": False}
    except Exception as e:
        return {"status": str(e), "success": False}


@app.get("/")
def home():
    with _weight_lock:
        w = _weight_g
    return {
        "service": "VisionPay Weight Service",
        "scale_connected": _scale_connected,
        "current_weight_kg": round(w / 1000, 3),
    }


if __name__ == "__main__":
    import uvicorn
    print("Starting VisionPay Weight Service on port 8001...")
    uvicorn.run(app, host="0.0.0.0", port=8001)
