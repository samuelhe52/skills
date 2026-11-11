#!/bin/bash
# Render an HTML slide deck and check it.
# Usage: render_check.sh <deck.html> [out-dir]   (default out-dir: ./tmp/render-<deck-name>)
# Checks that the deck kept the template's runtime and that it works in a live browser
# (navigation, theme toggle, highlights, line charts, no script errors), prints KaTeX
# formula/error counts, prints the deck to PDF (one slide per page, light theme),
# screenshots every slide in the dark theme, and writes 2x2 contact sheets of both.
# Exits nonzero on any error.
set -euo pipefail
tpl="$(cd "$(dirname "$0")/.." && pwd)/assets/template.html"
fail=0

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
rm -f "$out"/p-*.png "$out"/d-*.png "$out"/sheet*.png "$out"/dark-sheet*.png
slides=$({ grep -o 'class="page' "$deck" || true; } | wc -l | tr -d ' ')

# 1. The runtime (everything after the end marker) must match the template byte for byte.
end='<!-- SLIDES:END -->'
if grep -qF "$end" "$deck"; then
  if cmp -s <(sed "1,/$end/d" "$deck") <(sed "1,/$end/d" "$tpl"); then
    echo "runtime:        matches template"
  else
    echo "ERROR: the code after $end differs from the template's. Copy it back from $tpl (or, for a deck made"
    echo "       from an older template, move the slides into a fresh copy of the template)."
    fail=1
  fi
  heads_differ=$(cmp -s <(sed "/SLIDES:BEGIN/,\$d" "$deck" | grep -v -e '<html' -e '<title>') \
                        <(sed "/SLIDES:BEGIN/,\$d" "$tpl"  | grep -v -e '<html' -e '<title>') || echo yes)
  [ -z "$heads_differ" ] || echo "note:           <head> differs from the template (fine if styles were added on purpose)"
else
  echo "WARNING: no $end marker, so the template's runtime can't be verified; the live checks below still run"
fi

# 2. Live page after all scripts and KaTeX have run, with the browser console captured.
"$chrome" --headless=new --disable-gpu --enable-logging=stderr --v=0 --virtual-time-budget=15000 \
  --dump-dom "$url" 2>"$out/console.log" > "$out/dom.html"
console=$(grep ':CONSOLE' "$out/console.log" | sed 's/^.*:CONSOLE[^]]*] //' || true)
if [ -n "$console" ]; then
  echo "browser console:"; echo "$console" | sed 's/^/  /'
  # KaTeX missing offline is reported by the formula check below, not here.
  if echo "$console" | grep -v 'renderMathInElement is not defined' | grep -qE 'Uncaught|lchart:'; then
    echo "ERROR: script error or unplaceable chart label (see console above)"; fail=1
  fi
fi
hidden=$({ grep -oE 'class="page[^"]*" hidden' "$out/dom.html" || true; } | wc -l | tr -d ' ')
missing=""
[ "$hidden" = "$((slides - 1))" ] || missing="$missing slide-navigation(hidden pages: $hidden, want $((slides - 1)))"
grep -q 'class="theme-toggle"' "$out/dom.html" || missing="$missing theme-toggle"
grep -q 'id="hl-bar"' "$out/dom.html" && grep -q 'id="hl-note"' "$out/dom.html" || missing="$missing highlight-ui"
# Slide region: from <body> to the first bare <script> line (JSON chart specs use <script type=...>).
charts=$({ sed -n '/<body>/,/^<script>$/p' "$deck" | grep -o 'class="lchart"' || true; } | wc -l | tr -d ' ')
drawn=$({ grep -o 'class="lchart-svg"' "$out/dom.html" || true; } | wc -l | tr -d ' ')
[ "$charts" = "$drawn" ] || missing="$missing line-charts($drawn of $charts drawn)"
if [ -n "$missing" ]; then echo "ERROR: not working in the live page:$missing"; fail=1
else echo "live page:      navigation, theme toggle, highlights, $drawn line chart(s) ok"; fi
formulas=$({ grep -o 'class="katex"' "$out/dom.html" || true; } | wc -l | tr -d ' ')
errors=$({ grep -o 'katex-error' "$out/dom.html" || true; } | wc -l | tr -d ' ')
echo "katex formulas: $formulas"
echo "katex errors:   $errors"
# Search only the slides: the template's CSS comments and KaTeX setup contain $ delimiters.
if [ "$formulas" = "0" ] && sed -n '/<body>/,/^<script>$/p' "$deck" | grep -q '\$'; then
  echo "WARNING: no formulas rendered; KaTeX may have failed to load (network?)"
fi

# PDF, one slide per page via the deck's print CSS.
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=15000 \
  --print-to-pdf="$out/$name.pdf" "$url" 2>/dev/null
pages=$(pdfinfo "$out/$name.pdf" | awk '/^Pages:/ {print $2}')
echo "pdf pages:      $pages (slides in source: $slides)"
[ "$pages" = "$slides" ] || echo "WARNING: page count differs from slide count; a slide may be overflowing onto a second page"

pdftoppm -r 100 -png "$out/$name.pdf" "$out/p"

# Dark theme: one screenshot per slide (fresh headless profile, so the theme follows the forced dark scheme).
for i in $(seq 1 "$slides"); do
  "$chrome" --headless=new --disable-gpu --force-dark-mode --hide-scrollbars --window-size=1600,900 \
    --virtual-time-budget=8000 --screenshot="$out/d-$(printf %02d "$i").png" "$url#$i" >/dev/null 2>&1
done

# Contact sheets, four pages each, at half size: sheetN.png (light, from the PDF) and dark-sheetN.png.
if python3 -c "import PIL" 2>/dev/null; then
  python3 - "$out" <<'EOF'
import glob, os, sys
from PIL import Image
out = sys.argv[1]
for pat, prefix in (("p-*.png", "sheet"), ("d-*.png", "dark-sheet")):
    ims = [Image.open(f).convert("RGB").resize((800, 450)) for f in sorted(glob.glob(os.path.join(out, pat)))]
    for k in range(0, len(ims), 4):
        sheet = Image.new("RGB", (1600, 900), "white")
        for j, im in enumerate(ims[k:k + 4]):
            sheet.paste(im, ((j % 2) * 800, (j // 2) * 450))
        sheet.save(os.path.join(out, f"{prefix}{k // 4}.png"))
    print(f"{prefix + 's:':<16}{(len(ims) + 3) // 4}")
EOF
else
  echo "Pillow not installed; inspect the per-page PNGs instead of contact sheets"
fi

echo "output dir:     $out  (full-size pages: p-NN.png light, d-NN.png dark)"
[ "$errors" = "0" ] || fail=1
exit "$fail"
