.PHONY: $(shell ls)
.SILENT:

OPT = -w -Mstrict -Mv5.10 -MData::Dumper   -Mblib #-MData::Show
vi  = vi -p  -c 'set nofoldenable'

current = 10_basic.t
current = 01c_coverage.t
current = 01b_pod.t
current = 08_script.t
current = 10_legal.t
current = 12_find_author.t
current = 13_annotate.t
current = 14_deannotate.t
current = 15_howl_notice.t
current = 16_license_type.t
current = 17_license_text.t
current = 21_values.t
current = 11_load_meta.t

#all:add
##all: t
#all: pod
all: $(current)

tel:
	$(vi)  ../examples/script/tel2num.pl   ../examples/script/tel2mnemonic.pl
1* 0* 2*:
	perl $(OPT) $@
license_injector li:
	perl $(OPT) ../script/license-injector.pl  ../examples   check
check remove t list:
	#perl $(OPT) ../script/copyright-injector.pl -d  ../examples   $@
	perl $(OPT) ../script/license-injector.pl -d  ../examples   $@
add:
	perl $(OPT) ../script/license-injector.pl -d  ../examples  $@
pod: 
	perldoc  ../blib/lib/Test/Legal.pm 
podu: 
	perldoc -f ../blib/lib/Test/Legal/Util.pm 
vi: w
	$(vi) $(current)  ../blib/lib/Test/Legal.pm
pvi: w
	$(vi) -c 'set foldenable' ../blib/lib/Test/Legal.pm
pviu: w
	$(vi)  -c 'set foldenable' ../blib/lib/Test/Legal/Util.pm
vici: w
	$(vi) ../script/copyright-injector.pl  ../blib/lib/Test/Legal.pm
viciu: w
	$(vi) ../script/copyright-injector.pl  ../blib/lib/Test/Legal/Util.pm
vili: w
	$(vi) ../script/license-injector.pl  ../blib/lib/Test/Legal.pm
viliu: w
	$(vi) ../script/license-injector.pl  ../blib/lib/Test/Legal/Util.pm
viu: w
	$(vi) $(current)  ../blib/lib/Test/Legal/Util.pm
b: w
	$(vi) ../blib/lib/Test/Legal.pm  ../blib/lib/Test/Legal/Util.pm
prove:
	prove t
w:
	chmod -R u+w ../blib/lib
cp:
	cp ../blib/lib/Test/Legal.pm ../lib/Test
	cp ../blib/lib/Test/Legal/Util.pm ../lib/Test/Legal/Util.pm
test:
	make -C ../ test
help:
	echo vi pod prove test 
