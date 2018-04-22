# This file defines common configuration variables shared across all Makefiles.
# Furthermore, it defines a help target which makes the buildsystem
# self-documenting.

# that might need adaptation, standard debian ships with dash these days and
# people might not have bash at all; it's also questionable what functionality
# from bash is actually used; on the other hand, the help system relis on bash
# substitutions
SHELL=bash


# set all as default target, so that help is not executed by default
.DEFAULT_GOAL := all

# `xsltproc' comes with libxml/libxslt, see xmlsoft.org
XSLTPROCESSOR ?= xsltproc
XSLTPROCESSORARGS ?= --novalid --xinclude

# set default value
FREEDICT_TOOLS ?= .

# where built files should get installed
PREFIX?=/usr/local
DESTDIR ?= 

# name of the nsgmls command
NSGMLS ?= onsgmls

# the file xml.soc file comes with sp/opensp/openjade
# and is required by nsgmls
XMLSOC ?= /usr/share/xml/declaration/xml.soc

# xml.soc normally points to this file
XMLDECLARATION ?= /usr/share/xml/declaration/xml.dcl
#XMLDECLARATION ?= /usr/share/xml/declaration/xml1n.dcl

# you can also set this in ~/.bashrc
SGML_CATALOG_FILES ?= /etc/sgml/catalog


# dictfmts pre 1.10 are considered "old" and don't understand the --utf8 switch
old_dictfmt := $(shell dictfmt --version | perl -pe '\
if(/^dictfmt v. (\d+)\.(\d+)(\.(\d+))?.*/)\
{ exit (($$1>=1 && $$2 >= 10 && ($$4 eq "" || $$4 >=1)) ? 0 : 1); };\
exit 2;'; echo $$?)

ifeq ($(old_dictfmt), 1)
DICTD_LOCALE ?= en_GB.utf8
DICTFMTFLAGS += --locale $(DICTD_LOCALE)
else
DICTFMTFLAGS += --utf8
endif

charlint_in_path := $(shell which charlint.pl 2>/dev/null)
ifneq ($(charlint_in_path), )
CHARLINT := $(charlint_in_path)
else
# if this doesn't exist it will be downloaded
CHARLINT := $(FREEDICT_TOOLS)/charlint.pl
endif
CHARLINT_DATA := $(dir $(CHARLINT))charlint-unicodedata

MBRDICO_PATH = /

BUILDHELPERS_DIR=$(FREEDICT_TOOLS)/buildhelpers/
# Directory containing all build files, usually a tree like build/<platform>
# within the current working directory.
BUILD_DIR=build
RELEASE_DIR=$(BUILD_DIR)/release


# find python
PYTHON := $(shell command -v python3 2> /dev/null)
ifndef PYTHON
	PYTHON := python
endif

# script to restart the dictd daemon, if installed
DICTD_RESTART_SCRIPT = $(BUILDHELPERS_DIR)dict_restart_helper.sh

# Define the help system, use #! after the colon of a rule to add a
# documentation string
help:
	@echo "Usage: make <command>"
	@echo "The following commands are defined:"
	@echo
	@IFS=$$'\n'; \
	help_lines=`fgrep -h "#!" $(MAKEFILE_LIST) | fgrep -v fgrep | fgrep -v help_line | grep -v 'Define the' | sed -e 's/\\$$//' | sort`; \
	for help_line in $${help_lines[@]}; do \
		help_command=`echo $$help_line | sed -e 's/^\(.*\): .*/\1/' -e 's/^ *//' -e 's/ *$$//' -e 's/:$$//'`; \
		help_info=`echo $$help_line | sed -e 's/.*#!\(.*\)$$/\1/' -e 's/^ *//' -e 's/ *$$//'`; \
		printf "%-19s %s\n" $$help_command $$help_info; \
	done;\
	if [ -n `echo $$HELP_SUFFIX|wc -w` ]; then \
		echo;\
		printf "%s\n" $$HELP_SUFFIX; \
	fi
# NOTE: If you want to add a HELP_SUFFIX, you have to export the variable as
# environment variable.
# Note II: wc -w is necessary, because HELP_SUFFIX might be a multi-line string



