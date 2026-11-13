#!/usr/bin/env bash
# Hotfix 2026-11-12 — share thumbnail. Run in AWS CloudShell, us-east-2 (BB-OPS-001 §9.6).
set -euo pipefail
U=https://coderm15.github.io/aditimahajan.github.io/bolobit-share-upload
B=s3://bolobit-frontend
SHA_INDEX=67d5781f824d4c2ff27a820322142693bec3accf588d37396fe5aa6bad5d1d80
SHA_OG=3079280cf79a24872e8b9e7ea5bb30d3d9b46eb7e90ad841088d8001e6522522
SHA_BEFORE=996963ec8e604b319fc69ba5caaff85194eb01f5f88726c16d9b499e0ad6f227
mkdir -p ~/share && cd ~/share
check() { [ "$(sha256sum "$1" | cut -c1-64)" = "$2" ] || { echo "STOPPED: $1 does not match the tested file. Nothing uploaded."; exit 1; }; }

echo "1/5 Downloading the tested files"
curl -sf "$U/index.html" -o index.html && check index.html "$SHA_INDEX"
curl -sf "$U/og-v1.png"  -o og-v1.png  && check og-v1.png  "$SHA_OG"

echo "2/5 Backing up the live page"
aws s3 cp "$B/index.html" index-before.html --only-show-errors
[ "$(sha256sum index-before.html | cut -c1-64)" = "$SHA_BEFORE" ] || {
  echo "STOPPED: the live index.html changed since this patch was made (another release?). Nothing uploaded."; exit 1; }

echo "3/5 Uploading the image"
aws s3 cp og-v1.png "$B/og-v1.png" --content-type image/png --cache-control no-cache --only-show-errors

echo "4/5 Uploading the page"
aws s3 cp index.html "$B/index.html" --content-type 'text/html; charset=utf-8' --cache-control no-cache --only-show-errors

echo "5/5 Clearing the CDN cache"
aws cloudfront create-invalidation --distribution-id EERQNNNL431GC --paths '/*' --query 'Invalidation.{Id:Id,Status:Status}' --output text
echo "DONE. Backup: ~/share/index-before.html"
