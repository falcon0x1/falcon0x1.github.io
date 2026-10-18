#!/usr/bin/env bash
# blog-status.sh — run AFTER you push. Tells you if the live deploy succeeded,
# and if it failed, prints exactly why (the htmlproofer failures), so you never
# have to guess why a post isn't appearing.
# Needs the GitHub CLI (gh) authenticated for the repo.
set -u
REPO="falcon0x1/falcon0x1.github.io"

echo "== Latest deploy runs =="
gh api "repos/$REPO/actions/runs" \
  --jq '.workflow_runs[0:5][] | "\(.conclusion // .status) | \(.head_sha[0:8]) | \(.display_title) | \(.created_at)"' 2>&1

latest_sha=$(git rev-parse --short HEAD 2>/dev/null)
echo
echo "== Status of your current HEAD ($latest_sha) =="
run=$(gh api "repos/$REPO/actions/runs" --jq ".workflow_runs[] | select(.head_sha|startswith(\"$latest_sha\")) | {id:.id,c:.conclusion,s:.status}" 2>&1 | head -1)
echo "  $run"

# If the newest run failed, show the failing step log tail
rid=$(gh api "repos/$REPO/actions/runs" --jq '.workflow_runs[0].id' 2>&1)
concl=$(gh api "repos/$REPO/actions/runs" --jq '.workflow_runs[0].conclusion' 2>&1)
if [ "$concl" = "failure" ]; then
  echo
  echo "== Newest run FAILED — reason =="
  gh run view "$rid" --repo "$REPO" --log-failed 2>&1 | grep -iE "does not exist|failures|error|htmlproofer|internally linking" | sed 's/^/  /' | head -30
  echo "  (tip: most failures are a post linking an image you forgot to 'git add' — run ./blog-preflight.sh)"
else
  echo
  echo "Newest run: $concl — live site is in sync."
fi
