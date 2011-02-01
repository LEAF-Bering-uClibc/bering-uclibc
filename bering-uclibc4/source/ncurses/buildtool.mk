#############################################################
#
# ncurses
#
# $Id: buildtool.mk,v 1.2 2010/09/18 08:52:38 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)

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
		CC=$(TARGET_CC) \
		AR=$(BT_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ar \
		LD=$(BT_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ld \
		RANLIB=$(BT_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-ranlib \
		CFLAGS=$(NCURSES_CFLAGS)  \
		./configure --prefix=/usr \
		--target=i386-pc-linux-gnu \
		--with-build-libs="$(BT_STAGING_DIR)/lib" \
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
	make -C $(NCURSES_DIR) CC=$(TARGET_CC)
	make -C $(NCURSES_DIR) install
	$(BT_STRIP) --strip-unneeded $(NCURSES_BUILD_DIR)/usr/lib/libform.so.5.5
	$(BT_STRIP) --strip-unneeded $(NCURSES_BUILD_DIR)/usr/lib/libmenu.so.5.5
	$(BT_STRIP) --strip-unneeded $(NCURSES_BUILD_DIR)/usr/lib/libncurses.so.5.5
	$(BT_STRIP) --strip-unneeded $(NCURSES_BUILD_DIR)/usr/lib/libpanel.so.5.5
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


