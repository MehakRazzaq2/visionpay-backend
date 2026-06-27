"""Verify the fixes applied to FYP Report - Copy.docx"""
from docx import Document
import re

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

print("=== CHAPTER 6 TITLE PAGE AREA ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    if "TESTING AND EVALUATION" in t or "6.1" in t or "6.2" in t:
        # check pageBreakBefore
        has_pb = 'w:pageBreakBefore' in p._element.xml
        print(f"[{i:3}] style='{p.style.name}' pb={has_pb} | '{t[:60]}'")
        if "6.2" in t:
            break

print("\n=== CHAPTER 5 HEADINGS ===")
ch5_pat = re.compile(r'^5\.\d')
for i, p in enumerate(paras):
    t = p.text.strip()
    if ch5_pat.match(t):
        print(f"[{i:3}] style='{p.style.name}' | '{t[:60]}'")

print("\n=== CHAPTER 6 HEADINGS ===")
ch6_pat = re.compile(r'^6\.\d')
for i, p in enumerate(paras):
    t = p.text.strip()
    if ch6_pat.match(t):
        print(f"[{i:3}] style='{p.style.name}' | '{t[:60]}'")

print("\n=== TABLE CAPTIONS in Ch5/Ch6 ===")
cap_pat = re.compile(r'^Table [56]\.\d+:')
for i, p in enumerate(paras):
    t = p.text.strip()
    if cap_pat.match(t):
        print(f"[{i:3}] style='{p.style.name}' | '{t[:60]}'")

print("\n=== LIST OF TABLES (last 25 entries) ===")
lot_entries = [(i,p) for i,p in enumerate(paras) if p.style.name == 'table of figures']
for i, p in lot_entries[-25:]:
    print(f"[{i:3}] '{p.text.strip()[:70]}'")

print(f"\nTotal LOT entries: {len(lot_entries)}")
