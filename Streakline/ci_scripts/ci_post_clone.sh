#!/bin/sh
# Xcode Cloud runs this after clone, before the build resolves the project.
# "Prepare build for App Store Connect" submits CI_BUILD_NUMBER as the
# build for this marketing version. CURRENT_PROJECT_VERSION has to be
# that same number. An offset such as 10000 + CI_BUILD_NUMBER makes
# prepare fail because the binary and the submitted build disagree.
# The script does not commit. A local archive keeps the number in git.
set -eu

if [ -z "${CI_BUILD_NUMBER:-}" ]; then
  echo "error: CI_BUILD_NUMBER is unset; refusing to reuse the project build number." >&2
  exit 1
fi

# Digits only, no leading zero. Arithmetic would read a leading zero as
# octal and could stamp a different number than the one Xcode Cloud submits.
case "$CI_BUILD_NUMBER" in
  *[!0-9]*|0*)
    echo "error: CI_BUILD_NUMBER must be a positive integer; got '${CI_BUILD_NUMBER}'." >&2
    exit 1
    ;;
esac

build_number=$CI_BUILD_NUMBER
pbxproj="$(cd "$(dirname "$0")/.." && pwd)/Streakline.xcodeproj/project.pbxproj"
sed -i '' -e "s/CURRENT_PROJECT_VERSION = [0-9][0-9]*;/CURRENT_PROJECT_VERSION = ${build_number};/g" "$pbxproj"
echo "Set CURRENT_PROJECT_VERSION to ${build_number}"
