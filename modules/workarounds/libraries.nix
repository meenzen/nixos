{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.workarounds.libraries;
in {
  options.meenzen.workarounds.libraries = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        bzip2
        cairo
        cups
        curlWithGnuTls
        dbus
        dbus-glib
        desktop-file-utils
        e2fsprogs
        expat
        flac
        fontconfig
        freeglut
        freetype
        fribidi
        fuse
        fuse3
        gdk-pixbuf
        glew_1_10
        glib
        gmp
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-ugly
        gst_all_1.gstreamer
        gtk2
        harfbuzz
        icu
        keyutils.lib
        libGL
        libGLU
        libappindicator-gtk2
        libcaca
        libcanberra
        libcap
        libclang.lib
        libdbusmenu
        libdrm
        libgcrypt
        libgpg-error
        libidn
        libjack2
        libjpeg
        libmikmod
        libogg
        libpng12
        libpulseaudio
        librsvg
        libsamplerate
        libthai
        libtheora
        libtiff
        libudev0-shim
        libusb1
        libuuid
        libvdpau
        libvorbis
        libvpx
        libxcrypt-legacy
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        p11-kit
        pango
        pixman
        python3
        speex
        stdenv.cc.cc
        tbb
        udev
        vulkan-loader
        wayland
        libICE
        libSM
        libX11
        libXScrnSaver
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXft
        libXi
        libXinerama
        libXmu
        libXrandr
        libXrender
        libXt
        libXtst
        libXxf86vm
        libpciaccess
        libxcb
        xcbutil
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        xcbutilwm
        xkeyboardconfig
        xz
        zlib
      ];
      description = "List of libraries to install";
    };
  };

  config = lib.mkIf config.meenzen.desktop.enable {
    # Fix JetBrains Toolbox, see https://github.com/NixOS/nixpkgs/issues/240444#issuecomment-1988645885
    programs.nix-ld = {
      enable = true;
      libraries = cfg.packages;
    };

    environment.variables = {
      LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.fontconfig
      ];
    };
  };
}
