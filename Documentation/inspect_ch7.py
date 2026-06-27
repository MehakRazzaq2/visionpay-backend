"""Inspect Chapter 7 area in the document"""
from docx import Document
import re

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

# Find chapter 7 start
ch7_start = None
for i, p in enumerate(paras):
    if 'chapter 7' in p.text.strip().lower() or 'CHAPTER 7' in p.text.strip():
        ch7_start = i
        break

print(f"Chapter 7 starts at index: {ch7_start}")
if ch7_start:
    print("\n=== Chapter 7 area (all paras) ===")
    for i, p in enumerate(paras):
        if i < ch7_start - 5:
            continue
        if i > ch7_start + 80:
            break
        t = p.text.strip()
        has_pb = 'w:pageBreakBefore' in p._element.xml
        print(f"[{i:3}] style='{p.style.name}' pb={has_pb} | '{t[:70]}'")
