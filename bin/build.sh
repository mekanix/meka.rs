#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${PROJECT_DIR}/public"

cd "${PROJECT_DIR}"
rm -rf public
hugo
tail -n +6 "${PROJECT_DIR}/content/resume.md" | \
pandoc --standalone --include-in-header "${PROJECT_DIR}/styles/resume.css" \
  --lua-filter=pdc-links-target-blank.lua \
  --from markdown --to html \
  --metadata pagetitle="Goran Mekić" | \
weasyprint - "${OUTPUT_DIR}/resume.pdf"
