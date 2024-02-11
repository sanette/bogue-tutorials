#!/bin/bash -e
# Tries to disable given tutorial, if not linked in an active tutorial
# The corresponding drectory is not deleted.

# Note: the bash -e option will quit if anything fails, even a grep...
# https://stackoverflow.com/questions/9952177/whats-the-meaning-of-the-parameter-e-for-bash-shell-command-line

if ! [[ -d common ]]
then
    >&2 echo "This command should be run from the root directory of the tutorials, like this:
$ common/disable_tuto.sh my_old_tuto"
    exit 1
fi

if [[ $# == 0 ]]
then
    >&2 echo "The machine name of the tutorial should be given on the command line."
    exit
fi

remove=$1
exists=$(grep "SUBDIRS =" Makefile | grep $remove || exit_code=$?)
if [[ "A"$exists == "A" ]]
then
    echo "Tutorial [${remove}] is not currently enabled in Makefile. Aborting."
    exit 0
fi

echo "Disabling tutorial : ${remove}..."
reg=$(printf '{!page-%s}' $remove)

ACTIVE=$(grep "SUBDIRS =" Makefile | sed 's/SUBDIRS =//')
echo "Active tutorials :$ACTIVE"

active=( $ACTIVE ) # make an array
used=false

for tuto in "${active[@]}"
do
    echo -n " - Checking ${tuto} : "
    count=$(grep -c $reg ${tuto}/src/${tuto}.ml || exit_code=$?)
    if (( exit_code > 1 ))
    then
	echo "grep failure"
	exit $exit_code
    fi
    if (( count > 0 ))
    then
	echo "[$remove] is referenced in [$tuto]!"
	used=true
    else echo "OK"
    fi
done

if [[ $used == true ]]
then
    echo -e "STOP : [$remove] is referenced in other tutorials. Aborting.\nPlease remove references and try again."
    exit 0
fi

regs="s/\(SUBDIRS =.*\) ${remove}\b/\1/"
echo -n "Udpating Makefile..."
sed -i "$regs" Makefile
echo "OK"

echo -n "Updating index..."
mv common/src/index.ml common/src/index.ml.old
grep -v "$reg" common/src/index.ml.old > common/src/index.ml
echo "OK"

echo -n "Disabling dune file..."
mv ${tuto}/src/dune ${tuto}/src/dune.disabled
echo "OK"

echo "done."
