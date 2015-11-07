#!/bin/bash

set -e

# Set up build directory
mkdir "${BUILD_DIR}"
cp ./index.html ./"${BUILD_DIR}"

uname -a
echo "***** Do we have kpsewhich?"
dpkg -L texlive-binaries | grep kpsewhich

echo "***** Where do we find .sty files?"
kpsewhich -show-path .sty

echo "***** What files does texlive-bibtex-extra contain? Where is biblatex.sty?"
dpkg -L texlive-bibtex-extra 

echo "***** Try find biblatex system wise?"
find /usr/share/texlive/texmf-dist/tex/latex -iname 'biblatex*'

kpsewhich biblatex.sty
echo "Success on kpsewhich"

# Build LaTeX files
latexmk
