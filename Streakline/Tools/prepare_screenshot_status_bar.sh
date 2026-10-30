#!/bin/sh
# Tidies the booted simulator status bar before a screenshot or promo capture.
# Clear it afterwards with: xcrun simctl status_bar booted clear
xcrun simctl status_bar booted override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4
