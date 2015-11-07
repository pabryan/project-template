#!/bin/bash

set -e

# Set up build and deploy directories
[[ "${BUILD_DIR}" != "." ]] &&  mkdir "${BUILD_DIR}"
mkdir "${DEPLOY_DIR}"

# Build LaTeX files
latexmk

# Move PDF's into _deploy directory
while IFS=':' read -ra TEX_SOURCES_ARRAY; do
    for file in "${TEX_SOURCES_ARRAY[@]}"; do
	mv "${BUILD_DIR}"/$(basename "$file" .tex)".pdf" "${DEPLOY_DIR}/"
    done
done <<< "$TEX_SOURCES"

cp ./index.html ./"${DEPLOY_DIR}"
