#############################################################
#
# cron
#
# $Id: buildtool.mk,v 1.2 2010/10/30 16:26:58 nitr0man Exp $
#############################################################

include $(MASTERMAKEFILE)
DIR:=dry2
TARGET_DIR:=$(BT_BUILD_DIR)/dry2


$(DIR)/.source: 
	mkdir -p $(DIR)
	zcat $(SOURCE) >$(DIR)/dry.c
	touch $(DIR)/.source

$(DIR)/.build: $(DIR)/.source
	mkdir -p $(TARGET_DIR)/usr/bin
#i386 reference
	$(TARGET_CC) -c -O3 -march=i386 $(DIR)/dry.c -o $(DIR)/dry1.o
	$(TARGET_CC) -DPASS2 -O3 -march=i386 $(DIR)/dry.c $(DIR)/dry1.o -o $(DIR)/dry2_i386
#i486 reference
	$(TARGET_CC) -c -O3 -march=i486 $(DIR)/dry.c -o $(DIR)/dry1.o
	$(TARGET_CC) -DPASS2 -O3 -march=i486 $(DIR)/dry.c $(DIR)/dry1.o -o $(DIR)/dry2_i486
#i486 tuned to i686
	$(TARGET_CC) -c -O3 -march=i486 -mtune=i686 $(DIR)/dry.c -o $(DIR)/dry1.o
	$(TARGET_CC) -DPASS2 -O3 -march=i486 -mtune=pentiumpro $(DIR)/dry.c $(DIR)/dry1.o -o $(DIR)/dry2_i486t
#i586 reference
	$(TARGET_CC) -c -O3 -march=i586 $(DIR)/dry.c -o $(DIR)/dry1.o
	$(TARGET_CC) -DPASS2 -O3 -march=i586 $(DIR)/dry.c $(DIR)/dry1.o -o $(DIR)/dry2_i586
#i686 reference
	$(TARGET_CC) -c -O3 -march=i686 $(DIR)/dry.c -o $(DIR)/dry1.o
	$(TARGET_CC) -DPASS2 -O3 -march=i686 $(DIR)/dry.c $(DIR)/dry1.o -o $(DIR)/dry2_i686
	cp $(DIR)/dry2_* $(TARGET_DIR)/usr/bin
	-$(BT_STRIP) -s $(TARGET_DIR)/usr/bin/*
	cp -a $(TARGET_DIR)/* $(BT_STAGING_DIR)
	touch $(DIR)/.build

source: $(DIR)/.source 

build: $(DIR)/.build

clean:
	-rm $(DIR)/.build $(DIR)/*.o $(DIR)/dry2_*
  
srcclean:
	rm -rf $(DIR)
