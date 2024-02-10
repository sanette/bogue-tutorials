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

You now can write your tutorial in `great_tutorial/src/great_tutorial.ml`.

### Syntax

The text of the tutorial is written in a "simple" `.ml` file, with
some special syntax. The easier is really to look at one of the
existing tutos, but here are the various constructs you may use:

+ *Standard text* must be written in _comments_ of the form `(** My
  nice explanation **)`. Note the double stars for opening _and_
  closing comments.
+ *Images* can be easily included using `+IMAGE:"myimage.png"`
+ *Side notes* (folded by default in the final html document) (written
	in standard text) are surrounded by ``+SIDE:begin` and `+SIDE:end`.
+ *Code* that will be compiled (and can be executed with `make exe`)
  should be written _outside_ comments, and surrounded by
  `(* +CODE:begin *)` and `(* +CODE:end *)`:
  ```ocaml
  (* +CODE:begin *)
  let () = print_endline "Hello"
  (* +CODE:end *)
  ```
  This may sound weird, but the advantage is that the code will be
  analyzed and pretty-printed by emacs/merlin as any code in an `.ml`
  file.

_Warning:_ if you include images (which is a good idea!) make sure
that their names are specific enough, because eventually the images of
all tutorials will be copied into the same directory.

### Preview

To preview your tutorial:

```bash
cd great_tutorial
make view
```

You may then offer a pull request!
