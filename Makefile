# Warble Linux — developer entry points
# https://github.com/warble-tech/warble-linux

.PHONY: help bake all-editions clean mock lint check test-artifacts release-check sync-bootloaders

EDITION ?= 1
MOCK_ONLY ?= 0
export EDITION MOCK_ONLY

help:
	@echo "Warble Linux"
	@echo ""
	@echo "  make bake EDITION=1|2|3|4   Build one edition (default: 1)"
	@echo "  make all-editions           Build editions 1–4"
	@echo "  make mock EDITION=4         Force mock artifacts"
	@echo "  make test-artifacts         Validate out/ (size, tar, OVF, checksums)"
	@echo "  make release-check          all-editions + test-artifacts"
	@echo "  make sync-bootloaders       Refresh syslinux/grub/efiboot from archiso"
	@echo "  make clean                  Remove out/ and work dirs"
	@echo "  make lint                   Shell syntax check"
	@echo "  make check                  lint + mock bake edition 1"
	@echo ""
	@echo "Editions: 1=minimal 2=developer 3=cloud-native 4=full"

bake:
	@chmod +x scripts/make-and-bake.sh
	./scripts/make-and-bake.sh

all-editions:
	@chmod +x scripts/build-all-editions.sh scripts/make-and-bake.sh
	./scripts/build-all-editions.sh

mock:
	MOCK_ONLY=1 $(MAKE) bake

clean:
	rm -rf out /tmp/warble-linux-work
	@echo "cleaned out/ and /tmp/warble-linux-work"

lint:
	@bash -n scripts/make-and-bake.sh
	@bash -n scripts/build-all-editions.sh
	@bash -n scripts/push-to-gcp.sh
	@bash -n scripts/test-artifacts.sh
	@bash -n scripts/sync-bootloaders.sh
	@bash -n scripts/docker-bake.sh
	@for f in profile/airootfs/usr/local/bin/*.sh profile/airootfs/etc/profile.d/*.sh; do \
	  bash -n "$$f" || exit 1; \
	done
	@echo "lint OK"

test-artifacts:
	@chmod +x scripts/test-artifacts.sh
	./scripts/test-artifacts.sh

release-check: lint
	@chmod +x scripts/build-all-editions.sh scripts/make-and-bake.sh scripts/test-artifacts.sh
	./scripts/build-all-editions.sh
	./scripts/test-artifacts.sh

check: lint
	MOCK_ONLY=1 EDITION=1 ./scripts/make-and-bake.sh
	@test -n "$$(ls out/MANIFEST-minimal-*.txt 2>/dev/null)"
	@test -n "$$(ls out/warble-linux-minimal-*.iso 2>/dev/null)"
	@test -d profile/syslinux && test -d profile/grub
	@echo "check OK (full matrix: make release-check)"

sync-bootloaders:
	@chmod +x scripts/sync-bootloaders.sh
	./scripts/sync-bootloaders.sh
