TUTO = counter
DUNE = opam exec -- dune

all:	mld
	$(DUNE) build @check
.PHONY: all

mld:	src
	$(MAKE) -C src mld
.PHONY: mld

clean:
	$(MAKE) -C src clean
.PHONY: clean

view:
	$(MAKE) -C .. all
	sensible-browser ../_build/default/_doc/_html/bogue-tutorials/$(TUTO).html
.PHONY: view

exe:
	$(DUNE) exec src/$(TUTO).exe
.PHONY: exe

images:
	$(MAKE) -C src images
.PHONY: images
