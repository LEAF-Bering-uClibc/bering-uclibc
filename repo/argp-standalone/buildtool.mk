# makefile for argp-standalone
include $(MASTERMAKEFILE)

ARGP-STANDALONE_DIR:=argp-standalone-1.4-test2
ARGP-STANDALONE_TARGET_DIR:=$(BT_BUILD_DIR)/argp-standalone

.source:
	zcat $(ARGP-STANDALONE_SOURCE) | tar -xvf -
	cat $(ARGP-STANDALONE_PATCH1) | patch -d $(ARGP-STANDALONE_DIR) -p1       
	touch .source

source: .source

$(ARGP-STANDALONE_DIR)/.configured: .source
	(cd $(ARGP-STANDALONE_DIR) ; autoreconf -i -f && \
	./configure --prefix=/usr/ \
	--build=$(GNU_BUILD_NAME) \
	--host=$(GNU_TARGET_NAME) )
	touch $(ARGP-STANDALONE_DIR)/.configured

$(ARGP-STANDALONE_DIR)/.build: $(ARGP-STANDALONE_DIR)/.configured
	mkdir -p $(ARGP-STANDALONE_TARGET_DIR)/usr/include
	mkdir -p $(ARGP-STANDALONE_TARGET_DIR)/usr/lib
	make $(MAKEOPTS) -C $(ARGP-STANDALONE_DIR) DESTDIR=$(ARGP-STANDALONE_TARGET_DIR)
	cp -a $(ARGP-STANDALONE_DIR)/argp.h  $(ARGP-STANDALONE_TARGET_DIR)/usr/include  
	cp -a $(ARGP-STANDALONE_DIR)/libargp.a $(ARGP-STANDALONE_TARGET_DIR)/usr/lib
	cp -a $(ARGP-STANDALONE_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(ARGP-STANDALONE_DIR)/.build

build: $(ARGP-STANDALONE_DIR)/.build

clean:
	make -C $(ARGP-STANDALONE_DIR) clean
	rm -rf $(ARGP-STANDALONE_TARGET_DIR)
	rm -f $(ARGP-STANDALONE_DIR)/.build
	rm -f $(ARGP-STANDALONE_DIR)/.configured

srcclean: clean
	rm -rf $(ARGP-STANDALONE_DIR)
	rm -f .source
