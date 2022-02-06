#!make

build:
	@bash github-showcase

update:
	@bash github-showcase

publish: build
	@git add . && git commit -am "Publish updates" || true
	@git push || true
