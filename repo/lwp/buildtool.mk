#############################################################
#
# lwp
#
#############################################################

include $(MASTERMAKEFILE)

.source:
	zcat $(LWP_SOURCE) | tar -xvf -
	touch .source

source: .source

build: .source
	mkdir -p var/webconf/www
	mkdir -p etc/webconf
	mkdir -p var/webconf/lib
	mkdir -p var/webconf/templates
	
	cp dropbear.cgi var/webconf/www
	cp config.cgi var/webconf/www

clean:
	rm -rf var
	rm -rf etc
	rm -rf .source
