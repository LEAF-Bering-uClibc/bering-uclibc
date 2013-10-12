#############################################################
#
# ncurses
#
#############################################################


NCURSES_DIR=ncurses-5.5
NCURSES_BUILD_DIR=$(BT_BUILD_DIR)/ncurses

NCURSES_CFLAGS="-Os"

$(NCURSES_DIR)/.source:
	zcat $(NCURSES_SOURCE) | tar -xvf -
#	zcat $(NCURSES_PATCH1) | patch -d $(NCURSES_DIR) -p1
	touch $(NCURSES_DIR)/.source

$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.source
	(cd $(NCURSES_DIR); \
		DESTDIR=$(NCURSES_BUILD_DIR) \
		./configure --prefix=/usr \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_BUILD_NAME) \
		--with-shared \
		--mandir='$${datadir}/man' \
		--without-profile \
		--without-xterm-new \
		--without-debug \
		--disable-rpath \
		--enable-echo \
		--enable-const \
		--disable-big-core \
		--without-ada \
		--without-libtool \
		--disable-termcap \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--without-cxx-binding \
		--enable-overwrite;)
	touch $(NCURSES_DIR)/.configured


$(NCURSES_DIR)/.build: $(NCURSES_DIR)/.configured
	mkdir -p $(NCURSES_BUILD_DIR)
#build in single thread
	make -C $(NCURSES_DIR) sources
	make $(MAKEOPTS) -C $(NCURSES_DIR) all
	make -C $(NCURSES_DIR) install
	-$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(NCURSES_BUILD_DIR)/usr/lib/*
	ln -s $(NCURSES_BUILD_DIR)/usr/lib/libncurses.so.5 $(NCURSES_BUILD_DIR)/usr/lib/libtinfo.so.5
	ln -s $(NCURSES_BUILD_DIR)/usr/lib/libtinfo.so.5 $(NCURSES_BUILD_DIR)/usr/lib/libtinfo.so
	cp -a $(NCURSES_BUILD_DIR)/* $(BT_STAGING_DIR)
	touch $(NCURSES_DIR)/.build


source: $(NCURSES_DIR)/.source

build: $(NCURSES_DIR)/.build

clean:
	-rm $(NCURSES_DIR)/.build
	-rm -r $(NCURSES_BUILD_DIR)
	-make -C $(NCURSES_DIR) clean

srcclean:
	rm -rf $(NCURSES_DIR)


