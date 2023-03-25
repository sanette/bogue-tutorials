all:	mld
	dune build @check
.PHONY: all

mld:	src
	$(MAKE) -C src mld
.PHONY: mld

clean:
	$(MAKE) -C src clean
.PHONY: clean

view:
	$(MAKE) -C .. all
	sensible-browser ../_build/default/_doc/_html/bogue-tutorials/hello.html
.PHONY: view

exe:
	dune exec src/hello.exe
.PHONY: exe

images:
	$(MAKE) -C src images
.PHONY: images
