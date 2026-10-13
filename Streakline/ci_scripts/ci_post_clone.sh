#!/bin/sh
# Xcode Cloud runs this after clone, before the build resolves the project.
# TestFlight rejects a repeated CURRENT_PROJECT_VERSION for the same
# marketing version. Assign 10000 + the Xcode Cloud run number so each
# archive is newer than the manually uploaded builds 1–4, and newer than
# the raw CI_BUILD_NUMBER (that counter started at 1).
# The script does not commit. A local archive keeps the number in git.
set -eu

if [ -z "${CI_BUILD_NUMBER:-}" ]; then
  echo "error: CI_BUILD_NUMBER is unset; refusing to reuse the project build number." >&2
  exit 1
fi

build_number=$((10000 + CI_BUILD_NUMBER))
pbxproj="$(cd "$(dirname "$0")/.." && pwd)/Streakline.xcodeproj/project.pbxproj"
sed -i '' -e "s/CURRENT_PROJECT_VERSION = [0-9][0-9]*;/CURRENT_PROJECT_VERSION = ${build_number};/g" "$pbxproj"
echo "Set CURRENT_PROJECT_VERSION to ${build_number}"
