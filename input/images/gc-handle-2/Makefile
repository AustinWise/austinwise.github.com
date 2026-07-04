
all: heap1.svg heap2.svg

.PHONY: all

%.svg: %.gv
	dot -Tsvg -o $@ $<
