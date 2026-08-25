#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook:sdl-soundfonts.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1

# Deploy dependencies
quick-sharun ./AppDir/bin/openclaw /usr/lib/libfluidsynth.so*
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# this app has problems with other locales breaking physics
echo 'LC_ALL=C.UTF-8' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage
