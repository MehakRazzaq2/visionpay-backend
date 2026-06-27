# HX711 Calibration Guide

## Wiring
| HX711 Pin | Arduino Pin |
|-----------|-------------|
| VCC       | 5V          |
| GND       | GND         |
| DT        | D3          |
| SCK       | D2          |

Load cell wires: Red→E+, Black→E−, White→A−, Green→A+

## Calibration Steps
1. Upload weight_reader.ino with `calibrationFactor = -7050.0`
2. Open Serial Monitor (9600 baud)
3. Send `T` → tare (zero out)
4. Place a known weight (e.g. 500g)
5. Note the reading shown
6. New factor = (current factor × known weight) / reading shown
7. Update calibrationFactor in .ino, re-upload, retest

## If weight reads negative → swap A+ and A− wires on HX711

## Troubleshooting
- `WEIGHT:0.00` always → check DT/SCK wiring
- Weight unstable → use `scale.get_units(10)` for more averaging
- Serial Monitor must be CLOSED before running weight_service.py
