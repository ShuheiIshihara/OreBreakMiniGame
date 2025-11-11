# Technology Stack

## Architecture

iOS Native Application - MVC/MVVMパターンを採用予定

## Core Technologies

- **Language**: Swift (最新安定版)
- **Framework**: SwiftUI (UI構築)
- **Platform**: iOS (最小サポートバージョンは実装時に決定)

## Key Libraries

- SwiftUI: 宣言的UI構築、アニメーション
- Combine: リアクティブな状態管理（タイマー、ゲーム状態）
- AVFoundation: サウンドエフェクト（必要に応じて）
- Core Haptics: タップ時のバイブレーションフィードバック

## Development Standards

### Type Safety
- Swift strict type checking
- Optional unwrapping best practices
- Protocol-oriented programming

### Code Quality
- SwiftLint for code style enforcement
- Consistent naming conventions (Swift API Design Guidelines)

### Testing
- XCTest for unit and UI testing
- Test coverage for core game logic

## Development Environment

### Required Tools
- Xcode (latest stable version)
- iOS Simulator or physical iOS device
- Swift Package Manager

### Common Commands
```bash
# Build: xcodebuild build -scheme OreBreakMiniGame
# Test: xcodebuild test -scheme OreBreakMiniGame -destination 'platform=iOS Simulator,name=iPhone 15'
# Run: Open .xcodeproj in Xcode and Run (Cmd+R)
```

## Key Technical Decisions

- **SwiftUI選定理由**: モダンなUI構築、アニメーションが簡潔に記述可能、iOS開発の標準フレームワーク
- **状態管理**: MVVM + Combineでリアクティブなゲーム状態管理
- **Native App**: Web技術ではなくネイティブiOSアプリとして実装し、パフォーマンスとUXを最大化

## Game Mechanics

- **タップ判定**: 3回タップで採掘完了（ヒビ小 → ヒビ大 → 破壊）
- **ドロップ判定**: 10%固定確率でダイヤモンドドロップ
- **タイマー**: ゲーム開始からダイヤモンドドロップまでの時間を計測
- **演出**: SwiftUIアニメーション + Core Hapticsでフィードバック

---
_Document standards and patterns, not every dependency_
