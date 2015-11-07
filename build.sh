#!/bin/bash

set -e

# Set up build directory
mkdir "${BUILD_DIR}"
cp ./index.html ./"${BUILD_DIR}"

#kpsewhich biblatex.sty

# Build LaTeX files
latexmk
