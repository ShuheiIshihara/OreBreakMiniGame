# Implementation Plan

## Task Overview

このドキュメントは、マインクラフト風ダイヤモンド鉱石採掘アプリの実装タスクを定義します。すべてのタスクは、requirements.mdとdesign.mdに基づいて生成されています。

## Implementation Tasks

### Phase 1: Foundation & Core Models

- [ ] 1. ドメインモデルとユーティリティの実装
- [x] 1.1 (P) ゲーム状態とドメインモデルを定義
  - GameState enumを5状態（idle, playing, destroying, diamondDrop, result）で実装
  - OreBlock structを実装し、tapCount、crackLevel、increment()、reset()を提供
  - MiningSession structを実装し、oreCount、elapsedTime、incrementOreCount()、updateElapsedTime()、reset()を提供
  - CrackLevel enumをnone、small、large、brokenの4レベルで実装
  - _Requirements: 1, 4, 5, 7_

- [x] 1.2 (P) タイマー管理機能を実装
  - Date基準の高精度時間計測を実装（±0.001秒）
  - Combine.Timerを1秒ごとのUI更新トリガーとして使用
  - pauseTimer()でaccumulatedTimeに経過時間を保存
  - resumeTimer()で新しいstartDateから再開
  - formattedTime計算プロパティで「MM:SS」形式を提供
  - _Requirements: 3, 14_

- [x] 1.3 (P) ハプティックフィードバック管理を実装
  - lightGenerator（UIImpactFeedbackGenerator.light）を初期化
  - mediumGenerator（UIImpactFeedbackGenerator.medium）を初期化
  - notificationGenerator（UINotificationFeedbackGenerator）を初期化
  - prepare()をidle→playing遷移時に一度だけ呼び出す仕組み
  - provideFeedback()でlight、medium、successの3種類を提供
  - cleanup()でresult遷移時にgeneratorを解放
  - _Requirements: 9_

- [x] 1.4 (P) 乱数生成プロバイダーを実装
  - RandomProviderプロトコルを定義（random() -> Double）
  - SystemRandomProviderを実装（Double.random(in: 0.0...1.0)）
  - MockRandomProviderを実装（テスト用固定値）
  - _Requirements: 2_

- [x] 1.5 (P) アニメーション定数を定義
  - AnimationConstants enumを実装
  - destroyDuration（0.4秒）を定義
  - diamondDropDuration（1.5秒）を定義
  - crackTransitionDuration（0.15秒）を定義
  - startHintFadeDuration（1.0秒）を定義
  - _Requirements: 11_

### Phase 2: Application Layer

- [ ] 2. GameViewModelの実装
- [ ] 2.1 状態管理とプロパティを実装
  - @Observable属性を付与
  - state: GameStateプロパティを実装（初期値: .idle）
  - currentOreBlock: OreBlockプロパティを実装
  - miningSession: MiningSessionプロパティを実装
  - isDestroyAnimationActiveフラグを実装
  - TimerManager、HapticFeedbackManager、RandomProviderの依存注入を実装
  - _Requirements: 7_

- [ ] 2.2 鉱石タップ処理を実装
  - onOreTapped()メソッドでアイドル→playing遷移を処理
  - 初回タップ時にtimerManager.startTimer()とhapticManager.prepare()を呼び出し
  - OreBlock.increment()を呼び出し、戻り値で破壊判定
  - tapCount 1-2回目はhapticManager.provideFeedback(.light)
  - tapCount 3回目はhapticManager.provideFeedback(.medium)
  - 破壊時にcurrentOreBlock.reset()とminingSession.incrementOreCount()を即座に実行
  - 状態を.playing以外（.destroying、.diamondDrop、.result）の時はタップを無視
  - _Requirements: 1, 4, 5, 9, 13_
  - _Depends on: 1.1, 1.3_

- [ ] 2.3 破壊アニメーション開始処理を実装
  - isDestroyAnimationActive = trueを設定
  - state = .destroyingに遷移
  - destroyTaskプロパティでTask参照を保持
  - Task内でTask.sleep(AnimationConstants.destroyDuration)を呼び出し（0.4秒待機）
  - _Requirements: 1, 11_
  - _Depends on: 1.5, 2.2_

- [ ] 2.4 破壊アニメーション完了後の処理を実装
  - Task.sleep()完了後にisDestroyAnimationActive = falseに戻す
  - performDropCheck()メソッドを呼び出してドロップ判定に進む
  - Task完了時にdestroyTask参照をクリア
  - _Requirements: 1, 11_
  - _Depends on: 2.3_

