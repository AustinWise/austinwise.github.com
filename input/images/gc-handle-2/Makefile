
all: naive.svg heap1.svg heap2.svg heap3.svg

.PHONY: all

%.svg: %.gv
	dot -Tsvg -o $@ $<
