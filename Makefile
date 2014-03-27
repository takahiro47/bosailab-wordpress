.PHONY: run dev build mocha watch

dev:
	NODE_ENV=development \
	PORT=3001 \
	coffee ./config/web.coffee

run:
	NODE_ENV=production \
	PORT=3000 \
	nodectl start -W

build:
	grunt build

watch:
	grunt serve

mocha:
	NODE_ENV=test \
	./node_modules/.bin/mocha \
	--reporter nyan \
	--compilers coffee:coffee-script \
	--check-leaks \
	--slow 20 \
	tests

