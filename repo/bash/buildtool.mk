# makefile for bash
include $(MASTERMAKEFILE)

BASH_DIR:=bash-4.2
BASH_TARGET_DIR:=$(BT_BUILD_DIR)/bash
export bash_cv_job_control_missing=no

$(BASH_DIR)/.source:
	zcat $(BASH_SOURCE) | tar -xvf -
	touch $(BASH_DIR)/.source

source: $(BASH_DIR)/.source

$(BASH_DIR)/.configured: $(BASH_DIR)/.source
	(cd $(BASH_DIR) ; ./configure \
			--host=$(GNU_TARGET_NAME) \
			--with-curses --disable-net-redirections --prefix=/ \
			--infodir=/usr/share/info --mandir=/usr/share/man \
			--enable-command-timing \
			--enable-debugger \
			--enable-job-control \
			--enable-history \
			--enable-readline \
			--disable-nls --disable-rpath )
	touch $(BASH_DIR)/.configured

$(BASH_DIR)/.built: $(BASH_DIR)/.configured
	mkdir -p $(BASH_TARGET_DIR)
	mkdir -p $(BASH_TARGET_DIR)/bin
	make $(MAKEOPTS) -C $(BASH_DIR) all
	cp -a $(BASH_DIR)/bash $(BASH_TARGET_DIR)/bin
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(BASH_TARGET_DIR)/bin/*
	cp -a $(BASH_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(BASH_DIR)/.built

build: $(BASH_DIR)/.built

clean:
	make -C $(BASH_DIR) clean
	rm $(BASH_DIR)/.build $(BASH_DIR)/.configured
	rm -rf $(BASH_TARGET_DIR)

srcclean: clean
	rm -rf $(BASH_DIR)

