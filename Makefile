.DEFAULT_GOAL := all

# M1 macs may need to switch back to x86, until arm releases are available
EMULATE_X86 =
ifeq ($(shell uname -sm),Darwin arm64)
EMULATE_X86 = arch -x86_64
endif

OS = $(shell uname -s)
ARCH = $(shell $(EMULATE_X86) uname -m)

BIN := .bin
$(BIN):
	@mkdir -p $@

# https://docs.buf.build/
# changing BUF_VERSION will automatically download and use the specified version.
BUF_VERSION = 0.36.0
BUF_URL = https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(OS)-$(ARCH)
# use BUF_VERSION_BIN as a bin prerequisite, not "buf", so the correct version will be used.
BUF_VERSION_BIN = buf-$(BUF_VERSION)
$(BIN)/$(BUF_VERSION_BIN): | $(BIN)
	@echo "downloading buf $(BUF_VERSION)"
	@curl -sSL $(BUF_URL) -o $@
	@chmod +x $@

PROTO_ROOT := proto
PROTO_FILES = $(shell find ./$(PROTO_ROOT) -name "*.proto")
PROTO_DIRS = $(sort $(dir $(PROTO_FILES)))
proto-lint: $(PROTO_FILES) $(BIN)/$(BUF_VERSION_BIN)
	@$(BIN)/$(BUF_VERSION_BIN) lint

all: proto-lint

# generally not necessary unless we change library versions, but this DOES impact codegen
# formatting because it inherits that from the version of Go used to build tools.
clean:
	rm -rf $(BIN)
