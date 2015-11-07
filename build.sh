#!/bin/bash

set -e

# Set up build directory
mkdir "${BUILD_DIR}"
cp ./index.html ./"${BUILD_DIR}"

dpkg -L texlive-binaries | grep kpsewhich
kpsewhich -show-path .sty

kpsewhich biblatex.sty
echo "Success on kpsewhich"

# Build LaTeX files
latexmk