- [ ] 2.5 ドロップ判定処理を実装
  - performDropCheck()メソッドを実装
  - randomProvider.random() < 0.10でドロップ判定（10%確率）
  - ドロップ判定結果に応じて次の処理を分岐
  - _Requirements: 2_
  - _Depends on: 1.4, 2.4_

- [ ] 2.6 ダイヤモンドドロップ時の状態遷移を実装
  - ドロップ判定が真の場合の処理
  - timerManager.stopTimer()を呼び出し
  - state = .diamondDropに遷移
  - hapticManager.provideFeedback(.success)を呼び出し
  - diamondDropTaskでTask参照を保持
  - _Requirements: 2, 9_
  - _Depends on: 2.5_

- [ ] 2.7 ドロップなし時の復帰処理を実装
  - ドロップ判定が偽の場合の処理
  - state = .playingに戻る（新鉱石は既にreset済み）
  - 次のタップを受け付ける状態に遷移
  - _Requirements: 2_
  - _Depends on: 2.5_

- [ ] 2.8 ダイヤモンドドロップ演出とリザルト遷移を実装
  - state = .diamondDrop時にTask.sleep(AnimationConstants.diamondDropDuration)で1.5秒待機
  - 演出完了後にstate = .resultに遷移
  - diamondDropTask?.cancel()でタスクキャンセル機能を実装
  - _Requirements: 2, 6, 11_
  - _Depends on: 2.6_

- [ ] 2.9 リトライ処理を実装
  - onRetryTapped()メソッドを実装
  - currentOreBlock.reset()、miningSession.reset()、timerManager.reset()を呼び出し
  - state = .idleに遷移
  - hapticManager.cleanup()を呼び出し
  - _Requirements: 6, 7_
  - _Depends on: 1.1, 1.2, 1.3_

- [ ] 2.10 バックグラウンド/フォアグラウンド処理を実装
  - handleScenePhaseChange()メソッドを実装
  - state == .playing時にtimerManager.pauseTimer()
  - state == .destroying時にdestroyTask?.cancel()してperformDropCheckSync()を即座実行
  - state == .diamondDrop時にdiamondDropTask?.cancel()してstate = .resultに遷移
  - フォアグラウンド復帰時、state == .playingならtimerManager.resumeTimer()
  - _Requirements: 14_
  - _Depends on: 1.2, 2.3, 2.8_

### Phase 3: Presentation Layer - Views

- [ ] 3. UI基盤とレイアウト実装
- [ ] 3.1 (P) GameViewを実装
  - ZStackでOreBlockView、StatsView、ResultViewを配置
  - SafeAreaを考慮したレイアウト
  - ScenePhase監視でGameViewModel.handleScenePhaseChange()を呼び出し
  - アイドル状態で「タップして開始」ヒントを鉱石下方20ptに表示
  - ヒントのフェードアニメーション（1.0秒周期、透明度0.3〜1.0）を実装
  - 画面回転を無効化（Portrait専用）
  - _Requirements: 7, 10, 12_

- [ ] 3.2 鉱石画像の表示を実装
  - Assets.xcassetsから鉱石画像を読み込み（グレーベース + 青い鉱脈）
  - 画面中央に配置
  - 適切なサイズでレンダリング
  - _Requirements: 8_
  - _Depends on: 4.1_

- [ ] 3.3 CrackLevelに応じたヒビオーバーレイを実装
  - CrackLevelに応じたヒビ画像のオーバーレイ描画
  - none: ヒビなし
  - small: 小ヒビ（黒線1-2本）
  - large: 大ヒビ（黒線3本以上）
  - broken: 破壊（非表示）
  - _Requirements: 1, 8_
  - _Depends on: 1.1, 3.2, 4.1_

- [ ] 3.4 鉱石のタップ判定を実装
  - タップ判定を鉱石画像全体の矩形領域に設定（透明部分も含む）
  - .onTapGestureでviewModel.onOreTapped()を呼び出し
  - 領域外のタップは無視
  - _Requirements: 1, 13_
  - _Depends on: 2.2, 3.2_

- [ ] 3.5 破壊アニメーションを実装
  - isDestroyAnimationActiveに応じた破壊アニメーション
  - scaleEffect（1.0 → 0.0）とopacity（1.0 → 0.0）の組み合わせ
  - アニメーション時間: 0.4秒（AnimationConstants.destroyDuration）
  - easeOutタイミング関数を使用
  - _Requirements: 1, 8, 11_
  - _Depends on: 1.5, 2.3_

- [ ] 3.6 ヒビ表示のトランジションアニメーションを実装
  - CrackLevelが変化した時のスムーズなトランジション
  - アニメーション時間: 0.15秒（AnimationConstants.crackTransitionDuration）
  - _Requirements: 8, 11_
  - _Depends on: 1.5, 3.3_

