"""Show all Normal body paragraphs from Ch1-4"""
from docx import Document

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

ch5_start = None
for i, p in enumerate(paras):
    if p.text.strip() == "Chapter 5":
        ch5_start = i
        break

print(f"Ch5 starts at {ch5_start}\n")

for i, p in enumerate(paras):
    if i >= ch5_start:
        break
    t = p.text.strip()
    if not t or len(t) < 40:
        continue
    if p.style.name not in ('Normal',):
        continue
    # skip bold (headings stored as normal)
    runs = [r for r in p.runs if r.text.strip()]
    is_bold = all(r.bold for r in runs) if runs else False
    if is_bold:
        continue
    print(f"[{i:3}] {t[:120]}")
    print()
