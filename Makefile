# "make view" is enough to browse the tutorials in $(DOCDIR)
# "make all" will also check the OCaml code (and fail on warnings)
# use "make docs" to copy everything in the docs dir (like in the github repo)
#
SUBDIRS = common hello modif_parent counter
DOCDIR = _build/default/_doc/_html/bogue-tutorials
DUNE = opam exec -- dune

all: css
	$(DUNE) build
.PHONY: all

.PHONY: subdirs $(SUBDIRS)
mld: $(SUBDIRS)
.PHONY:	mld

$(SUBDIRS):
	$(MAKE) -C $@ mld

images: $(DOCDIR)
	for dir in $(SUBDIRS); do \
          $(MAKE) -C $$dir images; \
        done
.PHONY: images

$(DOCDIR): mld
	$(DUNE) build @doc # this removes images

clean:
	for dir in $(SUBDIRS); do \
          $(MAKE) -C $$dir clean; \
        done
	$(DUNE) clean
	rm -rf docs
.PHONY: clean

view:	css
	sensible-browser $(DOCDIR)/index.html
.PHONY: view

css: images
	chmod 644  $(DOCDIR)/../_odoc_support/odoc.css
	cat common/misc.css >> $(DOCDIR)/../_odoc_support/odoc.css
.PHONY: css

docs: css
	rsync -av $(DOCDIR)/../ docs
	cd docs; rm -rf odoc_support; mv _odoc_support odoc_support #Github pages does not like directories starting with "_"
	find docs -name *.html -exec sed -i 's|_odoc_support|odoc_support|g' {} \;
