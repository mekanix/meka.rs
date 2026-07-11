#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${PROJECT_DIR}/public"

build_resume() {
  INPUT="$1"
  OUTPUT="$2"
  EMAIL=$(awk -F"['\"]" '/^[[:space:]]*email[[:space:]]*=/ {print $2; exit}' "${PROJECT_DIR}/hugo.toml")
  SITE=$(awk -F"['\"]" '/^baseURL[[:space:]]*=/ {print $2; exit}' "${PROJECT_DIR}/hugo.toml")
  BODY_HEADER=$(mktemp)
  echo "<p style=\"text-align:center;\"><img src=\"static/images/avatar.webp\" alt=\"Goran Mekić\" style=\"width:120px;height:120px;border-radius:50%;\"></p>" > "${BODY_HEADER}"

  tail -n +6 "${INPUT}" | \
    sed -e "s|{{< site >}}|${SITE}|g" -e "s|{{< email >}}|${EMAIL}|g" | \
    pandoc --standalone \
      --include-in-header "${PROJECT_DIR}/styles/resume.css" \
      --include-before-body "${BODY_HEADER}" \
      --lua-filter=pdc-links-target-blank.lua \
      --from markdown --to html \
      --metadata pagetitle="Goran Mekić" | \
    weasyprint --custom-metadata - "${OUTPUT}"

  rm -f "${BODY_HEADER}"
}

cd "${PROJECT_DIR}"
rm -rf public
hugo --minify
build_resume "${PROJECT_DIR}/content/resume.md" "${OUTPUT_DIR}/resume.pdf"
