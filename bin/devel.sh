#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="${SCRIPT_DIR}/.."

cd "${PROJECT_DIR}"
hugo server
