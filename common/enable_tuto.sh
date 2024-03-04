#!/bin/bash -e
# re-enable a previously dissabled tutorial

if ! [[ -d common ]]
then
    >&2 echo "This command should be run from the root directory of the tutorials, like this:
$ common/enable_tuto.sh my_tuto"
    exit 1
fi

if [[ $# == 0 ]]
then
    >&2 echo "The machine name of the tutorial should be given on the command line."
    exit 1
else
    tuto=$1
fi

if ! [[ -d "$tuto" ]]
then
    >&2 echo "Directory [$tuto] does not exist. Aborting."
    exit 1
fi

if [[ "A"$(grep "SUBDIRS ="  Makefile | grep $tuto || :) != "A" ]]
then
    echo "Tutorial [$tuto] is already present in Makefile. Aborting."
    exit 1
fi

echo -n "Updating Makefile..."
sed -i'' -e "s|SUBDIRS = \(.*\)|SUBDIRS = \1 $tuto|g" Makefile
echo "OK"

fullname=$(grep "(\*\* {0" ${tuto}/src/${tuto}.ml | sed 's/(\*\* {0 Bogue-tutorial — \(.*\)\.}.*/\1/')

echo "Title : $fullname"

if [[ "A"$(grep "!page-$tuto" common/src/index.ml || :) == "A" ]]
then
    echo -n "Updating index..."
    sed -i'' -e "s|+ More to come...|+ {{!page-$tuto}$fullname}\n   + More to come...|g" common/src/index.ml
    echo "OK"
else
    echo "Warning: {!page-$tuto} was already mentioned in common/src/index.ml"
fi

echo -n "Enabling dune file..."
mv ${tuto}/src/dune.disabled ${tuto}/src/dune
echo "OK"

echo "Done. Now execute [make]"
