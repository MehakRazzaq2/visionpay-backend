import easyocr
import re
import numpy as np
import cv2

class OCRModule:
    def __init__(self):
        print("Loading OCR model...")
        self.reader = easyocr.Reader(['en'], gpu=False)
        print("OCR ready!")
    
    def extract_text(self, image_input):
        # Path ya numpy array dono accept karo
        if isinstance(image_input, str):
            results = self.reader.readtext(image_input)
        elif isinstance(image_input, np.ndarray):
            results = self.reader.readtext(image_input)
        else:
            return None
            
        extracted = {
            'all_text': [],
            'brand': None,
            'product_name': None,
            'weight': None
        }
        
        for (bbox, text, confidence) in results:
            if confidence > 0.3:
                extracted['all_text'].append({
                    'text': text,
                    'confidence': round(confidence, 2)
                })
        
        full_text = ' '.join([t['text'] for t in extracted['all_text']])
        
        # Weight extract
        weight_pattern = r'\d+\s*(g|kg|ml|l|oz|lb|gm|GM|KG|ML|L)\b'
        weight_match = re.search(weight_pattern, full_text, re.IGNORECASE)
        if weight_match:
            extracted['weight'] = weight_match.group()
        
        # Product keywords
        product_keywords = [
            'toothpaste', 'rice', 'flour', 'sugar', 'salt', 'oil', 'milk',
            'juice', 'biscuit', 'chips', 'chocolate', 'soap', 'shampoo',
            'tea', 'coffee', 'butter', 'cream', 'powder', 'sauce', 'ketchup',
            'noodles', 'pasta', 'bread', 'biscuits', 'cookies', 'wafer',
            'atta', 'ghee', 'masala', 'spice', 'jam', 'honey', 'yogurt'
        ]
        
        for item in extracted['all_text']:
            text_lower = item['text'].lower()
            for keyword in product_keywords:
                if keyword in text_lower:
                    extracted['product_name'] = item['text']
                    break
            if extracted['product_name']:
                break
        
        if not extracted['product_name'] and len(extracted['all_text']) > 1:
            extracted['product_name'] = extracted['all_text'][1]['text']
        
        if extracted['all_text']:
            extracted['brand'] = extracted['all_text'][0]['text']
        
        return extracted

    def process_multiple_products(self, image_path, yolo_boxes):
        """Multiple products ke liye — har box ko crop karke OCR lagao"""
        image = cv2.imread(image_path)
        all_results = []
        
        for i, box in enumerate(yolo_boxes):
            x1, y1, x2, y2 = map(int, box)
            cropped = image[y1:y2, x1:x2]
            
            if cropped.size == 0:
                continue
                
            result = self.extract_text(cropped)
            result['product_id'] = i + 1
            all_results.append(result)
            
            print(f"\nProduct {i+1}:")
            print(f"  Brand: {result['brand']}")
            print(f"  Product: {result['product_name']}")
            print(f"  Weight: {result['weight']}")
        
        return all_results


if __name__ == "__main__":
    ocr = OCRModule()
    result = ocr.extract_text(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\test.jpg")
    
    print("\n=== OCR Results ===")
    print(f"Brand: {result['brand']}")
    print(f"Product: {result['product_name']}")
    print(f"Weight: {result['weight']}")
    print(f"\nAll text found:")
    for item in result['all_text']:
        print(f"  '{item['text']}' ({item['confidence']})")