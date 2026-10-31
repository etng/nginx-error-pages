all:
	@python generate.py
	@echo "update error_pages.conf"
	@sed 's|__NEP_ROOT__|$(CURDIR)|g' snippets/error_pages.conf.tpl > snippets/error_pages.conf
	@echo done, include the following line to your nginx site config
	@realpath snippets/error_pages.conf
clean:
	find . -maxdepth 1 -iname '[0-9][0-9][0-9].html' -not -iname '418.html' -exec rm \{\} \;
