#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun ./AppDir/bin/openclaw
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
mkdir -p /var/run/pulse
if ! getent group pulse 1>/dev/null; then
  groupadd -r pulse
fi
if ! id -u pulse 1>/dev/null; then
  useradd -r -g pulse -G audio \
    -d /var/run/pulse -s /usr/bin/nologin pulse 
fi
chown pulse:pulse /var/run/pulse
pulseaudio --system --daemonize --disable-shm --exit-idle-time=-1

quick-sharun --test ./dist/*.AppImage
