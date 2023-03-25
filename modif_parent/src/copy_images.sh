#!/bin/bash -e
# copy images references in ml files to odoc output dir

for ml in $@
do
    for i in $(grep 'img src=' $ml | sed "s|.* src=\"\(.*\)\".*|\1|g")
    do
	echo "Copy $i"
	cp $i ../_build/default/_doc/_html/bogue_tuto_modif_parent/
    done
done
