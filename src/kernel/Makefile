all: kern kerninit

kerninit: kerninit.asm
	acme -f cbm $^

kern: kern.asm
	acme -f cbm $^

clean:
	rm -f kern kerninit