#!/bin/bash 

TEXFILE=listofauthors

pdflatex $TEXFILE.tex
rm -fv $TEXFILE.log $TEXFILE.aux