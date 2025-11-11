# Project Structure

## Organization Philosophy

Feature-first organization with clear separation of concerns:
- Game logic and UI components separated
- Reusable components for scalability
- iOS standard project structure

## Directory Patterns

### Views
**Location**: `/Views/`
**Purpose**: SwiftUIビュー、画面コンポーネント
**Example**: `GameView.swift`, `ResultView.swift`, `OreBlockView.swift`

### ViewModels
**Location**: `/ViewModels/`
**Purpose**: ビジネスロジック、状態管理、ViewとModelの橋渡し
**Example**: `GameViewModel.swift`, `ResultViewModel.swift`

### Models
**Location**: `/Models/`
**Purpose**: データモデル、ゲームロジック、エンティティ定義
**Example**: `OreBlock.swift`, `GameState.swift`, `MiningSession.swift`

### Utilities
**Location**: `/Utilities/`
**Purpose**: 共通処理、ヘルパー関数、拡張機能
**Example**: `HapticFeedback.swift`, `RandomGenerator.swift`

### Resources
**Location**: `/Resources/`
**Purpose**: アセット（画像、音声）、設定ファイル
**Example**: `Assets.xcassets`, `Sounds/`, `ore_textures/`

## Naming Conventions

- **Files**: PascalCase for Swift files (`GameScene.swift`, `BlockNode.swift`)
- **Classes/Structs**: PascalCase (`class PaddleController`, `struct GameConfig`)
- **Functions/Variables**: camelCase (`func updateScore()`, `var currentLevel`)
- **Constants**: camelCase or UPPER_SNAKE_CASE for globals (`let maxLives`, `MAX_BLOCKS_PER_ROW`)

## Import Organization

```swift
// System frameworks first
import SwiftUI
import Combine
import AVFoundation

// Third-party (if any)
import SomeLibrary

// Local modules (if modularized)
```

## Code Organization Principles

- **MVVM Architecture**: SwiftUIのViewとビジネスロジックを分離
- **Single Responsibility**: 各クラス/ファイルは単一の責任を持つ
- **ObservableObject**: ViewModelは`@Published`プロパティで状態を公開
- **Protocol-Oriented**: テスト容易性のためプロトコルを活用
- **Dependency Injection**: ViewModelへの依存注入でテスタビリティ向上

## Game-Specific Patterns

### State Management
- `GameState` enum: `.idle`, `.playing`, `.result`
- `OreBlock` struct: タップカウント、ヒビ状態を保持
- `MiningSession`: 経過時間、採掘数、ドロップ判定を管理

### View Composition
- 小さなコンポーネントに分割（OreBlockView, TimerView, StatsView）
- 再利用可能なアニメーション修飾子
- パーティクルエフェクトは独立したView

---
_Document patterns, not file trees. New files following patterns shouldn't require updates_
