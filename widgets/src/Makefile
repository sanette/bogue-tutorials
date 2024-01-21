ML_FILES = $(wildcard *.ml)
MLD_TARGETS = $(ML_FILES:.ml=.mld)
COMMON_DIR = ../../common
DUNE = opam exec -- dune

all:	mld
	$(DUNE) build @check
.PHONY: all

mld:	$(MLD_TARGETS)
.PHONY: mld

$(MLD_TARGETS): %.mld: %.ml
	$(COMMON_DIR)/make_mld.sh $?

images: graph.png graph-volume.png
	$(COMMON_DIR)/copy_images.sh bogue-tutorials $(ML_FILES)
.PHONY: images

graph.png: graph.gv
	dot -Tpng graph.gv > graph.png

graph-volume.png: graph-volume.gv
	dot -Tpng graph-volume.gv > graph-volume.png

clean:
	rm -f $(MLD_TARGETS)
.PHONY: clean