- [ ] 3.7 パーティクルエフェクトの統合を実装
  - ParticleEffectViewをZStackで重ねる
  - isDestroyAnimationActiveに応じて表示/非表示を切り替え
  - 鉱石画像の中心位置をパーティクルの開始位置として渡す
  - _Requirements: 8, 11_
  - _Depends on: 3.2, 3.8_

- [ ] 3.8 (P) ParticleEffectViewのParticle構造とアルゴリズムを実装
  - Particle structを定義（id、startPosition、size、angle、velocity、color）
  - generateParticles()で4-8個の破片を生成
  - 放射状均等配置 + ランダムズレ（±15度）のアルゴリズム
  - 破片サイズ8-16pt、速度100-200pt/秒、色はグレー系3色
  - _Requirements: 8, 11_
  - _Depends on: 1.5_

- [ ] 3.9 (P) ParticleEffectViewのCanvas描画を実装
  - TimelineView + Canvasで60FPS維持
  - progress変数でフェードアウト（opacity: 1.0 - progress）とスケールダウン（scale: 1.0 - progress * 0.5）
  - isActiveフラグでアニメーション開始（withAnimation(.linear(duration: 0.4))）
  - position(at:)メソッドで各破片の位置を計算
  - _Requirements: 8, 11_
  - _Depends on: 3.8_

- [ ] 3.10 (P) StatsViewを実装
  - タイマー表示（timerManager.formattedTime、「MM:SS」形式）
  - 採掘数表示（miningSession.oreCount、「X個」形式）
  - タップ進捗インジケーター（currentOreBlock.tapCount、「X/3」形式）
  - 画面上部または鉱石近くに配置
  - セーフエリア内に収める
  - _Requirements: 3, 4, 5_
  - _Depends on: 1.1, 1.2_

- [ ] 3.11 (P) ResultViewを実装
  - かかった時間をtimerManager.formattedTimeで表示（「MM:SS」形式）
  - 砕いた鉱石総数をminingSession.oreCountで表示（「X個」形式）
  - 「リトライ」ボタンを表示
  - ボタンタップでviewModel.onRetryTapped()を呼び出し
  - state == .result時のみ表示（フェードトランジション0.3秒）
  - _Requirements: 6_
  - _Depends on: 2.9_

- [ ] 3.12 (P) ダイヤモンドドロップ演出Viewを実装
  - 鉱石位置を中心とした輝きエフェクトを実装
  - UI要素（タイマー、採掘数、タップインジケーター）の前面レイヤーに表示
  - state == .diamondDrop時に表示（1.5秒間）
  - すべてのタップ入力を無効化
  - UI要素の透明度変化なし（そのまま表示し続ける）
  - _Requirements: 2, 8_
  - _Depends on: 1.5, 2.8_

### Phase 4: Assets & Configuration

- [ ] 4. アセットとアプリ設定
- [ ] 4.1 (P) 鉱石画像アセットを用意
  - ヒビなし鉱石画像（グレーベース + 青い鉱脈、マインクラフト風）
  - 小ヒビ画像（黒い線1-2本）
  - 大ヒビ画像（黒い線3本以上）
  - 2Dピクセルアート風のビジュアルスタイル
  - Assets.xcassetsに配置
  - _Requirements: 8_

- [ ] 4.2 (P) アプリ設定とデバイス対応を実装
  - Info.plistでPortrait専用設定（画面回転無効化）
  - iPad実行時はiPhoneアプリとして動作（iPad最適化なし）
  - 異なる画面サイズ（iPhone SE〜iPhone Pro Max）でのスケーリング検証
  - _Requirements: 12_

### Phase 5: Integration & Testing

- [ ] 5. システム統合とテスト
- [ ] 5.1 GameViewModelの単体テストを実装
  - アイドル→playing→destroying→resultの完全なフロー検証
  - OreBlock.increment()とcrackLevelの対応検証
  - MiningSession統計（incrementOreCount、updateElapsedTime）検証
  - MockRandomProviderで固定値ドロップ判定検証
  - TimerManagerのpause/resume検証
  - _Requirements: 1, 2, 3, 4, 5, 7_

- [ ] 5.2 ドロップなしシナリオの統合テストを実装
  - 最初のタップ → playing → 破壊 → ドロップなし → 新鉱石表示
  - 破壊アニメーション→新鉱石表示のタイミング検証
  - タイマーが継続して動作することを確認
  - _Requirements: 1, 2, 7_

