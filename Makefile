CC=lazbuild
ST=strip
datadir  = $(DESTDIR)/usr/share/cqrtest
bindir   = $(DESTDIR)/usr/bin
sharedir = $(DESTDIR)/usr/share

cqrtest: src/cqrtest.lpi
	$(CC) --ws=gtk2 src/cqrtest.lpi
	$(ST) src/cqrtest

clean:
	rm -f -v src/*.o src/*.ppu src/*.bak src/lnet/lib/*.ppu src/lnet/lib/*.o src/lnet/lib/*.bak src/cqrtest src/cqrtest.compiled debian/cqrtest.*  src/cqrtest.or
	
install:
	install -d -v         $(bindir)
	install -d -v         $(datadir)
	install -d -v         $(datadir)/ctyfiles
	install -d -v	      $(datadir)/images		
	install -d -v         $(sharedir)/pixmaps/cqrtest
	install    -v -m 0755 src/cqrtest $(bindir)
	install    -v -m 0755 tools/cqrtest-apparmor-fix $(datadir)/cqrtest-apparmor-fix
	install    -v -m 0644 ctyfiles/* $(datadir)/ctyfiles/
	install    -v -m 0644 tools/cqrtest.desktop $(sharedir)/applications/cqrtest.desktop
	install    -v -m 0644 images/cqrtest.png $(sharedir)/pixmaps/cqrtest/cqrtest.png
	install    -v -m 0644 images/cqrtest.png $(sharedir)/icons/cqrtest.png
	install    -v -m 0644 images/*   $(datadir)/images/
deb:
	dpkg-buildpackage -rfakeroot -i -I
deb_src:
	dpkg-buildpackage -rfakeroot -i -I -S
