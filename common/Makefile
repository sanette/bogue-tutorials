ML_FILES = $(wildcard *.ml)
MLD_TARGETS = $(ML_FILES:.ml=.mld)
COMMON_DIR = .

all:	mld
	dune build @check
.PHONY: all

mld:	$(MLD_TARGETS)
.PHONY: mld

$(MLD_TARGETS): %.mld: %.ml
	$(COMMON_DIR)/make_mld.sh $?

images:
	$(COMMON_DIR)/copy_images.sh bogue-tutorials $(ML_FILES)
.PHONY: images

clean:
	rm -f $(MLD_TARGETS)
	dune clean
.PHONY: clean
