VPATH=src
BUILDDIR=lib

BEANDIR=.
JSONDIR=.

LIB_SOURCES= $(wildcard $(VPATH)/*.coffee)
LIB_TARGETS=$(patsubst $(VPATH)/%.coffee, $(BUILDDIR)/%.js, $(LIB_SOURCES))

BEAN_FILES=$(wildcard $(BEANDIR)/*.bean)
JSON_FILES=$(patsubst $(BEANDIR)/%.bean, $(JSONDIR)/%.json, $(BEAN_FILES))

all: build

.PHONY: build
build: node_modules objects

.PHONY: objects
objects: $(LIB_TARGETS) $(JSON_FILES)

$(JSONDIR)/%.json: $(BEANDIR)/%.bean
	./node_modules/.bin/bean --source $<

.PHONY: test
test: build
	./node_modules/.bin/testlet

.PHONY: clean
clean:
	rm -f $(COFFEE_OBJECTS)

.PHONE: pristine
pristine: clean
	rm -rf node_modules

node_modules:
	npm install -d

lib/%.js: src/%.coffee
	coffee -o lib -c $<

.PHONY: watch
watch:
	coffee --watch -o $(BUILDDIR) -c $(VPATH)

.PHONY: start
start:	all
	./node_modules/.bin/supervisor -w lib,src,src/express,src/mongodb,views -e coffee,hbs,js,json -q server.js

