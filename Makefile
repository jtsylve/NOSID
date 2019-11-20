all:
	(cd src/kernel && ${MAKE})
	(cd src/loader && ${MAKE})

clean:
	(cd src/kernel && ${MAKE} clean)
	(cd src/loader && ${MAKE} clean)
	rm -f nosid.d64

nosid.d64: clean all
	c1541 -format nosid,00 d64 $@
	c1541 -attach $@ -write src/loader/loader.prg 	loader.prg
	c1541 -attach $@ -write src/kernel/kern 		kern

run: nosid.d64
	x64 nosid.d64