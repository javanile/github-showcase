#!make

build:
	@bash bin/github-showcase.sh

publish: build
	@git add . && git commit -am "Publish updates" || true
	@git push || true
