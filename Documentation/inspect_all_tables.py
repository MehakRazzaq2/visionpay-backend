"""Map every Caption paragraph to its chapter and show current numbering"""
from docx import Document
import re

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

# Track current chapter
chapter = 0
chapter_map = {}   # para_index -> chapter number

for i, p in enumerate(paras):
    t = p.text.strip()
    # Detect chapter boundaries
    if re.match(r'^CHAPTER\s+(\d)', t, re.I):
        m = re.match(r'^CHAPTER\s+(\d)', t, re.I)
        chapter = int(m.group(1))
    elif re.match(r'^Chapter\s+(\d)', t):
        m = re.match(r'^Chapter\s+(\d)', t)
        chapter = int(m.group(1))
    chapter_map[i] = chapter

# Print all Caption paragraphs with their chapter
print("=== ALL CAPTION PARAGRAPHS ===")
print(f"{'Idx':>4} {'Ch':>3}  {'Style':<12} Text")
print("-"*80)
for i, p in enumerate(paras):
    if p.style.name == 'Caption':
        t = p.text.strip()
        ch = chapter_map.get(i, 0)
        kind = "TABLE" if t.lower().startswith("table") else "FIGURE"
        print(f"[{i:3}] Ch{ch}  {p.style.name:<12} [{kind}] {t[:70]}")

# Also check for any table captions in Normal style in Ch2 area
print("\n=== NORMAL paragraphs that look like table captions (Ch2 area) ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    ch = chapter_map.get(i, 0)
    if ch == 2 and p.style.name == 'Normal' and ('table' in t.lower() or 'Table' in t):
        print(f"[{i:3}] Ch{ch}  '{t[:80]}'")

print("\n=== LOT entries currently ===")
for i, p in enumerate(paras):
    if p.style.name == 'table of figures':
        t = p.text.strip()
        if 'Table' in t:
            print(f"[{i:3}] '{t[:80]}'")
