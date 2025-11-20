# Research & Design Decisions

---
**Purpose**: ダイヤモンド鉱石採掘アプリの技術設計における調査結果と設計判断を記録

**Usage**:
- ディスカバリーフェーズの調査活動と成果をログ化
- `design.md`には詳細すぎる設計判断のトレードオフを文書化
- 将来の監査や再利用のための参照と証拠を提供
---

## Summary
- **Feature**: `diamond-ore-mining`
- **Discovery Scope**: New Feature (グリーンフィールド)
- **Key Findings**:
  - SwiftUI + Combine + MVVMアーキテクチャは2025年の標準パターンとして確立
  - @Observableパターンの採用により、Combineへの依存を最小化できる
  - TimelineView + Canvasを使用したパーティクル実装が最高のパフォーマンスを提供
  - UIImpactFeedbackGeneratorのprepare()タイミングは即座実行では効果なし

## Research Log

### SwiftUI MVVM State Management (2025年ベストプラクティス)
- **Context**: ゲーム状態管理とリアクティブUIの最適アーキテクチャパターンを調査
- **Sources Consulted**:
  - [Modern MVVM in SwiftUI 2025](https://medium.com/@minalkewat/modern-mvvm-in-swiftui-2025-the-clean-architecture-youve-been-waiting-for-72a7d576648e)
  - [SwiftUI State Management Best Practices](https://www.dhiwise.com/blog/design-converter/proven-swiftui-state-management-best-practices-to-use)
  - [MVVM with Combine in SwiftUI](https://iosapptemplates.com/blog/swiftui/mvvm-combine-swiftui)
- **Findings**:
  - @Observableマクロの採用により、@Published + ObservableObjectの冗長性が削減される
  - ViewModelはSwiftUI/UIKitに依存せず、純粋なビジネスロジック層として実装すべき
  - 複数View間で共有する状態は@EnvironmentObject、ローカル状態は@Stateを使用
  - Combineは非同期イベントとデータストリーム処理に特化して使用
- **Implications**:
  - GameViewModelは@Observable + @Publishedの組み合わせで実装
  - タイマー管理にはCombine.Timerを使用
  - 状態遷移（idle/playing/result）はenumで明示的に管理

### SwiftUI Animation Coordination & Timing
- **Context**: 破壊アニメーション、ドロップ演出、画面遷移のタイミング制御方法を調査
- **Sources Consulted**:
  - [Demystifying SwiftUI Animation](https://fatbobman.com/en/posts/the_animation_mechanism_of_swiftui/)
  - [WWDC23 - Advanced animations in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10157/)
  - [SwiftUI animation sequence](https://medium.com/nerd-for-tech/swiftui-animation-sequence-7a0cf364773a)
- **Findings**:
  - Keyframes APIにより複雑な協調アニメーションのタイミングを完全制御可能
  - Phased animationsで離散的な状態間を自動的にアニメーション
  - withAnimation block内で状態変更をラップすることでアニメーションをコーディネート
  - アニメーションシーケンスは前のアニメーションの継続時間を遅延として使用
- **Implications**:
  - 破壊アニメーション完了 → ドロップ判定 → 新鉱石表示の順序制御にwithAnimationとTask.sleepを使用
  - ヒビ表示トランジションは.animationモディファイアで0.1-0.2秒指定
  - リザルト画面遷移は.transition(.opacity)とwithAnimation(.easeInOut(duration: 0.3))を組み合わせ

### iOS Haptic Feedback Best Practices
- **Context**: タップ時のハプティックフィードバックの最適実装方法を調査
- **Sources Consulted**:
  - [Haptic Feedback in iOS: A Comprehensive Guide](https://dev.to/maxnxi/haptic-feedback-in-ios-a-comprehensive-guide-39fb)
  - [UIFeedbackGenerator - Sarunw](https://sarunw.com/posts/play-haptic-feedback-using-uifeedbackgenerator/)
  - [Haptics on Apple Platforms](https://blog.eidinger.info/haptics-on-apple-platforms)
- **Findings**:
  - UIImpactFeedbackGeneratorはprepare()呼び出し後、数秒間のみ準備状態を維持
  - prepare()と即座のトリガー間に時間がない場合、レイテンシ改善効果なし
  - Taptic Engineは準備状態を短期間のみ維持し、電力節約のためアイドル状態に戻る
  - 適切な使用タイミング: ユーザーアクションに対する応答、視覚的変化との一致
  - Core Hapticsは複雑なパターンや音声同期が必要な場合に使用
- **Implications**:
  - 鉱石タップ直前にprepare()を呼び出すのではなく、GameViewModelの初期化時に準備
  - light/medium/successの3種類のフィードバックタイプを使い分け
  - ゲーム終了時にジェネレータへの参照を削除してTaptic Engineをアイドル状態に戻す

### SwiftUI Particle Effects Performance
- **Context**: 破壊時のパーティクルエフェクトの高パフォーマンス実装方法を調査
- **Sources Consulted**:
  - [Vortex - High-performance particle effects](https://github.com/twostraws/Vortex)
  - [Magical Particle Effects with SwiftUI Canvas](https://nerdyak.tech/development/2024/06/27/particle-effects-with-SwiftUI-Canvas.html)
  - [swiftui-particles performance debugging](https://github.com/benlmyers/swiftui-particles)
- **Findings**:
  - TimelineView + Canvasの組み合わせが最も効率的（事前レンダリング可能）
  - 60 FPS維持には各フレーム更新を16.66ms以内に完了させる必要
  - エンティティモディファイアを単一クロージャに統合することでproxy update timeを削減
  - .glow()/.blur()などのエフェクトモディファイアはrendering timeを増加
  - Release buildはDebug buildに比べて大幅に高速
- **Implications**:
  - パーティクルは4-8個の破片に制限（要件仕様に準拠）
  - Canvas APIを使用して破片を描画（Rectangle形状）
  - アニメーションは0.3-0.5秒で完結（60 FPS維持）
  - 外部ライブラリは不使用（シンプルな実装で十分）

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| MVVM + @Observable | ViewModelが@Observableマクロで状態を公開、Viewがバインディング | SwiftUI標準、シンプル、テスト容易 | Combineへの依存最小化 | ステアリング原則と完全一致 |
| MVVM + Combine | ViewModelが@Publishedプロパティで状態公開、Combineでストリーム処理 | Combineの強力なリアクティブ機能 | 複雑性増加、学習コスト高 | タイマー処理のみCombine使用 |
| Clean Architecture | Use Cases層を追加、依存性逆転 | テスタビリティ最高、分離度高 | 過度な複雑化、シンプルなゲームには過剰 | 本プロジェクトには不要 |

**選択**: MVVM + @Observable (タイマーのみCombine.Timer使用)

## Design Decisions

### Decision: 状態管理アーキテクチャ
- **Context**: ゲーム状態（idle/playing/result）、鉱石状態（tapCount, crackLevel）、統計（timer, oreCount）の管理方法
- **Alternatives Considered**:
  1. 単一のGameStateクラスにすべてを集約 — シンプルだがテストが困難
  2. 複数のViewModelに分離（GameViewModel, OreViewModel, StatsViewModel） — 過度な分離
  3. GameViewModel + ドメインModel（OreBlock, MiningSession） — MVVMの標準パターン
- **Selected Approach**: GameViewModel + ドメインModel
- **Rationale**:
  - GameViewModelがアプリケーション状態とユーザーインタラクションを管理
  - OreBlockはドメインロジック（タップカウント、ヒビ状態）をカプセル化
  - MiningSessionは採掘セッションの統計を管理
  - テスタビリティと責任分離のバランスが最適
- **Trade-offs**:
  - Benefits: 明確な責任分離、単体テスト容易、SwiftUIとの自然な統合
  - Compromises: やや多めのファイル数（3-4ファイル）
- **Follow-up**: 実装時にOreBlockとMiningSessionのimmutabilityを検証

### Decision: アニメーション実装戦略
- **Context**: 破壊アニメーション完了→ドロップ判定→新鉱石表示のシーケンス制御
- **Alternatives Considered**:
  1. Combineで状態遷移を管理 — 過度に複雑
  2. Task.sleep()で遅延実行 — シンプルだが正確性に欠ける可能性
  3. .onAnimationCompleted()モディファイアでコールバック — SwiftUI標準だが複雑
- **Selected Approach**: withAnimation + Task.sleep()の組み合わせ
- **Rationale**:
  - 要件の「破壊アニメーション完了イベント発火タイミングと同一フレームで描画」を満たす
  - withAnimation内でのアニメーション完了タイミングは予測可能
  - Task.sleep()で正確な遅延制御が可能
- **Trade-offs**:
  - Benefits: シンプル、理解しやすい、メンテナンス容易
  - Compromises: アニメーション時間とsleep時間の同期が必要
- **Follow-up**: アニメーション時間を定数化してsleep時間と一致させる

### Decision: パーティクルエフェクト実装
- **Context**: 破壊時の4-8個のパーティクル（画面幅30%以内に飛散）をどう実装するか
- **Alternatives Considered**:
  1. Vortex等の外部ライブラリ — 高機能だが依存関係増加
  2. Canvas API — 高パフォーマンス、ネイティブ
  3. 複数のView要素をGeometryEffectで移動 — シンプルだがパフォーマンス懸念
- **Selected Approach**: Canvas API
- **Rationale**:
  - TimelineView + Canvasが最高のパフォーマンス（調査結果より）
  - 4-8個の破片のみなので複雑なライブラリ不要
  - ネイティブSwiftUI APIのみで実装可能
- **Trade-offs**:
  - Benefits: ゼロ依存、高パフォーマンス、学習機会
  - Compromises: 手動実装が必要（ライブラリより手間）
- **Follow-up**: パーティクルの放射角度と速度のアルゴリズム検証

### Decision: ハプティックフィードバックのライフサイクル
- **Context**: prepare()のタイミングと Generator のライフサイクル管理
- **Alternatives Considered**:
  1. タップ直前にprepare()を毎回呼び出す — レイテンシ改善効果なし
  2. ViewModel初期化時に prepare() — 準備状態は数秒で失効
  3. GameState.playing遷移時にprepare() — 適切なタイミング
- **Selected Approach**: GameState.playing遷移時にprepare()、ゲーム終了時に解放
- **Rationale**:
  - プレイ開始から終了までの間、Taptic Engineを準備状態に維持
  - アイドル状態では不要な電力消費を回避
  - 調査結果: 準備状態は数秒間維持されるため、ゲームセッション中は有効
- **Trade-offs**:
  - Benefits: 適切な電力管理、レイテンシ最小化
  - Compromises: 状態遷移時の処理が若干増加
- **Follow-up**: 実機でのハプティック応答時間を計測

## Risks & Mitigations
- **Risk 1**: アニメーション同期の不正確さ（破壊→ドロップ→新鉱石） — **Mitigation**: アニメーション時間を定数化し、Task.sleep()と厳密に同期
- **Risk 2**: パーティクル実装の複雑性とパフォーマンス — **Mitigation**: Canvas APIの事前検証、60FPS維持の確認
- **Risk 3**: ハプティックフィードbackの非対応デバイス — **Mitigation**: UIDevice.current.userInterfaceIdiom == .phoneでチェック、Simulator対応
- **Risk 4**: タイマーの精度低下（バックグラウンド移行） — **Mitigation**: ScenePhaseでバックグラウンド検知、タイマー一時停止/再開処理

## References
- [Modern MVVM in SwiftUI 2025](https://medium.com/@minalkewat/modern-mvvm-in-swiftui-2025-the-clean-architecture-youve-been-waiting-for-72a7d576648e)
- [SwiftUI Animation Mechanism](https://fatbobman.com/en/posts/the_animation_mechanism_of_swiftui/)
- [Haptic Feedback Comprehensive Guide](https://dev.to/maxnxi/haptic-feedback-in-ios-a-comprehensive-guide-39fb)
- [SwiftUI Particle Effects with Canvas](https://nerdyak.tech/development/2024/06/27/particle-effects-with-SwiftUI-Canvas.html)
- [Apple Developer - Controlling Animation Timing](https://developer.apple.com/documentation/swiftui/controlling-the-timing-and-movements-of-your-animations)
- [WWDC23 - Advanced Animations in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10157/)