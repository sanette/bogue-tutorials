(**
   {0 Bogue tutorials — General instructions}

   Welcome to the Bogue tutorials!

   These tutorials can be simply read online, but of course it's better (and
   more fun!) to execute the various code chunks by yourself. In fact, all
   tutorials have been designed so that they can be entirely compiled and
   executed. Hence, it's a good idea to install the [bogue-tutorials] package on
   your machine:

   {[
     opam install bogue-tutorials --deps-only
   ]}

   This will ensure that the whole code is compatible with your {{:https://github.com/sanette/bogue}Bogue}
   install. In fact, if you didn't install Bogue beforehand, this will
   automatically install a compatible version.

   {1 How to execute these tutorials}

   You may simply open an [OCaml] toplevel (for instance [utop]), and load
   [Bogue]:

   {[
     #thread;;
     #require "bogue";;
   ]}

   Of course we assume that you have a working
   {{:https://ocaml.org/docs/up-and-running}OCaml} environment and installed the
   {{:https://github.com/sanette/bogue}Bogue} library.

   Then, you can simply follow the tutorial by pasting the
   code chunks into the toplevel.

   Another option is to download the source:
   {@bash[
     git clone https://github.com/sanette/bogue-tutorials.git
     cd bogue-tutorials
   ]}
   and execute at once the whole tutorial with the command: [make exe] from
   within the tutorial directory. For instance, running the "Hello world"
   tutorial goes as follows:

   {@bash[
   cd hello
   make exe
   ]}

   If the tutorial opens several Bogue instances, just close the current Bogue
   window to allow the next one to open.

   {1 Ready?}

   Then let's start:

   + {{!page-hello}Hello world}
   + {Counter} TODO
   + {{!page-modif_parent}Self-modifying layouts}
   + More to come...
*)
