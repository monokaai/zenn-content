SHELL := /bin/bash

.PHONY: help install init article book preview

DEFAULT_GOAL := help

help:
	@echo "Zenn CLI Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  install        Install dependencies (npm install)"
	@echo "  init           Initialize Zenn directories (zenn init)"
	@echo "  article        Create new article: make article SLUG=xxx TITLE=\"Title\" [TYPE=tech|idea]"
	@echo "  book           Create new book: make book SLUG=xxx TITLE=\"Title\""
	@echo "  preview        Launch preview server"
	@echo ""
	@echo "Examples:"
	@echo "  make install"
	@echo "  make init"
	@echo "  make article SLUG=my-first TITLE=\"My First Article\" TYPE=tech"
	@echo "  make book SLUG=my-book TITLE=\"My Book\""
	@echo "  make preview"

install:
	npm install

init:
	npx zenn init

article:
	@test -n "$(SLUG)" -a -n "$(TITLE)" || (echo "Usage: make article SLUG=xxx TITLE=\"Title\" [TYPE=tech|idea]"; exit 1)
	@CMD="npx zenn new:article --slug \"$(SLUG)\" --title \"$(TITLE)\""; \
	if [ -n "$(TYPE)" ]; then CMD="$$CMD --type $(TYPE)"; fi; \
	echo "$$CMD"; eval "$$CMD"

book:
	@test -n "$(SLUG)" -a -n "$(TITLE)" || (echo "Usage: make book SLUG=xxx TITLE=\"Title\""; exit 1)
	npx zenn new:book --slug "$(SLUG)" --title "$(TITLE)"

preview:
	npx zenn preview --open


