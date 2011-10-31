#############################################################
#
# tcp-wrappers
#
#############################################################

include $(MASTERMAKEFILE)

TCP_WRAPPERS_DIR=tcp-wrappers-7.6.dbs.orig
TCP_WRAPPERS_BUILDDIR=$(BT_BUILD_DIR)/tcp_wrappers
TAR_DIR=tcp_wrappers_7.6
SOURCE_DIR=build-tree

BUILD_DIR := $(TCP_WRAPPERS_DIR)/$(SOURCE_DIR)/$(TAR_DIR)
REAL_DAEMON_DIR=/usr/sbin
STYLE = -DPROCESS_OPTIONS
#MYLIB = -lnsl
EXTRA_CFLAGS="-DSYS_ERRLIST_DEFINED -DHAVE_STRERROR -DHAVE_WEAKSYMS -D_REENTRANT -DINET6=1 -Dss_family=__ss_family -Dss_len=__ss_len"
COPTS="$(BT_COPT_FLAGS) -g"


$(TCP_WRAPPERS_DIR)/.source: 
	zcat $(TCP_WRAPPERS_SOURCE) | tar -xvf -
	zcat $(TCP_WRAPPERS_PATCH1) | patch -d $(TCP_WRAPPERS_DIR) -p1
	touch $(TCP_WRAPPERS_DIR)/.source


$(TCP_WRAPPERS_DIR)/.unpack: $(TCP_WRAPPERS_DIR)/.source
	# Force the creation of "stampdir" for make 3.82
	-mkdir $(TCP_WRAPPERS_DIR)/debian/stampdir
	$(MAKE) -C $(TCP_WRAPPERS_DIR) -f debian/sys-build.mk source.make 
	touch $(TCP_WRAPPERS_DIR)/.unpack

$(TCP_WRAPPERS_DIR)/.build: $(TCP_WRAPPERS_DIR)/.unpack
	$(MAKE) $(MAKEOPTS) CC=$(TARGET_CC) REAL_DAEMON_DIR=$(REAL_DAEMON_DIR) STYLE=$(STYLE) LIBS=$(MYLIB) \
	RANLIB=$(BT_RANLIB) ARFLAGS=rv AUX_OBJ=weak_symbols.o NETGROUP= TLI= VSYSLOG= BUGS= all \
	COPTS=$(COPTS) EXTRA_CFLAGS=$(EXTRA_CFLAGS) -C $(BUILD_DIR)

	mkdir -p $(TCP_WRAPPERS_BUILDDIR)/lib
	mkdir -p $(TCP_WRAPPERS_BUILDDIR)/usr/sbin
	mkdir -p $(TCP_WRAPPERS_BUILDDIR)/include/

	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/tcpd $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/tcpdchk $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/tcpdmatch $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/try-from $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/safe_finger $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/*.a $(TCP_WRAPPERS_BUILDDIR)/lib/ 	
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/shared/*.so* $(TCP_WRAPPERS_BUILDDIR)/lib/
	cp -a $(TCP_WRAPPERS_DIR)/build-tree/tcp_wrappers_7.6/tcpd.h $(TOOLCHAIN_DIR)/usr/include/ 
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $(TCP_WRAPPERS_BUILDDIR)/usr/sbin/*
	$(BT_STRIP) $(BT_STRIP_LIBOPTS) $(TCP_WRAPPERS_BUILDDIR)/lib/*.so.0
	cp -a $(TCP_WRAPPERS_BUILDDIR)/* $(BT_STAGING_DIR)
	cp -a $(TCP_WRAPPERS_BUILDDIR)/lib/*.a $(TOOLCHAIN_DIR)/lib
	touch $(TCP_WRAPPERS_DIR)/.build


source: $(TCP_WRAPPERS_DIR)/.source

build: $(TCP_WRAPPERS_DIR)/.build


clean:         
	-rm $(TCP_WRAPPERS_DIR)/.build
	-rm $(TCP_WRAPPERS_DIR)/.unpack
	$(MAKE) -C $(TCP_WRAPPERS_DIR) -f debian/sys-build.mk source.clean
	rm -rf $(TCP_WRAPPERS_BUILDDIR)
	-rm  $(BT_STAGING_DIR)/usr/lib/libwrap*
	-rm  $(BT_STAGING_DIR)/lib/libwrap*
	-rm  $(TOOLCHAIN_DIR)/lib/libwrap*

srcclean:
	rm -rf $(TCP_WRAPPERS_DIR)

