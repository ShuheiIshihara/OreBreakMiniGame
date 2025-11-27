import Foundation

/// ゲーム全体の状態管理を担うViewModel
@Observable
class GameViewModel {
    // MARK: - Public Properties

    /// 現在のゲーム状態
    private(set) var state: GameState = .idle

    /// 現在の鉱石ブロック
    private(set) var currentOreBlock = OreBlock()

    /// マイニングセッション統計
    private(set) var miningSession = MiningSession()

    /// 破壊アニメーション実行中フラグ
    private(set) var isDestroyAnimationActive: Bool = false

    // MARK: - Private Properties

    /// タイマー管理
    private let timerManager: TimerManager

    /// ハプティックフィードバック管理
    private let hapticManager: HapticFeedbackManager

    /// 乱数生成プロバイダー
    private let randomProvider: RandomProvider

    /// 破壊アニメーション用のTask参照
    private var destroyTask: Task<Void, Never>?

    /// ダイヤモンドドロップ演出用のTask参照
    private var diamondDropTask: Task<Void, Never>?

    // MARK: - Initializer

    /// 依存注入を使った初期化
    /// - Parameters:
    ///   - timerManager: タイマー管理インスタンス
    ///   - hapticManager: ハプティックフィードバック管理インスタンス
    ///   - randomProvider: 乱数生成プロバイダー（デフォルトはSystemRandomProvider）
    init(
        timerManager: TimerManager = TimerManager(),
        hapticManager: HapticFeedbackManager = HapticFeedbackManager(),
        randomProvider: RandomProvider = SystemRandomProvider()
    ) {
        self.timerManager = timerManager
        self.hapticManager = hapticManager
        self.randomProvider = randomProvider
    }

    // MARK: - Public Methods

    /// 鉱石がタップされたときの処理（タスク2.2）
    func onOreTapped() {
        // playing以外の状態ではタップを無視
        guard state == .idle || state == .playing else { return }

        // 初回タップ時の処理（idle → playing遷移）
        if state == .idle {
            state = .playing
            timerManager.startTimer()
            hapticManager.prepare()
        }

        // 鉱石をインクリメント
        let isBroken = currentOreBlock.increment()

        // タップ回数に応じたハプティックフィードバック
        switch currentOreBlock.tapCount {
        case 1, 2:
            hapticManager.provideFeedback(.light)
        case 3:
            hapticManager.provideFeedback(.medium)
        default:
            break
        }

        // 破壊判定
        if isBroken {
            // 鉱石をリセットし、採掘数をインクリメント（即座に実行）
            currentOreBlock.reset()
            miningSession.incrementOreCount()

            // 破壊アニメーションを開始（タスク2.3）
            startDestroyAnimation()
        }
    }

    /// リトライボタンがタップされたときの処理（タスク2.9）
    func onRetryTapped() {
        // すべての状態をリセット
        currentOreBlock.reset()
        miningSession.reset()
        timerManager.reset()
        hapticManager.cleanup()

        // アイドル状態に遷移
        state = .idle
    }

    /// ScenePhaseの変化を処理（タスク2.10）
    /// - Parameter isActive: アプリがアクティブかどうか
    func handleScenePhaseChange(isActive: Bool) {
        if !isActive {
            // バックグラウンドに移行した場合
            switch state {
            case .playing:
                // playing状態の場合、タイマーを一時停止
                timerManager.pauseTimer()

            case .destroying:
                // 破壊アニメーション中の場合、タスクをキャンセルして即座にドロップ判定
                destroyTask?.cancel()
                destroyTask = nil
                performDropCheckSync()

            case .diamondDrop:
                // ダイヤモンドドロップ演出中の場合、タスクをキャンセルして即座にリザルトへ遷移
                diamondDropTask?.cancel()
                diamondDropTask = nil
                state = .result

            default:
                break
            }
        } else {
            // フォアグラウンドに復帰した場合
            if state == .playing {
                timerManager.resumeTimer()
            }
        }
    }

    // MARK: - Private Methods

    /// 破壊アニメーション開始処理（タスク2.3）
    private func startDestroyAnimation() {
        isDestroyAnimationActive = true
        state = .destroying

        destroyTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            // アニメーション時間だけ待機
            try? await Task.sleep(nanoseconds: UInt64(AnimationConstants.destroyDuration * 1_000_000_000))

            // キャンセルされていなければ、アニメーション完了処理を実行
            if !Task.isCancelled {
                self.onDestroyAnimationComplete()
            }
        }
    }

    /// 破壊アニメーション完了後の処理（タスク2.4）
    private func onDestroyAnimationComplete() {
        isDestroyAnimationActive = false
        performDropCheck()
        destroyTask = nil
    }

    /// ドロップ判定処理（タスク2.5）
    private func performDropCheck() {
        let didDrop = randomProvider.random() < 0.10

        if didDrop {
            // タスク2.6: ダイヤモンドドロップ時の状態遷移
            onDiamondDrop()
        } else {
            // タスク2.7: ドロップなし時の復帰処理
            onNoDrop()
        }
    }

    /// バックグラウンド移行時の同期的なドロップ判定（タスク2.10用）
    private func performDropCheckSync() {
        isDestroyAnimationActive = false

        let didDrop = randomProvider.random() < 0.10

        if didDrop {
            // タイマーを停止して直接リザルト画面へ遷移（ドロップ演出をスキップ）
            timerManager.stopTimer()
            state = .result
            hapticManager.provideFeedback(.success)
        } else {
            // playing状態に戻る
            state = .playing
        }
    }

    /// ダイヤモンドドロップ時の状態遷移（タスク2.6 & 2.8）
    private func onDiamondDrop() {
        // タイマーを停止
        timerManager.stopTimer()

        // ダイヤモンドドロップ状態に遷移
        state = .diamondDrop

        // サクセスフィードバック
        hapticManager.provideFeedback(.success)

        // ダイヤモンドドロップ演出を開始
        diamondDropTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            // 演出時間だけ待機
            try? await Task.sleep(nanoseconds: UInt64(AnimationConstants.diamondDropDuration * 1_000_000_000))

            // キャンセルされていなければ、リザルト画面に遷移
            if !Task.isCancelled {
                self.state = .result
                self.diamondDropTask = nil
            }
        }
    }

    /// ドロップなし時の復帰処理（タスク2.7）
    private func onNoDrop() {
        // 新鉱石は既にreset済みなので、playing状態に戻るだけ
        state = .playing
    }
}
