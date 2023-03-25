#!/bin/bash -e
# copy images references in ml files to odoc subdir specified by first arg

# This parses both "+IMAGE:" and html "img src=" syntaxes
# (Very Basic! "img src" should be with a single space and on a single line!)

dir=$1
shift

for ml in "$@"
do
    for i in $(grep '+IMAGE:' $ml | sed "s|.*+IMAGE:\"\([^\"]*\)\".*|\1|g") $(grep 'img src=' $ml | sed "s|.* src=\"\([^\"]*\)\".*|\1|g")
    do
	echo "Copy [$i]"
	cp "$i" ../../_build/default/_doc/_html/$dir/
    done
done
