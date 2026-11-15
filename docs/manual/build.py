"""Build a booklet PDF from a manual's Markdown source.

Usage:
    python docs/manual/build.py [source.md] [--html out.html] [--pdf out.pdf]

With no arguments it builds information-manager.md into
information-manager.pdf next to it. The PDF is printed by a headless
Chromium-family browser (Edge or Chrome). Set BROWSER to its path if it
is not found automatically.

The Markdown converter is deliberately small so the build needs nothing
beyond the standard library. It understands: # and ## headings,
paragraphs, - and 1. lists, pipe tables, > notes, ``` fences (```screen
draws a TV screen), `code`, **bold**, and raw HTML lines (any line that
starts with "<" passes through untouched).
"""

import argparse
import html
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent


def inline(text):
    """Convert inline Markdown. Raw HTML tags are passed through."""
    codes = []

    def keep_code(m):
        codes.append("<code>" + html.escape(m.group(1)) + "</code>")
        return "\x00%d\x00" % (len(codes) - 1)

    text = re.sub(r"`([^`]+)`", keep_code, text)
    text = text.replace("&", "&amp;").replace("&amp;nbsp;", "&nbsp;")
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    return re.sub(r"\x00(\d+)\x00", lambda m: codes[int(m.group(1))], text)


def split_row(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def convert(md):
    lines = md.splitlines()
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        s = line.strip()
        if not s:
            i += 1
        elif s.startswith("```"):
            kind = s[3:].strip()
            i += 1
            body = []
            while i < n and not lines[i].strip().startswith("```"):
                body.append(lines[i])
                i += 1
            i += 1
            cls = ' class="screen"' if kind == "screen" else ""
            out.append("<pre%s><code>%s</code></pre>"
                       % (cls, html.escape("\n".join(body))))
        elif s.startswith("<"):
            out.append(line)
            i += 1
        elif s.startswith("# "):
            t = inline(s[2:])
            out.append('<h1><span class="tab">%s</span>%s</h1>' % (t, t))
            i += 1
        elif s.startswith("## "):
            out.append("<h2>%s</h2>" % inline(s[3:]))
            i += 1
        elif s.startswith("|"):
            rows = []
            while i < n and lines[i].strip().startswith("|"):
                rows.append(split_row(lines[i]))
                i += 1
            head, body = rows[0], rows[2:]
            t = ["<table><thead><tr>"]
            t += ["<th>%s</th>" % inline(c) for c in head]
            t.append("</tr></thead><tbody>")
            for r in body:
                t.append("<tr>" + "".join("<td>%s</td>" % inline(c)
                                          for c in r) + "</tr>")
            t.append("</tbody></table>")
            out.append("".join(t))
        elif s.startswith(">"):
            body = []
            while i < n and lines[i].strip().startswith(">"):
                body.append(lines[i].strip()[1:].strip())
                i += 1
            out.append('<aside class="note"><p>%s</p></aside>'
                       % inline(" ".join(body)))
        elif re.match(r"(-|\d+\.) ", s):
            ordered = s[0].isdigit()
            items = []
            while i < n and re.match(r"(-|\d+\.) ", lines[i].strip()):
                items.append(re.sub(r"^(-|\d+\.) ", "", lines[i].strip()))
                i += 1
            tag = "ol" if ordered else "ul"
            out.append("<%s>%s</%s>" % (tag, "".join(
                "<li>%s</li>" % inline(x) for x in items), tag))
        else:
            para = []
            while i < n and lines[i].strip() and not re.match(
                    r"(#|\||>|```|<|- |\d+\. )", lines[i].strip()):
                para.append(lines[i].strip())
                i += 1
            out.append("<p>%s</p>" % inline(" ".join(para)))
    return "\n".join(out)


def find_browser():
    env = os.environ.get("BROWSER")
    if env:
        return env
    candidates = [
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    ]
    for c in candidates:
        if Path(c).exists():
            return c
    for name in ("msedge", "google-chrome", "chromium", "chrome"):
        p = shutil.which(name)
        if p:
            return p
    sys.exit("No Edge/Chrome found; set BROWSER to its path.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source", nargs="?",
                    default=str(HERE / "information-manager.md"))
    ap.add_argument("--html", help="also keep the HTML at this path")
    ap.add_argument("--pdf", help="PDF output path")
    args = ap.parse_args()

    src = Path(args.source).resolve()
    pdf = Path(args.pdf).resolve() if args.pdf else src.with_suffix(".pdf")
    css = (HERE / "manual.css").read_text(encoding="utf-8")
    body = convert(src.read_text(encoding="utf-8"))
    title = src.stem.replace("-", " ").title()
    doc = ("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
           "<title>%s</title><style>%s</style></head><body>%s</body></html>"
           % (html.escape(title), css, body))

    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "manual.html"
        page.write_text(doc, encoding="utf-8")
        if args.html:
            Path(args.html).write_text(doc, encoding="utf-8")
        if pdf.exists():
            pdf.unlink()
        subprocess.run([
            find_browser(), "--headless", "--disable-gpu",
            "--no-pdf-header-footer", "--user-data-dir=" + tmp + "/profile",
            "--print-to-pdf=" + str(pdf), page.as_uri(),
        ], check=True, capture_output=True)
        # On Windows the Edge launcher can return before printing ends,
        # so wait until the PDF exists and its size has settled.
        last = -1
        for _ in range(120):
            size = pdf.stat().st_size if pdf.exists() else -1
            if size > 0 and size == last:
                break
            last = size
            time.sleep(0.5)
        else:
            sys.exit("Timed out waiting for " + str(pdf))
    print("wrote", pdf)


if __name__ == "__main__":
    main()
