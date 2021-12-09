.DEFAULT_GOAL := check

tests=tests.csv
test_sources=$(shell sed -s 1d $(tests) | cut -d, -f4 | sort -u)

and.noun.analizer.hfst: and.noun.generator.hfst
	hfst-invert $< -o $@

and.noun.generator.hfst: and.noun.lexd
	lexd $< | hfst-txt2fst -o $@
%.pass.txt: $(tests)
	awk -F, '$$4 == "$*" && $$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
%.ignore.txt: $(tests)
	awk -F, '$$4 == "$*" && $$3 == "ignore" {print $$1 ":" $$2}' $^ | sort -u > $@
check-gen: and.noun.generator.hfst $(foreach t,$(test_sources),$(t).pass.txt $(t).ignore.txt)
	for t in $(test_sources); do echo $$t; bash compare.sh $< $$t.ignore.txt; bash compare.sh $< $$t.pass.txt || exit $$?; done;
check: check-gen