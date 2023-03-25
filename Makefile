SUBDIRS = common hello modif_parent
DOCDIR = _build/default/_doc/_html/bogue-tutorials

all: images
	dune build
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
	dune build @doc # this removes images

clean:
	$(MAKE) -C common clean
	$(MAKE) -C hello clean
	$(MAKE) -C modif_parent clean
	dune clean
	rm -rf docs
.PHONY: clean

view:	$(DOCDIR)
	sensible-browser $(DOCDIR)/index.html
.PHONY: view

docs: $(DOCDIR)
	rsync -av $(DOCDIR)/../ docs
