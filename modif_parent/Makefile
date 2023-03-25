DUNE = opam exec -- dune

all:	mld
	$(DUNE) build @check
.PHONY: all

mld:	src
	$(MAKE) -C src mld
.PHONY: doc

clean:
	$(MAKE) -C src clean
	$(DUNE) clean
.PHONY: clean

view:
	$(MAKE) -C .. all
	sensible-browser ../_build/default/_doc/_html/bogue_tutorials/modif_parent.html
.PHONY: view

exe:
	$(DUNE) exec src/modif_parent.exe
.PHONY: exe

images:
	$(MAKE) -C src images
.PHONY: images
