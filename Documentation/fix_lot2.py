"""Fix the wrongly-styled List of Tables entries (Normal -> table of figures)"""
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
paras = doc.paragraphs

# LOT entries have format: "Table 5.1 Name\t—" (with tab, NO colon after number)
# Captions have format:    "Table 5.1: Name"   (WITH colon after number)
# We want to fix entries that are in front matter section (before Chapter 5)

lot_entry_re = re.compile(r'^Table [56]\.\d+ \w')  # "Table 5.1 Development..." (no colon)

ch5_start_idx = None
for i, p in enumerate(paras):
    if p.text.strip() == "Chapter 5":
        ch5_start_idx = i
        break

tof_style = doc.styles['table of figures']
fixed = 0

for i, p in enumerate(paras):
    if i >= ch5_start_idx:
        break  # only fix entries in front matter (before chapter 5)
    t = p.text.strip()
    if lot_entry_re.match(t) and p.style.name != 'table of figures':
        p.style = tof_style
        fixed += 1
        print(f"  Fixed [{i}]: '{t[:60]}'")

print(f"\nFixed {fixed} LOT entries")

# Verify: show all LOT entries now
lot_entries = [(i, p) for i, p in enumerate(paras) if p.style.name == 'table of figures']
print(f"\nTotal LOT entries after fix: {len(lot_entries)}")
print("Last 20:")
for i, p in lot_entries[-20:]:
    print(f"  [{i}] '{p.text.strip()[:70]}'")

doc.save(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
print("\nSaved.")
