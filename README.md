# Axon Lite Media Tools

This repository contains the source code, configurations, and automated build scripts necessary to generate the `axon-lite-media-tools` Debian package for the Rockchip RK3576 SoC (Axon Lite).

## What's Included?
When you build the package, it will seamlessly combine:
- **Rockchip MPP**: The core multimedia processing platform library.
- **Rockchip VA-API**: The translation layer driver that bridges MPP with standard VA-API.
- **Hardware Permissions**: Udev rules (`99-rockchip-media.rules`) to allow user space apps to access hardware decoders.
- **System Environment Configurations**: Automatically exports `LIBVA_DRIVER_NAME=rockchip` and `MOZ_DISABLE_RDD_SANDBOX=1` for GUI environments.
- **Firefox Optimizations**: Enforces hardware decoding and intentionally disables AV1 software decode (forcing YouTube to stream hardware-decoded VP9).

## Prerequisites

For the best results and to avoid cross-compilation complexities, **you must build this package directly on the target RK3576 Axon Lite board**.

You will need the following build dependencies:
```bash
sudo apt update
sudo apt install -y cmake make gcc g++ pkg-config meson ninja-build libdrm-dev dpkg-dev git
```

## How to Build

1. Clone this repository (with its submodules):
   ```bash
   git clone --recursive https://github.com/vicharak-in/axon-lite-media-tools.git
   cd axon-lite-media-tools
   ```
   *(If you've already cloned it without `--recursive`, run `git submodule update --init --recursive`)*

2. Run the automated build script:
   ```bash
   ./build.sh
   ```
   The script will compile both MPP and the VA-API driver, assemble the Debian package filesystem, inject the configurations, and output the final `.deb` file.

## Installation

Once the build is complete, you can install the newly generated tools package alongside the required `librga2` dependency:

```bash
sudo apt install ./librga2_2.2.0-1_arm64.deb ./axon-lite-media-tools_1.0.1-1_arm64.deb
```

> **Note:** After installation, it is recommended to completely close Firefox and log out/log back in so the new environment variables and permissions take effect system-wide.
