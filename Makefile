prefix ?= /usr/local/
build_dir := $(CURDIR)/build
appimage_dir := $(build_dir)/AppDir
packages_dir := $(CURDIR)/packages
lua_ls_ver := $(shell cat $(packages_dir)/lua-language-server.yaml | grep version | sed 's/.\+:\s//g')

# Check if running inside Docker
DOCKER := $(shell if [ -f /.dockerenv ]; then echo "true"; else echo "false"; fi)
DOCKER_CMD := docker run -t \
							--privileged \
							-e TARGET_UID=$(shell id -u) \
							-e TARGET_GID=$(shell id -g) \
							-e TARGET_USER=$(shell id -un) \
							-v $(CURDIR):$(CURDIR) \
							-w $(CURDIR) \
							lua-language-server

.PHONY: all clean docker_build test linuxdeploy_extract install

all: $(build_dir)/Lua_Language_Server-x86_64.AppImage

# build appimage
$(build_dir)/Lua_Language_Server-x86_64.AppImage: $(appimage_dir)/usr/bin/lua-language-server | $(build_dir)/linuxdeploy-x86_64.AppImage $(appimage_dir)/usr/share/applications/lua-language-server.desktop $(appimage_dir)/usr/share/icons/hicolor/scalable/apps/lua.svg
	@cd $(build_dir); \
		LD_LIBRARY_PATH=$(appimage_dir)/usr/lib \
		$(build_dir)/linuxdeploy-x86_64.AppImage --appdir $(appimage_dir) --output appimage --custom-apprun=$(CURDIR)/data/lua-language-server.bash || $(MAKE) linuxdeploy_extract -C $(CURDIR)

linuxdeploy_extract: $(appimage_dir)/usr/bin/lua-language-server | $(build_dir)/linuxdeploy-x86_64.AppImage $(build_dir)/linuxdeploy
	@cd $(build_dir)/linuxdeploy; \
	../linuxdeploy-x86_64.AppImage --appimage-extract; \
	cd $(build_dir); \
	LD_LIBRARY_PATH=$(appimage_dir)/usr/lib \
	$(build_dir)/linuxdeploy/squashfs-root/AppRun --appdir $(appimage_dir) --output appimage --custom-apprun=$(CURDIR)/data/lua-language-server.bash

$(appimage_dir)/usr/share/applications/lua-language-server.desktop:
	@mkdir -p $(appimage_dir)/usr/share/applications
	@cp $(CURDIR)/data/lua-language-server.desktop $(appimage_dir)/usr/share/applications

$(appimage_dir)/usr/share/icons/hicolor/scalable/apps/lua.svg:
	@mkdir -p $(appimage_dir)/usr/share/icons/hicolor/scalable/apps
	@cp $(CURDIR)/data/lua.svg $(appimage_dir)/usr/share/icons/hicolor/scalable/apps

# Define the Docker command
ifeq ($(DOCKER),true)
$(appimage_dir)/usr/bin/lua-language-server:
	$(MAKE) -C scripts appimage_dir=$(appimage_dir) build_dir=$(build_dir) packages_dir=$(packages_dir)
else
$(appimage_dir)/usr/bin/lua-language-server: docker_build
	$(DOCKER_CMD) $(MAKE) -C scripts appimage_dir=$(appimage_dir) build_dir=$(build_dir) packages_dir=$(packages_dir) -j
endif

# build docker image
docker_build:
	docker build -t lua-language-server $(CURDIR)

# download files
$(build_dir)/linuxdeploy-x86_64.AppImage: | $(build_dir)
	@$(CURDIR)/scripts/download_file.sh https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage $(build_dir)/linuxdeploy-x86_64.AppImage
	@chmod +x $(build_dir)/linuxdeploy-x86_64.AppImage

# mkdir
$(build_dir):
	@mkdir -p $(build_dir)

$(build_dir)/linuxdeploy:
	@mkdir -p $(build_dir)/linuxdeploy

clean:
	rm -rf $(build_dir)

test: $(build_dir)/Lua_Language_Server-x86_64.AppImage
	@$(CURDIR)/scripts/test_lua_ls.sh $< $(lua_ls_ver) && echo "Test passed" || echo "Test failed"

install: $(build_dir)/Lua_Language_Server-x86_64.AppImage
	@/usr/bin/env install -p -D $< $(prefix)/bin/lua-language-server.appimage
