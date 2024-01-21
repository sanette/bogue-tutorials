#!/bin/bash -e
# Convert an .ml file (with restrictions!) to an .mld file
# San Vu Ngoc 2023
#
# The goal is to have a unique file for both execution (ocaml) and
# documentation (odoc).  We chose to keep only the .ml files because
# emacs can do the syntax highlighting, which is currently not
# available for .mld.
#
# This script does a very basic conversion to mld by blindly removing
# comment markers '(**' and '*)'.
#
# In addition, some specific features:
#
# 1. Code markers.
# (* +CODE:begin *) and (* +CODE:end *) are replaced
# by '{[' and ']}' respectively, which embeds the code in the
# documentation.
# Warning: code parts should not contain the strings '(**' and '*)'!
# Hence no comments!
#
# 2. Hiding parts.
# Anything between (* +HIDE:begin *) and (* +HIDE:end *) is removed.
#
# 3. Images.
# (* +IMAGE:"file.png" *)
# Note: we are serving HiDPI images. Instead of srcset one could use:
# onload="this.width/=2;"

i=$1
base=$(basename $i ".ml")
mld=$base.mld
ml=$base.ml
echo "Converting $ml to $mld"

sed "s|(\* +CODE:begin \*)|{[|g" $ml > $mld
sed -i "s|(\* +CODE:end \*)|]}|g" $mld
sed -i "s|+SIDE:begin|{%html:<div class=\"sidenote\"><div class=\"collapse\"></div><div class=\"content\">%}|g" $mld
sed -i "s|+SIDE:end|{%html:</div></div>%}|g" $mld
sed -i 's|+IMAGE:"\([^\"]*\)"|{%html:<div class="figure"><img src="\1" srcset="\1 2x"></div>%}|g' $mld
sed -i -z "s|(\* +HIDE:begin \*).*(\* +HIDE:end \*)||g" $mld
sed -i -z "s|(\*\*[^/]||g" $mld
sed -i "s|*)||g" $mld

# https://github.com/ocaml/odoc/issues/998
sed -i '1s|^|{%html: <!-- auto-generated file --> %}\n|' $mld
