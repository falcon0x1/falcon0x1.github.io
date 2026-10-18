#!/usr/bin/env bash
# blog-preflight.sh — run BEFORE you commit/push a new post.
# Catches the #1 cause of a frozen blog: a post that links an image which is
# not committed to git. The deploy workflow runs htmlproofer and a single
# missing image fails the whole build, so nothing new publishes.
# No Ruby/Jekyll needed — pure shell + git.
set -u
cd "$(dirname "$0")" || exit 2
fail=0

echo "== Preflight: checking every /assets image referenced by posts and pages =="
# Collect image refs from posts + top-level pages/tabs (handles Liquid '{{ '/assets/..' | relative_url }}' and plain /assets/..)
refs=$(grep -rhoE "/assets/[A-Za-z0-9_./-]+\.(png|jpe?g|webp|gif|svg)" _posts _tabs _pages . --include='*.md' --include='*.markdown' --include='*.html' 2>/dev/null | sort -u)

for ref in $refs; do
  path=".${ref}"                      # /assets/img/x.png -> ./assets/img/x.png
  rel="${path#./}"
  if [ ! -e "$path" ]; then
    echo "  MISSING ON DISK : $ref"; fail=1; continue
  fi
  if ! git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
    echo "  NOT COMMITTED   : $ref   (exists on disk but git doesn't track it -> run: git add $rel)"; fail=1; continue
  fi
done

# Also flag any untracked image sitting in assets (you may have meant to commit it)
untracked=$(git ls-files --others --exclude-standard assets 2>/dev/null | grep -Ei '\.(png|jpe?g|webp|gif|svg)$')
if [ -n "$untracked" ]; then
  echo "== Untracked images in assets/ (commit them if a post uses them) =="
  echo "$untracked" | sed 's/^/  ?? /'
fi

if [ "$fail" -eq 0 ]; then
  echo "OK — every referenced image is committed. Safe to push."
else
  echo "PROBLEM — fix the lines above (git add the files) before pushing, or the deploy will fail its test gate and nothing will publish."
fi
exit $fail
