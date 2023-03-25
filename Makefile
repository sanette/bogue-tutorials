# "make all" is enough to browse the tutorials in $(DOCDIR) ("make view")
# use "make docs" to copy everything in the docs dir (like in the github repo)
#
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

view:	css
	sensible-browser $(DOCDIR)/index.html
.PHONY: view

css: images
	chmod 644  $(DOCDIR)/../_odoc_support/odoc.css
	echo ".sidenote{font-size:smaller;background:whitesmoke;" >> $(DOCDIR)/../_odoc_support/odoc.css
.PHONY: css

docs: css
	rsync -av $(DOCDIR)/../ docs
	cd docs; rm -rf odoc_support; mv _odoc_support odoc_support
	find docs -name *.html -exec sed -i 's|_odoc_support|odoc_support|g' {} \;
