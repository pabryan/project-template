#!/bin/bash

set -e

# Set up build directory
mkdir "${BUILD_DIR}"
cp ./index.html ./"${BUILD_DIR}"

# Build LaTeX files
latexmk