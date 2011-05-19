#############################################################
#
# kmodules
#
#############################################################

include $(MASTERMAKEFILE)

source: 
	# nothing to be done

build:
	(for i in $(KARCHS); do \
	sed 's,__KVER__,__KVER__-'"$$i"',g' common.cfg >common-$$i.cfg ; \
	sed 's,__KVER__,__KVER__-'"$$i"',g' modern.cfg >modern-$$i.cfg ; \
	done)

# add wlan drivers to common-geode.cfg
	sed 's,__KVER__,__KVER__-'geode',g' geode-wlan.cfg >>common-geode.cfg ;


	# nothing to be done

clean:
	# nothing to be done
