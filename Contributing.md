# How to contribute?

## Building

In each tutorial `src` directory, `.mld` files are auto-generated. You
should modify only the `.ml` files.

There is a special syntax for inserting executable chunks of code. See
examples.

After modifying `.ml` files, you should do:

```
make clean
make
```

This will generate the documentation and compile the code.

You may use `make view` to open the tutorials in a browser.

This works in the root directory. But more is available in each
tutorial directory: `make exe`. For instance

```
cd hello
make exe
```

This will execute the code of the tutorial.

## Create a new tutorial
	
To create a new tutorial, download the repository, `cd
bogue-tutorials`, and execute:

```bash
common/new_tuto.sh great_tutorial "My great tutorial"
```

where you should replace `great_tutorial` by the machine name of your
tutorial (it has to be different from all existing subdirectories),
and `My great tutorial` by the full title of your tutorial.

To preview your tutorial:

```bash
cd great_tutorial
make view
```

You may then offer a pull request!

_Warning:_ if you include images (which is a good idea!) make sure
that their names are specific enough, because eventually the images of
all tutorials will be copied into the same directory.
