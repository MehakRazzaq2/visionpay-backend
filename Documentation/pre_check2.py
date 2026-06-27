"""Show body elements in Ch5 tail area and Ch7 area to find missing table content"""
from docx import Document
from docx.oxml.ns import qn
import re

doc = Document(r"C:\Users\Mehak Razzaq\Desktop\VisionPay\Documentation\FYP Report - Copy.docx")
body = doc.element.body
children = list(body)

def get_text(el):
    parts = []
    for t in el.iter(qn('w:t')):
        if t.text:
            parts.append(t.text)
    return ''.join(parts).strip()

def get_style(el):
    s = el.find('.//' + qn('w:pStyle'))
    return s.get(qn('w:val'), '') if s is not None else 'Normal'

print("=== Body[815]-[840]: between last Ch5 table and Ch6 ===")
for idx in range(815, 842):
    el = children[idx]
    tag = el.tag.split('}')[-1] if '}' in el.tag else el.tag
    if tag == 'p':
        text = get_text(el)
        style = get_style(el)
        print(f"  body[{idx}] p style={style} | '{text[:80]}'")
    elif tag == 'tbl':
        rows = el.findall('.//' + qn('w:tr'))
        fc = get_text(rows[0].findall('.//' + qn('w:tc'))[0]) if rows else ''
        print(f"  body[{idx}] TABLE | rows={len(rows)} | first_cell='{fc}'")

print("\n=== Body[930]-[1008]: Ch7 area ===")
for idx in range(930, min(1009, len(children))):
    el = children[idx]
    tag = el.tag.split('}')[-1] if '}' in el.tag else el.tag
    if tag == 'p':
        text = get_text(el)
        style = get_style(el)
        if text or style not in ('Normal', ''):
            print(f"  body[{idx}] p style={style} | '{text[:80]}'")
    elif tag == 'tbl':
        rows = el.findall('.//' + qn('w:tr'))
        fc = get_text(rows[0].findall('.//' + qn('w:tc'))[0]) if rows else ''
        print(f"  body[{idx}] TABLE | rows={len(rows)} | first_cell='{fc}'")

print("\n=== Ch6 area between tables ===")
# Between body[858] (TABLE#24) and body[874] (TABLE#25) - looking for missing API table
print("Between TABLE#24 (6.1) and TABLE#25 (6.3):")
for idx in range(859, 874):
    el = children[idx]
    tag = el.tag.split('}')[-1] if '}' in el.tag else el.tag
    if tag == 'p':
        text = get_text(el)
        style = get_style(el)
        print(f"  body[{idx}] p style={style} | '{text[:80]}'")
    elif tag == 'tbl':
        rows = el.findall('.//' + qn('w:tr'))
        print(f"  body[{idx}] TABLE | rows={len(rows)}")

print("\nBetween TABLE#25 (6.3) and TABLE#26 (6.4):")
for idx in range(875, 893):
    el = children[idx]
    tag = el.tag.split('}')[-1] if '}' in el.tag else el.tag
    if tag == 'p':
        text = get_text(el)
        style = get_style(el)
        if text:
            print(f"  body[{idx}] p style={style} | '{text[:80]}'")
    elif tag == 'tbl':
        rows = el.findall('.//' + qn('w:tr'))
        print(f"  body[{idx}] TABLE | rows={len(rows)}")
