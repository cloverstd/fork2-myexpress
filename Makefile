SRC ?= src
DEST ?= lib
FILES ?= test
PATTERN ?= ''

test: compile
	mocha $(FILES) -g $(PATTERN)

compile:
	coffee --compile --output $(DEST) $(SRC)


.PHONY: compile
