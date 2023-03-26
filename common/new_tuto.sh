#!/bin/bash -e
# Create a directory and install makefiles for a new tutorial.
# Should be run from the root directory of the tutorials, like this:
# common/new_tuto.sh my_new_tuto

if ! [[ -d common ]]
then
    echo "This command should be run from the root directory of the tutorials, like this:
$ common/new_tuto.sh my_new_tuto"
    exit 1
fi

tuto=$1

if [[ $# == 2 ]]
then
    fullname="$2"
else
    fullname=$1
fi

if [[ -d "$tuto" ]]
then
    echo "Directory [$tuto] already exists. Aborting."
    exit 1
fi

mkdir -p $tuto/src
echo "TUTO = $tuto" > $tuto/Makefile
cat common/Makefile.main >> $tuto/Makefile
cp common/Makefile.src $tuto/src/Makefile
echo -e "(** {0 Bogue-tutorial — $fullname.} *)\n" > $tuto/src/$tuto.ml
cp common/dune.src $tuto/src/dune
sed -i "s|%%TUTO%%|$tuto|g" $tuto/src/dune

if [[ "A"$(grep "SUBDIRS ="  Makefile | grep $tuto) == "A" ]]
then
    echo "Updating Makefile."
    sed -i "s|SUBDIRS = \(.*\)|SUBDIRS = \1 $tuto|g" Makefile
else
    echo "Warning: $tuto was already present in Makefile."
fi

if [[ "A"$(grep "!page-$tuto" common/index.ml) == "A" ]]
then
    echo "Updating index."
    sed -i "s|+ More to come...|+ {{!page-$tuto}$fullname}\n   + More to come...|g" common/index.ml
else
    echo "Warning: {!page-$tuto} was already mentioned in common/index.ml"
fi

echo "Done. Now edit [$tuto/src/$tuto.ml]!"
