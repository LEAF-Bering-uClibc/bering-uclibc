#############################################################
#
# lwp
#
#############################################################

include $(MASTERMAKEFILE)

.source:
	touch .source

source: .source

build: .source
	mkdir -p var/webconf/www
	mkdir -p etc/webconf
	
	cp dropbear.cgi var/webconf/www
	cp config.cgi var/webconf/www
	cp pppoe.cgi var/webconf/www
	cp leafcfg.cgi var/webconf/www
	cp webipv6.cgi var/webconf/www
	cp keyboard.cgi var/webconf/www
	cp lrcfg.cgi var/webconf/www
	cp dnsmasq.cgi var/webconf/www
	cp blurb.expert var/webconf/www

	cp config.webconf etc/webconf
	cp dnsmasq.webconf etc/webconf
	cp dropbear.webconf etc/webconf
	cp keyboard.webconf etc/webconf
	cp pppoe.webconf etc/webconf
	cp webconf-expert.webconf etc/webconf
	cp webipv6.webconf etc/webconf

clean:
	rm -rf var
	rm -rf etc
	rm -rf .source
