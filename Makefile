PROJECTNAME      = blogger
BUILDDIR         = $(CURDIR)/target
TOOLSDIR         = $(BUILDDIR)/tools
SRCDIR           = $(CURDIR)
RESOURCEDIR      = $(BUILDDIR)/classes
SRCFILE          = $(SRCDIR)/$(PROJECTNAME).asciidoc
IMGDIR           = $(SRCDIR)/images
IMGTARGETDIR     = $(BUILDDIR)/classes/images
CSSDIR           = $(TOOLSDIR)/main/resources/css
JSDIR            = $(TOOLSDIR)/main/resources/js
CONFDIR          = $(SRCDIR)/conf
TOOLSCONFDIR     = $(TOOLSDIR)/main/resources/conf
DOCBOOKFILE      = $(BUILDDIR)/$(PROJECTNAME)-shortinfo.xml
DOCBOOKFILEHTML  = $(BUILDDIR)/$(PROJECTNAME)-html.xml
FOPDIR           = $(BUILDDIR)/pdf
FOPFILE          = $(FOPDIR)/$(PROJECTNAME).fo
FOPPDF           = $(FOPDIR)/$(PROJECTNAME).pdf
TEXTWIDTH        = 80
TEXTDIR          = $(BUILDDIR)/text
TEXTFILE         = $(TEXTDIR)/$(PROJECTNAME).txt
TEXTHTMLFILE     = $(TEXTFILE).html
SINGLEHTMLDIR    = $(BUILDDIR)/html
SINGLEHTMLFILE   = $(SINGLEHTMLDIR)/index.html
ANNOTATEDDIR     = $(BUILDDIR)/annotated
ANNOTATEDFILE    = $(HTMLDIR)/$(PROJECTNAME).html
CHUNKEDHTMLDIR   = $(BUILDDIR)/chunked
CHUNKEDOFFLINEHTMLDIR = $(BUILDDIR)/chunked-offline
CHUNKEDTARGET     = $(BUILDDIR)/$(PROJECTNAME).chunked
CHUNKEDSHORTINFOTARGET = $(BUILDDIR)/$(PROJECTNAME)-html.chunked
MANPAGES         = $(BUILDDIR)/manpages
UPGRADE          = $(BUILDDIR)/upgrade
EXTENSIONSRC     = $(TOOLSDIR)/bin/extensions
EXTENSIONDEST    = ~/.asciidoc
SCRIPTDIR        = $(TOOLSDIR)/build
ASCIDOCDIR       = $(TOOLSDIR)/bin/asciidoc
ASCIIDOC         = $(ASCIDOCDIR)/asciidoc.py
A2X              = $(ASCIDOCDIR)/a2x.py
DECKDIR          = $(BUILDDIR)/deck
DECKJSDIR        = $(EXTENSIONSRC)/backends/deckjs/deck.js

ifdef VERBOSE
	V = -v
	VA = VERBOSE=1
endif

ifdef KEEP
	K = -k
	KA = KEEP=1
endif

ifdef VERSION
	VERSNUM =$(VERSION)
else
	VERSNUM =-neo4j-version
endif

ifdef IMPORTDIR
	IMPDIR = --attribute importdir="$(IMPORTDIR)"
else
	IMPDIR = --attribute importdir="$(BUILDDIR)/docs"
	IMPORTDIR = "$(BUILDDIR)/docs"
endif

ifneq (,$(findstring SNAPSHOT,$(VERSNUM)))
	GITVERSNUM =master
else
	GITVERSNUM =$(VERSION)
endif

ifndef VERSION
	GITVERSNUM =master
endif

VERS =  --attribute neo4j-version=$(VERSNUM)

GITVERS = --attribute gitversion=$(GITVERSNUM)

ASCIIDOC_FLAGS = $(V) $(VERS) $(GITVERS) $(IMPDIR)

A2X_FLAGS = $(K) $(ASCIIDOC_FLAGS)

.PHONY: blog help

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  blog     to generate a blog post"
	@echo "For verbose output, use 'VERBOSE=1'".
	@echo "To keep temporary files, use 'KEEP=1'".
	@echo "To set the version, use 'VERSION=[the version]'".
	@echo "To set the importdir, use 'IMPORTDIR=[the importdir]'".

#dist: installfilter offline-html html html-check text text-check pdf manpages upgrade cleanup yearcheck

cleanup:
	#
	#
	# Cleaning up.
	#
	#
ifndef KEEP
	rm -f "$(DOCBOOKFILE)"
	rm -f "$(BUILDDIR)/"*.xml
	rm -f "$(ANNOTATEDDIR)/"*.xml
	rm -f "$(FOPDIR)/images"
	rm -f "$(FOPFILE)"
	rm -f "$(UPGRADE)/"*.xml
	rm -f "$(UPGRADE)/"*.html
endif

initialize:
	#
	#
	# Setting correct file permissions.
	#
	#
	find $(TOOLSDIR) \( -path '*.py' -o -path '*.sh' \) -exec chmod 0755 {} \;

installextensions: initialize
	#
	#
	# Installing asciidoc extensions.
	#
	#
	mkdir -p $(EXTENSIONDEST)
	cp -fr "$(EXTENSIONSRC)/"* $(EXTENSIONDEST)

blog: initialize installextensions
	#
	#
	# Building blog entry.
	#
	#
	"$(ASCIIDOC)" $(ASCIIDOC_FLAGS) -b blogger --conf-file="$(TOOLSCONFDIR)/asciidoc.conf" --conf-file="$(CONFDIR)/asciidoc.conf" --attribute console=1 --out-file "$(BUILDDIR)/blog.html.tmp" "$(SRCDIR)/blogentry.asciidoc"
	tr '\n' ' ' < "$(BUILDDIR)/blog.html.tmp" | tr '\r' ' ' > "$(BUILDDIR)/blog.html"
	rm "$(BUILDDIR)/blog.html.tmp"

