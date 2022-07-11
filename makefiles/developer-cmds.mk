ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

SUBPROJECTS            += developer-cmds
DEVELOPER-CMDS_VERSION := 66
DEB_DEVELOPER-CMDS_V   ?= $(DEVELOPER-CMDS_VERSION)-1

developer-cmds-setup: setup
	curl --silent -L -Z --create-dirs -C - --remote-name-all --output-dir $(BUILD_SOURCE) https://opensource.apple.com/tarballs/developer_cmds/developer_cmds-$(DEVELOPER-CMDS_VERSION).tar.gz
	$(call EXTRACT_TAR,developer_cmds-$(DEVELOPER-CMDS_VERSION).tar.gz,developer_cmds-$(DEVELOPER-CMDS_VERSION),developer-cmds)
	mkdir -p $(BUILD_STAGE)/developer-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1/}

ifneq ($(wildcard $(BUILD_WORK)/developer-cmds/.build_complete),)
developer-cmds:
	@echo "Using previously built developer-cmds."
else
developer-cmds: developer-cmds-setup
	cd $(BUILD_WORK)/developer-cmds; \
	for bin in ctags rpcgen unifdef; do \
		$(CC) $(CFLAGS) $(LDFLAGS) -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/developer-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$bin $$bin/*.c -D_POSIX_C_SOURCE=200112L -DS_IREAD=S_IRUSR -DS_IWRITE=S_IWUSR; \
		$(INSTALL) -Dm644 $$bin/$$bin.1 $(BUILD_STAGE)/developer-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/; \
	done
	$(call AFTER_BUILD)
endif

developer-cmds-package: developer-cmds-stage
	# developer-cmds.mk Package Structure
	rm -rf $(BUILD_DIST)/developer-cmds

	# developer-cmds.mk Prep developer-cmds
	cp -a $(BUILD_STAGE)/developer-cmds $(BUILD_DIST)

	# developer-cmds.mk Sign
	$(call SIGN,developer-cmds,general.xml)

	# developer-cmds.mk Make .debs
	$(call PACK,developer-cmds,DEB_DEVELOPER-CMDS_V)

	# developer-cmds.mk Build cleanup
	rm -rf $(BUILD_DIST)/developer-cmds

.PHONY: developer-cmds developer-cmds-package

endif # ($(MEMO_TARGET),darwin-\*)
