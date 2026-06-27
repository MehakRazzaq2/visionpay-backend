"""Inspect FYP Report - Copy.docx structure"""
from docx import Document
from docx.oxml.ns import qn

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")

for i, p in enumerate(doc.paragraphs):
    style = p.style.name
    text = p.text.strip()
    if text:
        print(f"[{i:3}] Style='{style}' | {text[:100]}")
