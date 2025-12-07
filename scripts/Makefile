prefix ?= /usr/local/
build_dir ?= $(CURDIR)/build
appimage_dir ?= $(build_dir)/AppDir
install_prefix := $(appimage_dir)/usr
packages_dir ?= $(CURDIR)/packages
scripts_dir ?= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
binutils_ver := $(shell cat $(packages_dir)/binutils.yaml | grep version | sed 's/.\+:\s//g')
libunwind_ver := $(shell cat $(packages_dir)/libunwind.yaml | grep version | sed 's/.\+:\s//g')
xz_ver := $(shell cat $(packages_dir)/xz.yaml | grep version | sed 's/.\+:\s//g')
lua_ls_ver := $(shell cat $(packages_dir)/lua-language-server.yaml | grep version | sed 's/.\+:\s//g')
runtime_libs := libbfd.so libbfd-$(binutils_ver).so libsframe.so libunwind.so liblzma.so
runtime_libs_src := $(addprefix $(build_dir)/deps/lib/,$(runtime_libs))
runtime_libs_dst := $(addprefix $(appimage_dir)/usr/lib/,$(runtime_libs))
runtime_files := main.lua debugger.lua LICENSE changelog.md locale meta script bin/lua-language-server bin/main.lua
runtime_files_src := $(addprefix $(build_dir)/lua-language-server-$(lua_ls_ver)/,$(runtime_files))
runtime_files_dst := $(addprefix $(appimage_dir)/usr/,$(runtime_files))

all: $(runtime_files_dst) $(runtime_libs_dst)

# lua-language-server
$(filter-out $(appimage_dir)/usr/bin/%, $(runtime_files_dst)): \
	$(appimage_dir)/usr/%: $(build_dir)/lua-language-server-$(lua_ls_ver)/% | $(appimage_dir)/usr
	@/usr/bin/env rsync -avz $< $(appimage_dir)/usr/

$(filter $(appimage_dir)/usr/bin/%, $(runtime_files_dst)): \
	$(appimage_dir)/usr/bin/%: $(build_dir)/lua-language-server-$(lua_ls_ver)/bin/% | $(appimage_dir)/usr/bin
	@/usr/bin/env rsync -avz $< $(appimage_dir)/usr/bin/

$(filter-out $(build_dir)/lua-language-server-$(lua_ls_ver)/bin/%, $(runtime_files_src)): | $(build_dir)/lua-language-server-$(lua_ls_ver)

$(build_dir)/lua-language-server-$(lua_ls_ver)/bin/lua-language-server: $(runtime_libs_src) | $(build_dir)/lua-language-server-$(lua_ls_ver)
	@cd $(build_dir)/lua-language-server-$(lua_ls_ver); \
		$(scripts_dir)/patch.sh lua-language-server $(lua_ls_ver) $(build_dir); \
		export LD_LIBRARY_PATH="$(build_dir)/deps/lib:$${LD_LIBRARY_PATH}"; \
		cd $(build_dir)/lua-language-server-$(lua_ls_ver)/3rd/luamake; \
		./compile/build.sh; \
		cd $(build_dir)/lua-language-server-$(lua_ls_ver); \
		FLAGS=-I$(build_dir)/deps/include \
		LDFLAGS=-L$(build_dir)/deps/lib \
		LD_LIBRARY_PATH=$(build_dir)/deps/lib \
		3rd/luamake/luamake rebuild

$(build_dir)/lua-language-server-$(lua_ls_ver)/bin/main.lua: $(build_dir)/lua-language-server-$(lua_ls_ver)/bin/lua-language-server

$(build_dir)/deps/lib/libbfd.so: | $(build_dir)/binutils-$(binutils_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/binutils-$(binutils_ver); \
		./configure --prefix=$(build_dir)/deps --enable-shared --disable-gdb --disable-gprofng; \
		$(MAKE); \
		$(MAKE) install

$(build_dir)/deps/lib/libsframe.so: $(build_dir)/deps/lib/libbfd.so

$(build_dir)/deps/lib/libbfd-$(binutils_ver).so: $(build_dir)/deps/lib/libbfd.so

$(build_dir)/deps/lib/libunwind.so: | $(build_dir)/libunwind-$(libunwind_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/libunwind-$(libunwind_ver); \
		./configure --prefix=$(build_dir)/deps; \
		$(MAKE); \
		$(MAKE) install

$(build_dir)/deps/lib/liblzma.so: | $(build_dir)/xz-$(xz_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/xz-$(xz_ver); \
		./configure --prefix=$(build_dir)/deps --disable-xz --disable-xzdec --disable-lzmadec --disable-lzmainfo --disable-scripts; \
		$(MAKE); \
		$(MAKE) install

# Download files
$(build_dir)/lua-language-server-$(lua_ls_ver):
	@cd $(build_dir); \
		git clone https://github.com/LuaLS/lua-language-server.git --branch $(lua_ls_ver) lua-language-server-$(lua_ls_ver); \
		cd lua-language-server-$(lua_ls_ver); \
		git submodule update --init --recursive

$(build_dir)/binutils-$(binutils_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://ftp.gnu.org/gnu/binutils/binutils-$(binutils_ver).tar.gz $(build_dir)/binutils-$(binutils_ver).tar.gz
	@tar -axf $(build_dir)/binutils-$(binutils_ver).tar.gz -C $(build_dir)

$(build_dir)/libunwind-$(libunwind_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://github.com/libunwind/libunwind/releases/download/v$(libunwind_ver)/libunwind-$(libunwind_ver).tar.gz $(build_dir)/libunwind-$(libunwind_ver).tar.gz
	@tar -axf $(build_dir)/libunwind-$(libunwind_ver).tar.gz -C $(build_dir)

$(build_dir)/xz-$(xz_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://github.com/tukaani-project/xz/releases/download/v$(xz_ver)/xz-$(xz_ver).tar.gz $(build_dir)/xz-$(xz_ver).tar.gz
	@tar -axf $(build_dir)/xz-$(xz_ver).tar.gz -C $(build_dir)

# runtime-libs
$(appimage_dir)/usr/lib/%.so: $(build_dir)/deps/lib/%.so | $(appimage_dir)/usr/lib
	@/usr/bin/env cp -P --preserve=mode,timestamps $<* $(appimage_dir)/usr/lib/

# mkdir
$(build_dir)/deps:
	@mkdir -p $(build_dir)/deps

$(appimage_dir)/usr:
	@mkdir -p $(appimage_dir)/usr

$(appimage_dir)/usr/lib:
	@mkdir -p $(appimage_dir)/usr/lib

$(appimage_dir)/usr/bin:
	@mkdir -p $(appimage_dir)/usr/bin

clean:
	rm -rf $(build_dir) $(appimage_dir)
