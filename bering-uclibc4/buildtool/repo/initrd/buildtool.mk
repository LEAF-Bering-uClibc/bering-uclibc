# makefile for initrd
include $(MASTERMAKEFILE)

INITRD_DIR=.
INITRD_TARGET_DIR:=$(BT_BUILD_DIR)/config
ESCKEY=$(shell echo "a\nb"|awk '/\\n/ {print "-e"}')

$(INITRD_DIR)/.source:
	touch $(INITRD_DIR)/.source

source: $(INITRD_DIR)/.source
                        
$(INITRD_DIR)/.configured: $(INITRD_DIR)/.source
	touch $(INITRD_DIR)/.configured
                                                                 
$(INITRD_DIR)/.build: $(INITRD_DIR)/.configured
	mkdir -p $(INITRD_TARGET_DIR)
	mkdir -p $(INITRD_TARGET_DIR)/var/lib/lrpkg
	mkdir -p $(INITRD_TARGET_DIR)/boot/etc
	
	echo $(ESCKEY) "isofs\nvfat">$(INITRD_TARGET_DIR)/boot/etc/modules
	(for a in $(KARCHS); do \
	BT_STAGING_DIR=$(BT_STAGING_DIR) BT_KERNEL_RELEASE=$(BT_KERNEL_RELEASE)-$$a \
		    sh $(BT_TOOLS_DIR)/getdep.sh "ata_.*" ahci ehci-hcd uhci-hcd \
		    ohci-hcd usb-storage sd_mod sr_mod isofs vfat floppy usbhid >mod ; \
	[ -f files.$$a ] && rm -f files.$$a ; \
	for m in `cat mod`; do echo $(ESCKEY) "<File>\n\tSource\t= lib/modules/__KVER__-$$a/$$m \n\t\
	Filename\t= lib/modules/$$(echo $$m|sed 's/[a-z]*\/[a-z_/-]*\///g')\n\t\
	Type\t= binary\n\tType\t= module\n\tPermissions\t= 644\n</File>">>files.$$a; done; done)
	    
	cp -aL README $(INITRD_TARGET_DIR)/boot/etc	
	cp -aL root.linuxrc $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -aL root.helper $(INITRD_TARGET_DIR)/var/lib/lrpkg
	cp -a $(INITRD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(INITRD_DIR)/.build

build: $(INITRD_DIR)/.build
                                                                                         
clean:
	rm -rf $(INITRD_TARGET_DIR)
	rm -f $(INITRD_DIR)/.build
	rm -f $(INITRD_DIR)/.configured
                                                                                                                 
srcclean: clean
	rm -f $(INITRD_DIR)/.source
	rm -f $(INITRD_DIR)/root.linuxrc	
	rm -f $(INITRD_DIR)/modules
	rm -f $(INITRD_DIR)/README
				
