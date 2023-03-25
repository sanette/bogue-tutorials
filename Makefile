SUBDIRS = common hello modif_parent
DOCDIR = _build/default/_doc/_html/bogue-tutorials
DUNE = opam exec -- dune

all: images
	$(DUNE) build
.PHONY: all

.PHONY: subdirs $(SUBDIRS)
mld: $(SUBDIRS)
.PHONY:	mld

$(SUBDIRS):
	$(MAKE) -C $@

images: $(DOCDIR)
	$(MAKE) -C common images
	$(MAKE) -C hello images
	$(MAKE) -C modif_parent images
.PHONY: images

$(DOCDIR): mld
	$(DUNE) build @doc # this removes images

clean:
	$(MAKE) -C common clean
	$(MAKE) -C hello clean
	$(MAKE) -C modif_parent clean
	$(DUNE) clean
	rm -rf docs
.PHONY: clean

view:	$(DOCDIR)
	sensible-browser $(DOCDIR)/index.html
.PHONY: view

docs: $(DOCDIR)
	rsync -av $(DOCDIR)/../ docs
	cd docs; mv _odoc_support odoc_support
	find docs -name *.html -exec sed -i 's|_odoc_support|odoc_support|g' {} \;

