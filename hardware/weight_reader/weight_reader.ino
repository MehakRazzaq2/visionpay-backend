#include <HX711.h>

#define DOUT 3
#define CLK  2

HX711 scale;
float calibrationFactor = 420;

void setup() {
  Serial.begin(9600);
  scale.begin(DOUT, CLK);
  delay(2000);
  scale.tare();
  Serial.println("=== VisionPay Weight Scale ===");
  Serial.println("Tare complete!");
  Serial.println("Commands: + increase | - decrease | T = tare");
}

void loop() {
  scale.set_scale(calibrationFactor);

  float weight = scale.get_units(10);
  long rawVal  = scale.read_average(3);

  Serial.print("WEIGHT:");
  Serial.println(weight, 1);

  Serial.print("  RAW:");
  Serial.print(rawVal);
  Serial.print(" | CAL:");
  Serial.println(calibrationFactor, 1);

  while (Serial.available()) {
    char c = Serial.read();
    if (c == '+') { calibrationFactor += 50;  Serial.print("CAL UP: ");   Serial.println(calibrationFactor); }
    if (c == '-') { calibrationFactor -= 50;  Serial.print("CAL DOWN: "); Serial.println(calibrationFactor); }
    if (c == 'T' || c == 't') { scale.tare(); Serial.println("Tared!"); }
  }

  delay(500);
}