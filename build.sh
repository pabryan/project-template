#!/bin/bash

set -e

# Set up build directory
mkdir "${BUILD_DIR}"
cp ./index.html ./"${BUILD_DIR}"

# Build LaTeX files
mkdir "${LATEX_BUILD_DIR}"
latexmk
mv "${LATEX_BUILD_DIR}/*.pdf" "${BUILD_DIR}/"
