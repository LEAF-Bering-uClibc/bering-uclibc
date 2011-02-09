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

build:
	# nothing to be done

clean:
	rm -rf var
	rm -rf etc
	rm -rf .source
