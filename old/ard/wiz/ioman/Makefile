C=cc
S=as
LD=gcc
#.gold
ENTRY=go
LDFLAGS=
#-e $(ENTRY) -M --verbose -N

all:	m
m:	main.o
	$(LD) -lc -ludev -lblkid $(LDFLAGS) -o $@ $^ /usr/lib/x86_64-linux-gnu/libc_nonshared.a

h:	ioman.o
	$(LD) $(LDFLAGS) -o $@ $^
	strip -s -R .note -R .note.gnu.gold-version -R .bss h
	objdump -M x86-64 -xd h
.c.o:
	$C -O0 -g -c $< -o $@
.s.o:
	$S -c $< -o $@
.PHONY: clean
clean:
	-rm *.o
