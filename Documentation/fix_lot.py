"""Fix List of Tables entries - find correct style ID and re-apply"""
from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

# First, find the XML style ID of the existing 'table of figures' entries
print("=== Existing LOT entry XML snippet ===")
for p in paras:
    if p.style.name == 'table of figures':
        # Get the pStyle value from XML
        xml = p._element.xml
        # Find w:pStyle w:val=
        import re
        m = re.search(r'<w:pStyle w:val="([^"]+)"', xml)
        if m:
            print(f"Style XML ID: '{m.group(1)}'")
        break

# Also list all available styles that contain 'figure' or 'table' in name
print("\n=== Styles with 'figure' or 'table' in name ===")
for s in doc.styles:
    if 'figure' in s.name.lower() or ('table' in s.name.lower() and 'grid' not in s.name.lower()):
        print(f"  name='{s.name}' type={s.type}")
