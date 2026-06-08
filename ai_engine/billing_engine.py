from datetime import datetime
import json

class BillingEngine:
    def __init__(self):
        self.tax_rate = 0.0  # Tax rate (0% default)
    
    def generate_bill(self, products):
        bill = {
            'bill_id': datetime.now().strftime("%Y%m%d%H%M%S"),
            'timestamp': datetime.now().strftime("%d-%m-%Y %H:%M:%S"),
            'items': [],
            'subtotal': 0,
            'tax': 0,
            'total': 0
        }
        
        for product in products:
            if product['weight_based']:
                weight = product.get('weight_kg', 0)
                price = product['price_per_kg'] * weight
                item = {
                    'name': product['name'],
                    'brand': product.get('brand', ''),
                    'type': 'weight_based',
                    'weight_kg': weight,
                    'price_per_kg': product['price_per_kg'],
                    'total_price': round(price, 2)
                }
            else:
                quantity = product.get('quantity', 1)
                price = product['price_per_unit'] * quantity
                item = {
                    'name': product['name'],
                    'brand': product.get('brand', ''),
                    'type': 'fixed_price',
                    'quantity': quantity,
                    'price_per_unit': product['price_per_unit'],
                    'total_price': round(price, 2)
                }
            
            bill['items'].append(item)
            bill['subtotal'] += item['total_price']
        
        bill['subtotal'] = round(bill['subtotal'], 2)
        bill['tax'] = round(bill['subtotal'] * self.tax_rate, 2)
        bill['total'] = round(bill['subtotal'] + bill['tax'], 2)
        
        return bill
    
    def print_receipt(self, bill):
        print("\n" + "="*40)
        print("       VISIONPAY RECEIPT")
        print("="*40)
        print(f"Bill ID: {bill['bill_id']}")
        print(f"Date: {bill['timestamp']}")
        print("-"*40)
        
        for item in bill['items']:
            print(f"\n{item['name']} ({item['brand']})")
            if item['type'] == 'weight_based':
                print(f"  {item['weight_kg']}kg x Rs.{item['price_per_kg']}/kg")
            else:
                print(f"  {item['quantity']} x Rs.{item['price_per_unit']}")
            print(f"  Subtotal: Rs.{item['total_price']}")
        
        print("\n" + "-"*40)
        print(f"Subtotal: Rs.{bill['subtotal']}")
        print(f"Tax: Rs.{bill['tax']}")
        print(f"TOTAL: Rs.{bill['total']}")
        print("="*40)
        print("   Thank you for shopping!")
        print("="*40)


if __name__ == "__main__":
    billing = BillingEngine()
    
    # Test products
    products = [
        {
            'name': 'Nestle Milk 1L',
            'brand': 'Nestle',
            'weight_based': False,
            'price_per_unit': 180,
            'quantity': 2
        },
        {
            'name': 'Seb (Apple)',
            'brand': 'Local',
            'weight_based': True,
            'price_per_kg': 200,
            'weight_kg': 0.5
        },
        {
            'name': 'Lays Chips',
            'brand': 'Lays',
            'weight_based': False,
            'price_per_unit': 50,
            'quantity': 1
        }
    ]
    
    bill = billing.generate_bill(products)
    billing.print_receipt(bill)