all: sw run

sw:
	x10c++ -STATIC_CHECKS -NO_CHECKS -O -report postcompile=5 -o sw ssca1/SW.x10
swd:
	x10c++ -STATIC_CHECKS -report postcompile=5 -o sw ssca1/SW.x10

run:
	export X10_NPLACES=1; ./sw -s ../data/short9.txt -l ../data/long9.txt -p ../data/baseDNA.txt -r 4
	export X10_NPLACES=2; ./sw -s ../data/short9.txt -l ../data/long9.txt -p ../data/baseDNA.txt -r 4 

clean:
	rm -fR sw *.dSYM ssca1/*.h ssca1/*.cc ssca1/*.inc ssca1/*.struct_h
