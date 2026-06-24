#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${PROJECT_DIR}/public"

build_resume() {
  INPUT="$1"
  OUTPUT="$2"
  HIDDEN=$(awk -F"['\"]" '/^[[:space:]]*hidden[[:space:]]*=/ {print $2; exit}' "${INPUT}")
  META_HEADER=$(mktemp)
  echo "<meta name=\"hidden\" content=\"${HIDDEN}\">" > "${META_HEADER}"
  BODY_HEADER=$(mktemp)
  echo "<p style=\"text-align:center;\"><img src=\"static/images/avatar.webp\" alt=\"${HIDDEN}\" style=\"width:120px;height:120px;border-radius:50%;\"></p>" > "${BODY_HEADER}"

  tail -n +6 "${INPUT}" | \
    sed "s|^\(### Master of Science in Business Information Technology\)$|\1 <span style=\"color:#FFFFFF;font-size:1px;\">${HIDDEN}</span>|" | \
    pandoc --standalone \
      --include-in-header "${PROJECT_DIR}/styles/resume.css" \
      --include-in-header "${META_HEADER}" \
      --include-before-body "${BODY_HEADER}" \
      --lua-filter=pdc-links-target-blank.lua \
      --from markdown --to html \
      --metadata pagetitle="Goran Mekić" \
      --metadata description="${HIDDEN}" \
      --metadata keywords="${HIDDEN}" | \
    weasyprint --custom-metadata - "${OUTPUT}"

  rm -f "${META_HEADER}" "${BODY_HEADER}"
}

cd "${PROJECT_DIR}"
rm -rf public
hugo --minify
build_resume "${PROJECT_DIR}/content/resume.md" "${OUTPUT_DIR}/resume.pdf"
