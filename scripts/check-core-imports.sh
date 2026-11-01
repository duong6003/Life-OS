#!/usr/bin/env bash
# ADR-0002/0008: lõi không được import framework chỉ có trên Apple; Feature không import Platform.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
core_forbidden='^\s*(@preconcurrency\s+)?import\s+(SwiftUI|UIKit|AppKit|CloudKit|CryptoKit|Security|os|OSLog|Combine|WidgetKit|LocalAuthentication|UserNotifications|BackgroundTasks|MetricKit)\b'
if grep -rnE "$core_forbidden" Packages/LifeOSCore/Sources; then
  echo "LỖI: LifeOSCore import framework Apple (xem ADR-0002)"; fail=1
fi
if grep -rnE '^\s*import\s+GRDB\b' Packages/LifeOSCore/Sources --include=*.swift | grep -v '/Persistence/' ; then
  echo "LỖI: chỉ Persistence được import GRDB"; fail=1
fi
if [ -d Packages/LifeOSFeatures/Sources ]; then
  if grep -rnE '^\s*import\s+(CloudKitTransport|CryptoApple|PlatformServices)\b' Packages/LifeOSFeatures/Sources --include=*.swift | grep -v '/AppFeature/'; then
    echo "LỖI: chỉ AppFeature được import LifeOSPlatform"; fail=1
  fi
fi
[ $fail -eq 0 ] && echo "core imports OK"
exit $fail
