#!/bin/bash -u

if [ $# -ge 1 ]
then
  TEXT="$@"
else
  TEXT="EMPTY FIGURE"
fi


convert -size 800x600 -background gray -fill white -pointsize 100 -gravity center label:"$TEXT" "${TEXT// /_}.png"
