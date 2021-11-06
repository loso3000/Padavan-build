THISDIR = $(shell pwd)
all:

clean:

romfs:
	./makedevlinks $(ROMFSDIR)
	$(ROMFSINST) /sbin/dev_init.sh
	$(ROMFSINST) /sbin/reset_ss.sh
	$(ROMFSINST) /sbin/mtd_storage.sh
	$(ROMFSINST) -p +x $(THISDIR)/wgetcurl.sh /sbin/wgetcurl.sh
	$(ROMFSINST) -p +x $(THISDIR)/copyscripts.sh /usr/bin/copyscripts.sh
	$(ROMFSINST) -p +x $(THISDIR)/autostart.sh /usr/bin/autostart.sh
ifeq ($(STORAGE_ENABLED),y)
	$(ROMFSINST) /sbin/automount.sh
endif
ifdef CONFIG_BLK_DEV_SD
	$(ROMFSINST) /sbin/hddtune.sh
	$(ROMFSINST) /sbin/spindown.sh
endif
	$(ROMFSINST) /etc_ro/ld.so.conf
	$(ROMFSINST) /etc_ro/protocols
	$(ROMFSINST) /etc_ro/services
	$(ROMFSINST) /etc_ro/profile
	$(ROMFSINST) /etc_ro/shells
	$(ROMFSINST) /etc_ro/mdev.conf
	$(ROMFSINST) /etc_ro/banner
	$(ROMFSINST) /etc_ro/script.tgz
	mkdir -p $(INSTALLDIR)/usr/share/terminfo
	tar -xzf ./terminfo.tar.gz -C $(INSTALLDIR)/usr/share
	mkdir -p $(INSTALLDIR)/etc/storage/
	tar -xzf $(THISDIR)/script.tgz -C $(INSTALLDIR)/etc/storage/
	$(ROMFSINST) /sbin/check_crontab.sh
