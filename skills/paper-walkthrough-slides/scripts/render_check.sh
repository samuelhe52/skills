#!/bin/bash
# Render a paper-walkthrough deck and check it.
# Usage: render_check.sh <deck.html> [out-dir]   (default out-dir: ./tmp/render-<deck-name>)
# Prints KaTeX formula/error counts, prints the deck to PDF (one slide per page),
# rasterizes every page, and writes 2x2 contact sheets for visual review.
set -euo pipefail

deck="${1:?usage: render_check.sh <deck.html> [out-dir]}"
deck="$(cd "$(dirname "$deck")" && pwd)/$(basename "$deck")"
name="$(basename "$deck" .html)"
out="${2:-$PWD/tmp/render-$name}"
mkdir -p "$out"
out="$(cd "$out" && pwd)"

chrome=""
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "$(command -v google-chrome 2>/dev/null || true)" \
         "$(command -v chromium 2>/dev/null || true)" \
         "$(command -v chromium-browser 2>/dev/null || true)"; do
  if [ -n "$c" ] && [ -x "$c" ]; then chrome="$c"; break; fi
done
[ -n "$chrome" ] || { echo "ERROR: Chrome/Chromium not found" >&2; exit 2; }
for t in pdfinfo pdftoppm; do
  command -v "$t" >/dev/null || { echo "ERROR: $t not found (install poppler)" >&2; exit 2; }
done

url="file://$deck"
rm -f "$out"/p-*.png "$out"/sheet*.png

# Live DOM after KaTeX has run.
"$chrome" --headless=new --disable-gpu --virtual-time-budget=15000 --dump-dom "$url" 2>/dev/null > "$out/dom.html"
formulas=$({ grep -o 'class="katex"' "$out/dom.html" || true; } | wc -l | tr -d ' ')
errors=$({ grep -o 'katex-error' "$out/dom.html" || true; } | wc -l | tr -d ' ')
echo "katex formulas: $formulas"
echo "katex errors:   $errors"
if [ "$formulas" = "0" ] && grep -q '\$' "$deck"; then
  echo "WARNING: no formulas rendered; KaTeX may have failed to load (network?)"
fi

# PDF, one slide per page via the deck's print CSS.
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=15000 \
  --print-to-pdf="$out/$name.pdf" "$url" 2>/dev/null
pages=$(pdfinfo "$out/$name.pdf" | awk '/^Pages:/ {print $2}')
slides=$({ grep -o 'class="page' "$deck" || true; } | wc -l | tr -d ' ')
echo "pdf pages:      $pages (slides in source: $slides)"
[ "$pages" = "$slides" ] || echo "WARNING: page count differs from slide count; a slide may be overflowing onto a second page"

pdftoppm -r 60 -png "$out/$name.pdf" "$out/p"

# Contact sheets, four pages each.
if python3 -c "import PIL" 2>/dev/null; then
  python3 - "$out" <<'EOF'
import glob, os, sys
from PIL import Image
out = sys.argv[1]
files = sorted(glob.glob(os.path.join(out, "p-*.png")))
ims = [Image.open(f) for f in files]
w, h = ims[0].size
for k in range(0, len(ims), 4):
    sheet = Image.new("RGB", (w * 2, h * 2), "white")
    for j, im in enumerate(ims[k:k + 4]):
        sheet.paste(im, ((j % 2) * w, (j // 2) * h))
    sheet.save(os.path.join(out, f"sheet{k // 4}.png"))
print(f"contact sheets: {(len(ims) + 3) // 4}")
EOF
else
  echo "Pillow not installed; inspect the per-page PNGs instead of contact sheets"
fi

echo "output dir:     $out"
[ "$errors" = "0" ]
