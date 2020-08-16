# Makefile for SILE originally by Caleb Maclennan.
# This file is CC-BY-SA 4.0: 
# https://github.com/ctrlcctrlv/PamudpodUnicodePaper/commit/4d84d04f100e2265acbaaddc910bea080ef4df9d.patch

SHELL = bash
.ONESHELL:
.SECONDARY:
.SECONDEXPANSION:

OUTPUTS = ch.pdf

all: $(OUTPUTS)

# This is a monkey patch to figure out how many passes we have to to to garantee the TOC is up to date,
# simplify when #230 is fixed.
hastoc = [[ -f $(subst .pdf,.toc,$@) ]] && echo true || echo false
pages = pdfinfo $@ | awk '$$1 == "Pages:" {print $$2}' || echo 0
silepass = sile $< -m -o $@ && pg0=$${pg} pg=$$($(pages))

define runsile =
	pg0=$$($(pages)) hadtoc=$$($(hastoc))
	$(silepass)
	export -n SILE_COVERAGE
	if $(hastoc); then
		$${hadtoc} || $(silepass)
		[[ $${pg} -gt $${pg0} ]] && $(silepass) ||:
	fi
endef

include $(wildcard %.d)

%.pdf: %.sil
	$(runsile)
