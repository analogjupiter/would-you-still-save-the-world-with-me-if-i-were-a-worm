# Would you still save the world with me if I were a worm?


## Name of the project
project_name := wysstwfmiiwaw

### Project paths
user_project_root   := .
user_sources_root   := $(user_project_root)/src
user_app_entrypoint := $(user_sources_root)/app.d



## Compiler options
default_compiler := ldc2-1.40.1
default_debugger := lldb-19
pack_with_upx    := yes



## Output settings

### Target
target_path := $(user_project_root)/bin
target_name := $(project_name)

### Build Artifacts
build_path := $(user_project_root)/build



# Under the hood

MAKEFLAGS += --warn-undefined-variables

## User Settings
user_project_root   ?= app
user_sources_root   ?= $(user_project_root)/src
user_assets_root    ?= $(user_project_root)/assets
user_app_entrypoint ?= $(user_sources_root)/app.d
build_path          ?= $(user_project_root)/build
target_path         ?= $(user_project_root)/bin
target_name         ?= my-app
default_compiler    ?= ldc2-1.40.1
default_debugger    ?= lldb-19

## ----------------------------------------------------------------------------
## Framework Settings

### Binary Paths
output_file_target := $(target_path)/$(target_name)
output_file_build  := $(build_path)/app

### Compiler
LDC2 ?= $(default_compiler)

### Compiler Flags
DFLAGS ?= \
	--release \
	--boundscheck=off \
	--checkaction=halt \
	\
	-betterC \
	-Oz \
	-defaultlib=druntime-ldc-lto \
	-fvisibility=hidden \
	-flto=thin \
	--singleobj \
	--whole-program-visibility \
	--dw \
	--wi \
	\
	-L--lto-whole-program-visibility \
	-L--gc-sections \
	-L--strip-all

dflags_required = \
	-L-lcairo \
	-L-lfontconfig \
	-L-lfreetype \
	-L-lgobject-2.0 \
	-L-lharfbuzz \
	-L-lmpv \
	-L-lpangocairo-1.0 \
	-L-lpango-1.0 \
	-L-lSDL2 \
	-J $(user_assets_root) \
	-I $(user_sources_root) \
	-i \
	-of $(output_file_build)

override DFLAGS += $(dflags_required)

### Packer

pack_with_upx ?= yes

ifdef NO_UPX
pack_with_upx := no
endif

## ----------------------------------------------------------------------------
## Targets

.PHONY:
	all \
	analyize \
	build \
	clean \
	debug \
	run \
	\
	.analyize \
	.build \
	.clean \
	.debug \
	.debug_build \
	.run

all: \
	.clean \
	.build \
	.analyize

analyize: \
	.analyize

build: \
	.build \
	.analyize

clean: \
	.clean

debug: \
	.clean \
	.debug_build \
	.debug

run: \
	.clean \
 	.build \
	.analyize \
	.run

### Target implementations

.build:
	@mkdir -p $(build_path)
	$(LDC2) \
		$(DFLAGS) \
		$(user_app_entrypoint)

ifeq ($(pack_with_upx),yes)
	$(MAKE) analyize
	upx --best --ultra-brute $(output_file_build)
endif

	@mkdir -p $(target_path)
	ln $(output_file_build) $(output_file_target)

.debug_build:
	@mkdir -p $(build_path)
	$(LDC2) \
		-gc \
		-d-debug \
		$(dflags_required) \
		$(user_app_entrypoint)

	@mkdir -p $(target_path)
	ln $(output_file_build) $(output_file_target)

.analyize:
	@echo "\n== File Stats ==================================\n"
	@du -b $(output_file_build)
	@echo ""
	@size $(output_file_build)
	@echo "\n================================================\n"

.clean:
	rm -rf $(build_path)
	rm -f  $(output_file_target)

.run:
	./$(output_file_target)

.debug:
	$(default_debugger) ./$(output_file_target)
