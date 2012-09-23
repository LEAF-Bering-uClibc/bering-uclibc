# makefile for keyboard

KEYBOARD_DIR=.
KEYBOARD_TARGET_DIR:=$(BT_BUILD_DIR)/config

$(KEYBOARD_DIR)/.source:
	touch $(KEYBOARD_DIR)/.source

source: $(KEYBOARD_DIR)/.source

$(KEYBOARD_DIR)/.build: $(KEYBOARD_DIR)/.source
	mkdir -p $(KEYBOARD_TARGET_DIR)
	mkdir -p $(KEYBOARD_TARGET_DIR)/etc/init.d
	mkdir -p $(KEYBOARD_TARGET_DIR)/etc/default
	mkdir -p $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL keyboard.init $(KEYBOARD_TARGET_DIR)/etc/init.d/keyboard
	cp -aL keyboard.default $(KEYBOARD_TARGET_DIR)/etc/default/keyboard
	cp -aL azerty.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL be.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL bg.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL br-a.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL cf.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL croat.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL cz.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
#	cp -aL de-latin1.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL de.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL dk.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL dvorak.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL es.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL et.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
#	cp -aL fi-latin1.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL fi.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
#	cp -aL fr-latin1.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL fr.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL gr.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL hu.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL il.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL is.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL it.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL jp.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL la.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL lt.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL mk.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL nl.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL no.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL pl.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL pt.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL ro.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL ru.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL se.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL sg.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL sk-y.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL sk-z.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL slovene.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL trf.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL trq.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL ua.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL uk.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL us.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps
	cp -aL wangbe.map $(KEYBOARD_TARGET_DIR)/usr/share/keymaps

	cp -a $(KEYBOARD_TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(KEYBOARD_DIR)/.build

build: $(KEYBOARD_DIR)/.build

clean:
	rm -rf $(KEYBOARD_TARGET_DIR)
	rm -f $(KEYBOARD_DIR)/.build

srcclean: clean
	rm -f $(KEYBOARD_DIR)/.source
