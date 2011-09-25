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
	mkdir -p $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/webconf
	mkdir -p $(TARGET_DIR)/var/webconf
	cp -a etc/init.d/webconf $(TARGET_DIR)/etc/init.d
	cp -a etc/webconf/* $(TARGET_DIR)/etc/webconf
	cp -a var/webconf/* $(TARGET_DIR)/var/webconf
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

