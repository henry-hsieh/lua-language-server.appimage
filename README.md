# lua-language-server.appimage

This project aims to provide an automated build process for creating an AppImage of the popular Lua language server, [lua-language-server](https://github.com/LuaLS/lua-language-server). AppImage is a format for distributing portable software on Linux without needing to install it. With this AppImage, users can run lua-language-server on various Linux distributions without worrying about compatibility or installation issues.

## How to Use

### Downloading the AppImage

You can download the latest release of the lua-language-server AppImage from the [Releases](https://github.com/henry-hsieh/lua-language-server.appimage/releases) page. Simply download the `.AppImage` file and make it executable using the following command:

```bash
chmod +x Lua_Language_Server-x86_64.AppImage
```

### Running lua-language-server

Once the AppImage is downloaded and made executable, you can run it from the terminal:

```bash
./Lua_Language_Server-x86_64.AppImage
```

Or put to your system binary path:

```bash
sudo cp ./Lua_Language_Server-x86_64.AppImage /usr/bin/lua-language-server
```

**Note:** By default, the log and meta paths are redirected to user-writable directories to avoid issues with the read-only SquashFS filesystem. See `data/lua-language-server.bash` for details. This is necessary because lua-language-server attempts to write logs and meta relative to its executable's directory by default.

### Building from Source

If you want to build the lua-language-server AppImage from source yourself, you can clone this repository and run the provided build script. Ensure you have the necessary dependencies installed on your system:

- GNU Make
- Docker

```bash
git clone https://github.com/henry-hsieh/lua-language-server.appimage.git
cd lua-language-server.appimage
make -j
make install prefix=/path/to/install
```

This will generate the lua-language-server AppImage in the `build` directory.

## Contributing

Contributions to this project are welcome! If you encounter any issues or have suggestions for improvement, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE), which means you are free to use, modify, and distribute the code as you see fit.
