#############################################################
#
# buildtool makefile for sshblack
#
#############################################################


SSHBLACK_DIR:=$(shell $(BT_TGZ_GETDIRNAME) $(SOURCE) 2>/dev/null)

.source:
	zcat $(SOURCE) | tar -xvf -
	touch .source

source: .source

.build: .source
	# Change default file to check for messages
	perl -i -p -e 's,/var/log/secure,/var/log/auth.log,' $(SSHBLACK_DIR)/sshblack.pl
	# Change default whitelist network address
	perl -i -p -e 's,192\\.168\\.0,192\\.168\\.1\\.,' $(SSHBLACK_DIR)/sshblack.pl
	# Change default ADDRULE command
	perl -i -p -e 's,/sbin/iptables -I BLACKLIST -s ipaddress -j DROP,/sbin/shorewall drop ipaddress,' $(SSHBLACK_DIR)/sshblack.pl
	# Change default DELRULE command
	perl -i -p -e 's,/sbin/iptables -D BLACKLIST -s ipaddress -j DROP,/sbin/shorewall allow ipaddress,' $(SSHBLACK_DIR)/sshblack.pl
	# Change default REASONS text
	perl -i -p -e 's,Failed password\|Failed none,Login attempt for nonexistent user\|Bad password attempt,' $(SSHBLACK_DIR)/sshblack.pl
	# Change default to *not* email administrator
	perl -i -p -e 's,EMAILME\) = 1,EMAILME\) = 0,' $(SSHBLACK_DIR)/sshblack.pl
#
	cp -a $(SSHBLACK_DIR)/sshblack.pl $(BT_STAGING_DIR)/usr/sbin/
	cp -aL sshblack.init $(BT_STAGING_DIR)/etc/init.d/sshblack
	touch .build

build: .build

clean:
	rm -f .build

srcclean: clean
	rm -rf $(SSHBLACK_DIR)
	rm -f .source
