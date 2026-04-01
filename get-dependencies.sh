#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm   \
    cmake                 \
    fluidsynth            \
    freepats-general-midi \
    gcc-libs              \
    libdecor              \
    pipewire-audio        \
    pipewire-jack         \
    sdl2_gfx              \
    sdl2_image            \
    sdl2_mixer            \
    sdl2_ttf

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package sdl2 --noconfirm
mkdir -p ./AppDir/share/soundfonts
cp /usr/share/soundfonts/freepats-general-midi.sf2 ./AppDir/share/soundfonts

# If the application needs to be manually built that has to be done down here
echo "Making nightly build of OpenClaw..."
echo "---------------------------------------------------------------"
REPO="https://github.com/pjasicek/OpenClaw"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone "$REPO" ./OpenClaw
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./OpenClaw
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j$(nproc)
cd ../Build_Release
mv -v openclaw SAVES.XML clacon.ttf config.xml ASSETS.ZIP console02.tga ../../AppDir/bin
wget https://github.com/pjasicek/OpenClaw/releases/download/v0.3/OpenClaw_v1.03.zip -O temp.zip && bsdtar -xf temp.zip CLAW.REZ && rm temp.zip
mv -v CLAW.REZ ../../AppDir/bin
