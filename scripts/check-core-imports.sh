#!/usr/bin/env bash
# ADR-0002/0008/0016: ranh giới module.
#  - LifeOSCore không import framework chỉ có trên Apple, không import GRDB/SQLiteData.
#  - Feature không import LifeOSPlatform, CloudSync, SQLiteData (chỉ AppFeature được import CloudSync/Platform).
#  - Chữ `SyncEngine` chỉ xuất hiện trong LifeOSData/Sources/CloudSync và AppFeature (TC-SYNC-14).
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
core_forbidden='^\s*(@preconcurrency\s+)?import\s+(SwiftUI|UIKit|AppKit|CloudKit|CryptoKit|Security|os|OSLog|Combine|WidgetKit|LocalAuthentication|UserNotifications|BackgroundTasks|MetricKit|GRDB|SQLiteData)\b'
if grep -rnE "$core_forbidden" Packages/LifeOSCore/Sources; then
  echo "LỖI: LifeOSCore import framework Apple hoặc thư viện lưu trữ (xem ADR-0002, ADR-0016)"; fail=1
fi
if [ -d Packages/LifeOSFeatures/Sources ]; then
  if grep -rnE '^\s*import\s+(CloudKitTransport|CryptoApple|PlatformServices|CloudSync|SQLiteData|GRDB)\b' Packages/LifeOSFeatures/Sources --include=*.swift | grep -v '/AppFeature/'; then
    echo "LỖI: Feature chỉ dùng Persistence; LifeOSPlatform/CloudSync chỉ AppFeature được import (ADR-0016)"; fail=1
  fi
fi
if grep -rnw 'SyncEngine' Packages/*/Sources --include=*.swift | grep -vE '^[^:]+:[0-9]+:\s*//' | grep -v '/LifeOSData/Sources/CloudSync/' | grep -v '/LifeOSFeatures/Sources/AppFeature/'; then
  echo "LỖI: SyncEngine chỉ được nhắc trong CloudSync và AppFeature (ADR-0016)"; fail=1
fi
[ $fail -eq 0 ] && echo "core imports OK"
exit $fail
