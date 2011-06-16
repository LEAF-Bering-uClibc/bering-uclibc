include $(MASTERMAKEFILE)

ifenslave.c:
	cp $(BT_LINUX_DIR)-$(BT_KERNEL_RELEASE)/Documentation/networking/ifenslave.c $@

ifenslave: ifenslave.c
	$(TARGET_CC) $(BT_COPT_FLAGS) $< -o $@
	$(BT_STRIP) $(BT_STRIP_BINOPTS) $@
	mkdir -p $(BT_STAGING_DIR)/sbin
	mkdir -p $(BT_STAGING_DIR)/etc/network/if-up.d
	mkdir -p $(BT_STAGING_DIR)/etc/network/if-down.d
	cp -aL -f $@ $(BT_STAGING_DIR)/sbin/
	cp -aL -f $(IFENSLAVE_IFUP) $(BT_STAGING_DIR)/etc/network/if-up.d/ifenslave
	cp -aL -f $(IFENSLAVE_IFDOWN) $(BT_STAGING_DIR)/etc/network/if-down.d/ifenslave

source: ifenslave.c

build: ifenslave

clean:
	rm -f $(BT_STAGING_DIR)/sbin/ifenslave
	rm -f $(BT_STAGING_DIR)/etc/network/if-up.d/ifenslave
	rm -f $(BT_STAGING_DIR)/etc/network/if-down.d/ifenslave
	rm -f ifenslave

srcclean:
	rm -f ifenslave.c
