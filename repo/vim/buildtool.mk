# makefile for vim

VIM_DIR:=$(CURDIR)/$(shell $(BT_TGZ_GETDIRNAME) $(VIM_SOURCE) 2>/dev/null )
VIM_TARGET_DIR:=$(BT_BUILD_DIR)/vim

# Variable definitions for 'configure'
CONFDEFS = vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes             \
	vim_cv_tty_group=world          \
	vim_cv_getcwd_broken=no         \
	vim_cv_stat_ignores_slash=no    \
	vim_cv_memmove_handles_overlap=yes

CONFOPTS:=--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
	--host=$(GNU_TARGET_NAME)     \
	--build=$(GNU_BUILD_NAME)     \
	--target=$(GNU_TARGET_NAME)   \
	--with-tlib=ncurses           \
	--disable-darwin              \
	--disable-selinux             \
	--disable-xsmp                \
	--disable-xsmp-interact       \
	--disable-netbeans            \
	--with-features=tiny

.source:
	$(BT_SETUP_BUILDDIR) -v $(VIM_SOURCE)
	touch .source

source: .source

.configure: .source
	( cd $(VIM_DIR)/src ; $(CONFDEFS) ./configure $(CONFOPTS) )
	touch .configure

.build: .configure
	mkdir -p $(VIM_TARGET_DIR)/usr/bin
	make -C $(VIM_DIR)/src $(MAKEOPTS)
	cp -a $(VIM_DIR)/src/vim $(VIM_TARGET_DIR)/usr/bin/vim
	-$(BT_STRIP) $(BT_STRIP_BINOPTS) $(VIM_TARGET_DIR)/bin/*
	cp -a $(VIM_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	rm -rf $(VIM_TARGET_DIR)
	make -C $(VIM_DIR)/src clean
	rm -f .build .configured

srcclean: clean
	rm -rf $(VIM_DIR)
	-rm .source
