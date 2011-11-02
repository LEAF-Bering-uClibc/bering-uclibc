#####################################################
# 
# webconf - based on weblet buildtool.mk
# 
#####################################################
include $(MASTERMAKEFILE)

#####################################################
# Build webconf

REPODIR:=$(shell dirname `readlink buildtool.mk`)
TARGET_DIR:=$(BT_BUILD_DIR)/webconf

LINKS=	etc\
	var

$(LINKS):
	ln -s $(REPODIR)/$@ $@

source: .source 

.source: $(LINKS)
	touch .source

.build: .source
	mkdir -p $(TARGET_DIR)
	cp -aL etc var $(TARGET_DIR)
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch .build

build: .build

clean:
	rm -rf $(TARGET_DIR)
	rm -rf .build
	rm -rf .configured

srcclean: 
	rm -rf `cat .source`
	rm -f .source
	rm -f $(LINKS)

