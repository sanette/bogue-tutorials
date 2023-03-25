(**
   {0 Bogue tutorials — General instructions}

   Welcome to the Bogue tutorials!

   These tutorials can be simply read online, but of course it's better (and
   more fun!) to execute the various code chunks by yourself. In fact, all
   tutorials have been designed so that they can be entirely compiled and
   executed. Hence, it's a good idea to install the [bogue-tutorials] package on
   your machine:

   {[
     opam pin https://github.com/sanette/bogue-tutorials.git
   ]}

   This will ensure that the whole code is compatible with your
   {{:https://github.com/sanette/bogue}Bogue} install. In fact, if you didn't
   install Bogue beforehand, this will automatically install a compatible
   version. You can also download the source and [opam install .]; you may
   append the option [--deps-only] if you don't want to install the executables.

   {1 How to execute these tutorials}

   {2 Option 1: Interactive OCaml session}

   You may simply open an [OCaml] toplevel (for instance [utop]), and load
   [Bogue]:

   {[
     #thread;;
     #require "bogue";;
   ]}

   Of course we assume that you have a working
   {{:https://ocaml.org/docs/up-and-running}OCaml} environment and installed the
   {{:https://github.com/sanette/bogue}Bogue} library.

   Then, you can simply follow the chosen tutorial by pasting the code chunks
   into the toplevel.

   Another option is to directly execute the tutorial. For this you have two
   choices:

   {2 Option 2: Download the source}

   First, you need to download the complete repository:

   {@bash[
     git clone https://github.com/sanette/bogue-tutorials.git
     cd bogue-tutorials
   ]}

   Then, you can execute any tutorial with the command: [make exe] from within
   the tutorial directory. For instance, running the "Hello world" tutorial goes
   as follows:

   {@bash[
   cd hello
   make exe
   ]}

   +SIDE:begin
   A benefit for having downloaded the repo: you may access all
   tutorials locally, by opening the file [docs/bogue-tutorials/index.html] in a
   browser.
   +SIDE:end

   {2 Option 3: Install the package}

   {@bash[
     opam install bogue-tutorials
   ]}

   Then the executables [bogue-tutorials.xxx] will be automatically installed.
   For instance, for running the "Hello world" tutorial, just run

   {@bash[
   bogue-tutorials.hello
   ]}

   {1 Several examples in a tutorial?}

   No problem: if the tutorial opens several Bogue instances, just close the
   current Bogue window to allow the next one to open.

   {1 Ready?}

   Then let's start:

   + {{!page-hello}Hello world}
   + Counter TODO
   + {{!page-modif_parent}Self-modifying layouts}
   + More to come...
*)