- [ ] 5.3 ドロップありシナリオの統合テストを実装
  - 最初のタップ → playing → 破壊 → ドロップあり → result遷移
  - タイマー停止タイミングの検証
  - ダイヤモンドドロップ演出からリザルト画面への遷移検証
  - _Requirements: 1, 2, 3, 6, 7_

- [ ] 5.4 destroying中のバックグラウンド遷移テストを実装
  - 破壊アニメーション中にバックグラウンドに移行
  - destroyTask?.cancel()が呼ばれることを確認
  - performDropCheckSync()が即座実行されることを確認
  - state が .playing or .diamondDrop に遷移することを確認
  - _Requirements: 14_

- [ ] 5.5 diamondDrop中のバックグラウンド遷移テストを実装
  - ダイヤモンドドロップ演出中にバックグラウンドに移行
  - diamondDropTask?.cancel()が呼ばれることを確認
  - state = .result に即座遷移することを確認
  - タイマーが停止していることを確認
  - _Requirements: 14_

- [ ] 5.6 playing中のバックグラウンド/フォアグラウンド遷移テストを実装
  - プレイ中にバックグラウンドに移行
  - timerManager.pauseTimer()が呼ばれることを確認
  - フォアグラウンド復帰時にtimerManager.resumeTimer()が呼ばれることを確認
  - タイマーが正確に再開することを確認
  - _Requirements: 3, 14_

- [ ] 5.7 UI表示とアニメーションの検証テストを実装
  - 初回起動時のアイドル状態UI確認（鉱石、タイマー「00:00」、採掘数「0個」、タップインジケーター「0/3」、「タップして開始」ヒント）
  - 1, 2, 3回タップ時のUI変化確認（ヒビ表示、破壊アニメーション、パーティクル）
  - リザルト画面のリトライボタン動作確認
  - _Requirements: 1, 6, 8, 10_

- [ ] 5.8* パフォーマンステストを実装
  - パーティクル再生中の60FPS維持確認
  - 長時間プレイ時のメモリリーク検出
  - タップ応答時間 < 16ms（1フレーム以内）確認
  - タイマー精度 ± 0.1秒以内確認
  - _Requirements: 3, 8, 11_

## Requirements Coverage

| Requirement | Covered by Tasks |
|-------------|------------------|
| 1: 鉱石採掘メカニクス | 1.1, 2.2, 2.3, 2.4, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.7 |
| 2: ダイヤモンドドロップシステム | 1.4, 2.5, 2.6, 2.7, 2.8, 3.12, 5.1, 5.2, 5.3 |
| 3: タイマー機能 | 1.2, 3.10, 5.1, 5.3, 5.6, 5.8 |
| 4: 採掘統計トラッキング | 1.1, 2.2, 3.10, 5.1 |
| 5: タップ進捗インジケーター | 1.1, 2.2, 3.10, 5.1 |
| 6: リザルト画面 | 2.8, 2.9, 3.11, 5.3, 5.7 |
| 7: ゲームフロー管理 | 1.1, 2.1, 2.9, 3.1, 5.1, 5.2, 5.3 |
| 8: ビジュアル演出 | 3.2, 3.3, 3.5, 3.6, 3.8, 3.9, 3.12, 4.1, 5.7, 5.8 |
| 9: ハプティックフィードバック | 1.3, 2.2, 2.6 |
| 10: 初回起動とアイドル状態UI | 3.1, 5.7 |
| 11: アニメーションとタイミング仕様 | 1.5, 2.3, 2.4, 2.8, 3.5, 3.6, 3.7, 3.8, 3.9, 5.8 |
| 12: デバイス対応とレイアウト | 3.1, 4.2 |
| 13: タップ判定仕様 | 2.2, 3.4 |
| 14: バックグラウンド動作とアプリ状態管理 | 1.2, 2.10, 5.4, 5.5, 5.6 |

## Notes

- タスク番号の末尾に`(P)`がついているタスクは並列実行可能
- タスク番号の末尾に`*`がついているタスクはMVP後に延期可能なオプショナルなテスト
- `_Depends on:` が記載されているタスクは、依存タスク完了後に実装可能
- すべてのタスクはdesign.mdのコンポーネント定義に従って実装
- アニメーション時間は必ずAnimationConstants定数を参照
- Task.sleep()とwithAnimationのdurationは同じ定数を使用

## Task Summary

- **Total Major Tasks**: 5
- **Total Sub-tasks**: 38
- **Parallel-capable Tasks**: 10 (タスク1系、3.8-3.12、4系)
- **Optional Tasks**: 1 (5.8 パフォーマンステスト)
- **Average Task Size**: 1-2時間/サブタスク
