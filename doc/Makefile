.PHONY: doc upload all-subdirs

SUBDIRS = content liqi
DISTFILES = liquidsoap.1 Makefile protocols_to_liqi.pl reference_to_liqi.pl no-ref.txt \
	    template.html snippet.html
DISTDIRS = orig
PERL_DOM = $(shell perl -MXML::DOM -e1 > /dev/null 2>&1 && echo yes)

CONTENT=$(wildcard content/*.txt)
PRE_HTML=$(shell echo $(CONTENT:.txt=.html) | sed -e 's/content\//html\//g') \
     html/reference.html html/settings.html html/protocols.html
HTML=html/scripts/index.html
MD=$(addprefix md/,$(notdir $(CONTENT:.txt=.md)))
RST=$(addprefix rst/,$(notdir $(CONTENT:.txt=.rst)))
TEX=$(shell echo $(CONTENT:.txt=.tex) | sed -e 's/content\//tex\//g')
PDF=$(TEX:.tex=.pdf)

LIQI = cd html && ../liqi/liqi \
	     --template ../template.html --snippet-template ../snippet.html \
		 --subst rel:
LIQI_DEPS = liqi/liqi template.html snippet.html

# PDF is not ready for end-users yet.
doc: html

html: $(HTML)

md: liqi/liqi $(MD)

rst: liqi/liqi $(RST)

pdf: liqref.pdf

liqref.pdf: tex/liqref.tex $(TEX)
	@echo Compiling liqref.pdf...
	@cd tex; pdflatex -interaction nonstopmode liqref.tex

html/scripts/index.html: html/scripts/index.txt $(LIQI_DEPS)
	@echo Generating $(@)...
	@#Has to be called from html to put scripts in the right place
	$(LIQI) --subst rel:../ -i ../$(<) -o ../$(@)

# I have to tell make that index.txt will be there
# once the HTML have been generated.
# Also ensures that the index is built last even with a concurrent make run.
html/scripts/index.txt: $(PRE_HTML)

html/%.html: content/%.txt $(LIQI_DEPS)
	@echo Converting $(<) to $(@)...
	@test -d html || (mkdir -p html/scripts ; cp -RfL orig/* html)
	@#Has to be called from html to put scripts in the right place
	@$(LIQI) -i ../$(<) -o ../$(@)

tex/%.tex: content/%.txt liqi/liqi
	@echo Converting $(<) to $(@)...
	@test -d tex || mkdir tex
	@./liqi/liqi --latex -i $(<) -o $(@)

tex/%.pdf: tex/%.tex
	@echo Converting $(<) to $(@)...
	@cd tex; pdflatex ../$(<)

md/%.md: content/%.txt
	@echo Converting $(<) to $(@)
	@mkdir -p md
	@./liqi/liqi --markdown -i $(<) -o $(@)

rst/%.rst: content/%.txt
	@echo Converting $(<) to $(@)
	@mkdir -p rst
	@./liqi/liqi --rst -i $(<) -o $(@)

liqi/liqi: all-subdirs
	@# If I don\'t put anything here, make tries to build liqi/liqi
	@# from liqi/liqi.o by using gcc

../src/liquidsoap:
	@echo "Liquidsoap does not seem to be built. You have to build it before."
	@echo "Go to the toplevel and type 'make'"
	exit 1

reference.pdf:
	echo "# Liquidsoap reference\n\n" > reference.md;
	CAML_LD_LIBRARY_PATH=../src:../src/plugins ../src/liquidsoap \
	  --no-pervasives ../lib/pervasives.liq --list-functions-md >> reference.md
	pandoc reference.md -o reference.pdf
	rm -f reference.md

content/reference.txt: reference_to_liqi.pl ../src/liquidsoap ../lib/utils.liq
ifeq ($(PERL_DOM),yes)
	CAML_LD_LIBRARY_PATH=../src:../src/plugins ../src/liquidsoap \
	  --no-pervasives ../lib/pervasives.liq --list-plugins-xml | \
	  ./reference_to_liqi.pl > $(@)
else
	@echo "-> You don't seem to have perl XML::DOM module installed."
	@echo "-> Language reference cannot be generated."
	@cp no-ref.txt content/reference.txt
endif

content/protocols.txt: protocols_to_liqi.pl ../src/liquidsoap ../lib/utils.liq
ifeq ($(PERL_DOM),yes)
	CAML_LD_LIBRARY_PATH=../src:../src/plugins ../src/liquidsoap \
	  --no-pervasives ../lib/pervasives.liq --list-plugins-xml | \
	  ./protocols_to_liqi.pl > $(@)
else
	@echo "-> You don't seem to have perl XML::DOM module installed."
	@echo "-> protocols reference cannot be generated."
	@cp no-protocols.txt content/protocols.txt
endif

content/settings.txt: ../src/liquidsoap
	CAML_LD_LIBRARY_PATH=../src:../src/plugins ../src/liquidsoap --no-pervasives ../lib/pervasives.liq \
	--conf-descr-liqi > $(@)

VERSION="`../src/liquidsoap --version | head -n 1`"

test: html
	@echo "Testing code snippets with \033[1m$(VERSION)\033[0m"
	@echo ""
	@find html/scripts | grep '\.liq' | sort \
	  | ./scripts/test_snippets "`pwd`/../src/liquidsoap -p"
	@echo ""
	@echo "Testing shell scripts.."
	@echo "Please remember that it does not test liq syntax used inline.."
	@echo ""
	@find html/scripts | grep '\.sh' | sort | ./scripts/test_snippets "sh -n"
	@echo ""
	@echo "Testing perl scripts.."
	@echo ""
	@find html/scripts | grep '\.pl' | sort | ./scripts/test_snippets "perl -c"

spell-check: $(CONTENT:.txt=.txt.spell)

content/%.txt.spell: content/%.txt
	-aspell -d en_US-w_accents -c $(<)
	touch $(@)

doc-install:
	$(INSTALL)  -d $(datadir)/doc/$(DISTDIR)/html
	if [ -f html/index.html ] ; then \
	  cp -RfL html/* $(datadir)/doc/$(DISTDIR)/html ; \
        fi
	$(INSTALL) -d $(mandir)/man1
	$(INSTALL_DATA) liquidsoap.1 $(mandir)/man1

clean-local:
	rm -rf html $(TEX) content/reference.txt content/protocols.txt content/settings.txt content/*.txt.spell

top_srcdir=..
include $(top_srcdir)/Makefile.rules
