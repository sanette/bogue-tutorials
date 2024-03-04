#!/bin/bash -e
# Create a directory and install makefiles for a new tutorial.
# Should be run from the root directory of the tutorials, like this:
# common/new_tuto.sh my_new_tuto

if ! [[ -d common ]]
then
    >&2 echo "This command should be run from the root directory of the tutorials, like this:
$ common/new_tuto.sh my_new_tuto \"Optional full title\""
    exit 1
fi

if [[ $# == 0 ]]
then
    >&2 echo "The machine name of the tutorial (without spaces) should be given on the command line."
    exit 1
else
    tuto=$1
fi

if [[ $# -ge 2 ]]
then
    fullname="$2"
else
    fullname=$1
fi

if [[ -d "$tuto" ]]
then
    >&2 echo "Directory [$tuto] already exists. Aborting."
    exit 1
fi

echo "Creating tutorial [$tuto] with title [$fullname]."
mkdir -p $tuto/src
echo "TUTO = $tuto" > $tuto/Makefile
cat common/Makefile.main >> $tuto/Makefile
cp common/Makefile.src $tuto/src/Makefile
echo -e "(** {0 Bogue-tutorial — $fullname.} **)\n" > $tuto/src/$tuto.ml
cp common/dune.src $tuto/src/dune
sed -i'' -e "s|%%TUTO%%|$tuto|g" $tuto/src/dune

if [[ "A"$(grep "SUBDIRS ="  Makefile | grep $tuto || :) == "A" ]]
then
    echo "Updating Makefile."
    sed -i'' -e "s|SUBDIRS = \(.*\)|SUBDIRS = \1 $tuto|g" Makefile
else
    echo "Warning: $tuto was already present in Makefile."
fi

if [[ "A"$(grep "!page-$tuto" common/src/index.ml || :) == "A" ]]
then
    echo "Updating index."
    sed -i'' -e "s|+ More to come...|+ {{!page-$tuto}$fullname}\n   + More to come...|g" common/src/index.ml
else
    echo "Warning: {!page-$tuto} was already mentioned in common/src/index.ml"
fi

echo "Done. Now edit [$tuto/src/$tuto.ml]!"
