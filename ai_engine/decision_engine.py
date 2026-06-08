import sys
sys.path.append('backend')
from database import ProductDatabase


class DecisionEngine:
    def __init__(self, database):
        self.db = database
    
    def process_detected_products(self, detected_products):
        results = []
        
        for product in detected_products:
            class_name = product.get('class_name', '')
            ocr_data = product.get('ocr_data', {})
            
            db_product = self._find_product(class_name, ocr_data)
            
            if db_product:
                product_info = {
                    'id': db_product[0],
                    'name': db_product[1],
                    'brand': db_product[2],
                    'category': db_product[3],
                    'weight_based': bool(db_product[5]),
                    'price_per_unit': db_product[4],
                    'price_per_kg': db_product[6],
                    'unit': db_product[8],
                    'detected_class': class_name,
                    'status': 'weight_required' if db_product[5] else 'ready'
                }
            else:
                product_info = {
                    'name': class_name,
                    'brand': ocr_data.get('brand', 'Unknown') if ocr_data else 'Unknown',
                    'weight_based': False,
                    'price_per_unit': 0,
                    'status': 'not_found'
                }
            
            results.append(product_info)
        
        return results
    
    def _find_product(self, class_name, ocr_data):
        if ocr_data and ocr_data.get('brand'):
            result = self.db.get_product_by_name(ocr_data['brand'])
            if result:
                return result

        if ocr_data and ocr_data.get('product_name'):
            result = self.db.get_product_by_name(ocr_data['product_name'])
            if result:
                return result
        
        clean_name = class_name.split('_')[-1]
        result = self.db.get_product_by_name(clean_name)
        return result
    
    def calculate_price(self, product_info, weight_kg=None):
        if product_info['weight_based'] and weight_kg:
            price = product_info['price_per_kg'] * weight_kg
            return round(price, 2)
        else:
            return product_info['price_per_unit']
    
    def generate_bill(self, products_with_weights):
        bill = {
            'items': [],
            'subtotal': 0,
            'total': 0
        }
        
        for item in products_with_weights:
            price = self.calculate_price(item, item.get('weight_kg'))
            
            bill_item = {
                'name': item['name'],
                'brand': item.get('brand', ''),
                'quantity': item.get('quantity', 1),
                'weight': item.get('weight_kg'),
                'price': price,
                'subtotal': price * item.get('quantity', 1)
            }
            
            bill['items'].append(bill_item)
            bill['subtotal'] += bill_item['subtotal']
        
        bill['total'] = bill['subtotal']
        return bill


if __name__ == "__main__":
    db = ProductDatabase("visionpay.db")
    engine = DecisionEngine(db)
    
    detected = [
        {'class_name': 'Fruit_Apple', 'ocr_data': {'brand': 'Apple', 'weight': '1kg'}},
        {'class_name': '97_milk', 'ocr_data': {'brand': 'Nestle', 'product_name': 'Milk'}},
        {'class_name': 'Vegetables_Tomato', 'ocr_data': {'brand': 'Local'}},
    ]
    
    results = engine.process_detected_products(detected)
    
    print("=== Decision Engine Results ===")
    for r in results:
        print(f"\nProduct: {r['name']}")
        print(f"Status: {r['status']}")
        if r['weight_based']:
            print(f"→ WEIGHT REQUIRED (Load cell activate!)")
        else:
            print(f"→ Price: Rs.{r['price_per_unit']}")