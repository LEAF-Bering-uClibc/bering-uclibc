#############################################################
#
# ncurses
#
#############################################################


NCURSES_DIR=ncurses-5.9
NCURSES_BUILD_DIR=$(BT_BUILD_DIR)/ncurses

$(NCURSES_DIR)/.source:
	zcat $(NCURSES_SOURCE) | tar -xvf -
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
		--without-tests \
		--without-xterm-new \
		--without-debug \
		--without-manpages \
		--disable-rpath \
		--disable-rpath-hack \
		--enable-echo \
		--enable-const \
		--disable-big-core \
		--without-ada \
		--without-libtool \
		--disable-termcap \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--without-cxx \
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
	cp -a $(NCURSES_BUILD_DIR)/* $(BT_STAGING_DIR)
	touch $(NCURSES_DIR)/.build


source: $(NCURSES_DIR)/.source

build: $(NCURSES_DIR)/.build

clean:
	-rm $(NCURSES_DIR)/.build
	-rm -r $(NCURSES_BUILD_DIR)
	-make -C $(NCURSES_DIR) clean

srcclean: clean
	rm -rf $(NCURSES_DIR)


