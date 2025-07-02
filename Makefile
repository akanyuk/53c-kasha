ifeq ($(PROJECT_NAME),)
	PROJECT_NAME := $(shell basename "`pwd`")
endif

NAME_SUFFIX = $(shell date +%Y%m%d)-$(shell git log --format="%h" -n 1)

.PHONY: all build clean help

all: build

build: $(PARTS:%=build/%.bin.zx0) ## Default: build project
	@printf "\033[32mBuilding '$(PROJECT_NAME)'\033[0m\n"

	rm -f build/*.trd

	sjasmplus --fullpath --color=off --inc=src/. \
		-DSNA_FILENAME=\"build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna\" \
		-DTRD_FILENAME=\"build/$(PROJECT_NAME).trd\" \
		src/main.asm

ifneq ($(COPY_SNAPSHOT_TO),)
	cp --force build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna $(COPY_SNAPSHOT_TO)
endif

	@printf "\033[32mDone\033[0m\n"

ifneq ($(EMULATOR_BINARY),)
	$(EMULATOR_BINARY) build/$(PROJECT_NAME)-$(NAME_SUFFIX).sna
endif

clean: ## Remove all artifacts
	rm -f build/*

help: 	## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-8s\033[0m %s\n", $$1, $$2}' 
