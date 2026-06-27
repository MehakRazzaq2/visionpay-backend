#!/usr/bin/env python3
"""
Fix blank pages and references in FYP Report - Final-numbered.docx
"""
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

W      = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
XML_NS = 'http://www.w3.org/XML/1998/namespace'

INPUT  = 'Documentation/FYP Report - Final-numbered.docx'
OUTPUT = 'Documentation/FYP Report - Final-clean.docx'

doc  = Document(INPUT)
body = doc.element.body

def get_text(e):
    return ''.join((t.text or '') for t in e.findall(f'.//{{{W}}}t'))

def has_sect(e):
    return e.find(f'{{{W}}}pPr/{{{W}}}sectPr') is not None

def is_blank(e):
    return e.tag == f'{{{W}}}p' and not get_text(e).strip()

# ================================================================
# TASK 1 — REMOVE BLANK PAGES
# ================================================================

# ── 1a: Remove spurious empty-SECT paragraphs after Chapter 3 title ──────
# Chapter 3 title paragraph has SECT and contains "Chapter 3"
children = list(body)
ch3_idx = next(
    i for i, c in enumerate(children)
    if c.tag == f'{{{W}}}p' and 'Chapter 3' in get_text(c) and has_sect(c)
)
spurious = []
j = ch3_idx + 1
while j < len(children):
    c = children[j]
    if c.tag == f'{{{W}}}p' and is_blank(c) and has_sect(c):
        spurious.append(c)
        j += 1
    else:
        break
for s in spurious:
    body.remove(s)
print(f"[1a] Removed {len(spurious)} spurious empty sections after Ch3 title")

# ── 1b: Remove runs of 3+ blank paragraphs immediately before a SECT para ─
# (only in chapter content areas; skip the first 120 body children = title/front matter)
changed = True
while changed:
    children = list(body)
    changed = False
    for i in range(120, len(children)):
        c = children[i]
        if not (c.tag == f'{{{W}}}p' and has_sect(c)):
            continue
        # count consecutive blanks before this SECT para
        j = i - 1
        blanks = []
        while j >= 0 and is_blank(children[j]) and not has_sect(children[j]):
            blanks.append(children[j])
            j -= 1
        if len(blanks) >= 3:
            for b in blanks:
                body.remove(b)
            print(f"[1b] Removed {len(blanks)} blank paras before SECT at body[{i}]")
            changed = True
            break   # restart after any removal

# ── 1c: Reduce large blank blocks (5+) to 1 inside chapter content ─────────
# Handles the 5-9 blank para clusters in Ch4 use-case area and Ch6/7
changed = True
while changed:
    children = list(body)
    changed = False
    i = 0
    while i < len(children):
        if is_blank(children[i]) and not has_sect(children[i]):
            j = i
            while j < len(children) and is_blank(children[j]) and not has_sect(children[j]):
                j += 1
            count = j - i
            if count >= 5:
                to_del = [children[k] for k in range(i + 1, j)]  # keep children[i], del rest
                for d in to_del:
                    body.remove(d)
                print(f"[1c] Reduced {count} blanks to 1  at body[{i}]")
                changed = True
                break
        i += 1

# ── 1d: Reduce remaining 3-4 blank blocks to 1 ───────────────────────────
changed = True
while changed:
    children = list(body)
    changed = False
    i = 0
    while i < len(children):
        if is_blank(children[i]) and not has_sect(children[i]):
            j = i
            while j < len(children) and is_blank(children[j]) and not has_sect(children[j]):
                j += 1
            count = j - i
            if count >= 3:
                to_del = [children[k] for k in range(i + 1, j)]
                for d in to_del:
                    body.remove(d)
                print(f"[1d] Reduced {count} blanks to 1  at body[{i}]")
                changed = True
                break
        i += 1

# ================================================================
# TASK 2 — FIX REFERENCES
# ================================================================

children = list(body)

# Find "References" heading paragraph
ref_idx = next(
    i for i, c in enumerate(children)
    if c.tag == f'{{{W}}}p' and get_text(c).strip() == 'References'
)
print(f"[2] References heading at body[{ref_idx}]")

# The body-level <w:sectPr> is the very last child of <w:body>
body_list = list(body)
body_sectPr = body_list[-1]
assert body_sectPr.tag == f'{{{W}}}sectPr', \
    f"Expected body sectPr last, got: {body_sectPr.tag}"
body_sectPr_idx = len(body_list) - 1

# Remove everything between ref heading and body-level sectPr
to_remove = [body_list[i] for i in range(ref_idx + 1, body_sectPr_idx)]
for elem in to_remove:
    body.remove(elem)
print(f"[2] Removed {len(to_remove)} old reference / trailing paragraphs")

# Helper: build a properly formatted reference paragraph
def make_ref_para(text):
    p = OxmlElement('w:p')

    # Paragraph properties
    pPr = OxmlElement('w:pPr')

    # Justified alignment
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'both')
    pPr.append(jc)

    # 1.5 line spacing, no extra space after
    spacing = OxmlElement('w:spacing')
    spacing.set(qn('w:line'), '360')       # 240 * 1.5 = 360 twips
    spacing.set(qn('w:lineRule'), 'auto')
    spacing.set(qn('w:after'), '120')      # small gap between references
    pPr.append(spacing)

    # Hanging indent: 0.5 inch (720 twips)
    ind = OxmlElement('w:ind')
    ind.set(qn('w:left'), '720')
    ind.set(qn('w:hanging'), '720')
    pPr.append(ind)

    p.append(pPr)

    # Run with Times New Roman 12pt
    r = OxmlElement('w:r')

    rPr = OxmlElement('w:rPr')
    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'),  'Times New Roman')
    rFonts.set(qn('w:hAnsi'), 'Times New Roman')
    rFonts.set(qn('w:cs'),    'Times New Roman')
    rPr.append(rFonts)

    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), '24')          # 24 half-points = 12 pt
    rPr.append(sz)
    szCs = OxmlElement('w:szCs')
    szCs.set(qn('w:val'), '24')
    rPr.append(szCs)

    r.append(rPr)

    t_el = OxmlElement('w:t')
    t_el.set(f'{{{XML_NS}}}space', 'preserve')
    t_el.text = text
    r.append(t_el)
    p.append(r)

    return p

REFS = [
    (
        "[1] Oishi, S. K., Islam, M. M., Rony, S. D., Khan, R. S., Rahman, M. M., & Ahmmed, M. "
        "(2026). Enhancing Retail Checkout Efficiency Through a Hybrid YOLOv8-Based Grocery "
        "Detection and Billing System. Frontiers in Computer Science and Artificial Intelligence. "
        "https://doi.org/10.32996/jcsts.2026.5.5.6"
    ),
    (
        "[2] Tan, L., Liu, S., Gao, J., Liu, X., Chu, L., & Jiang, H. (2024). Improved YOLOv10 "
        "for Enhanced Self-Checkout System in Retail. Journal of Imaging, 10(10), 248. "
        "https://doi.org/10.3390/jimaging10100248"
    ),
    (
        "[3] Amazon Go. (n.d.). Just Walk Out Technology. Amazon. Retrieved 2026, from "
        "https://www.amazon.com/b?node=16008589011"
    ),
]

# Insert before the body-level sectPr (which is now at the very end)
insert_pos = len(list(body)) - 1   # just before final sectPr
for ref_text in REFS:
    p = make_ref_para(ref_text)
    body.insert(insert_pos, p)
    insert_pos += 1

print(f"[2] Added {len(REFS)} formatted references")

# ================================================================
# SAVE
# ================================================================
doc.save(OUTPUT)
print(f"Saved: {OUTPUT}")
