#!/bin/bash
set -e

# Define package paths
PKG_NAME="axon-lite-media-tools_1.0.1-1_arm64"
PKG_DIR="$(pwd)/build_pkg/$PKG_NAME"

echo "=== Axon Lite Media Tools Build Script ==="

echo "=> Checking dependencies..."
MISSING_DEPS=""
for dep in cmake make gcc g++ pkg-config meson ninja-build libdrm-dev dpkg-dev; do
    if ! dpkg -s $dep >/dev/null 2>&1; then
        MISSING_DEPS="$MISSING_DEPS $dep"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo "ERROR: Missing required build dependencies."
    echo "Please run: sudo apt install -y$MISSING_DEPS"
    exit 1
fi

echo "=> Initializing and updating git submodules..."
git submodule update --init --recursive

echo "=> Preparing packaging directory..."
rm -rf build_pkg
mkdir -p "$PKG_DIR"

echo "=> Building Rockchip MPP..."
cd mpp
rm -rf build-pkg
mkdir build-pkg
cd build-pkg
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)
make DESTDIR="$PKG_DIR" install
cd ../..

echo "=> Building rockchip-vaapi..."
cd rockchip-vaapi
make clean || true
make -j$(nproc)
mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri"
if [ -f src/rockchip_drv_video.so ]; then
    cp src/rockchip_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/rockchip_drv_video.so"
else
    cp rockchip_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/rockchip_drv_video.so"
fi
chmod 755 "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/rockchip_drv_video.so"
cd ..

echo "=> Injecting package metadata and configs..."
cp -r package_data/* "$PKG_DIR/"
chmod 755 "$PKG_DIR/DEBIAN/postinst"
chmod 755 "$PKG_DIR/DEBIAN/prerm"

echo "=> Building Debian package..."
cd build_pkg
dpkg-deb --build "$PKG_NAME"
mv "$PKG_NAME.deb" ../
cd ..

echo "=== Build Complete ==="
echo "The package axon-lite-media-tools_1.0.1-1_arm64.deb has been generated."
echo "Install it alongside librga2 via:"
echo "  sudo apt install ./librga2_2.2.0-1_arm64.deb ./axon-lite-media-tools_1.0.1-1_arm64.deb"
