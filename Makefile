PREFIX=/mnt/ext/ard2/prefix
SSLDIR=$(PREFIX)/lib/ssl

.PHONY: zlib openssl curl cppunit

rtorrent: libtorrent ncurses curl
	cd rtorrent && \
	export ACLOCAL_PATH=$(PREFIX)/share/aclocal && \
	./autogen.sh && \
	./configure --prefix=$(PREFIX) && \
	make install


ncurses:
	cd ncurses && \
	./configure --with-termlib --with-ticlib --with-shared --disable-relink --with-widec --prefix=$(PREFIX) && \
	make install

cppunit:
	cd cppunit && \
	./autogen.sh && \
	./configure --prefix=$(PREFIX) && \
	make install

curl:
	cd curl && \
	./buildconf && \
	./configure --prefix=$(PREFIX) --with-ssl=$(SSLDIR) && \
	make install

libtorrent: openssl zlib cppunit
	cd libtorrent && \
	export ACLOCAL_PATH=$(PREFIX)/share/aclocal && \
	export CFLAGS="-fPIC" && \
       	./autogen.sh && \
	PKG_CONFIG_PATH=$(PREFIX)/lib/pkgconfig ./configure --prefix=$(PREFIX) --with-posix-fallocate && \
	make install

openssl:
	cd openssl && \
	export CFLAGS="-fPIC" && \
	./config shared -fPIC --prefix=$(PREFIX) --openssldir=$(SSLDIR) && \
	make install

zlib:
	cd zlib && \
	./configure --prefix=$(PREFIX) && \
	make install
