import UIKit

/// ハプティックフィードバックのタイプ
enum HapticFeedbackType {
    case light   // タップ (1-2回目)
    case medium  // 破壊 (3回目)
    case success // ダイヤモンドドロップ
}

/// ハプティックフィードバックのライフサイクル管理
class HapticFeedbackManager {
    // MARK: - Public Properties

    /// 準備状態フラグ（テスト可能にするためpublicに変更）
    private(set) var isPrepared: Bool = false

    // MARK: - Private Properties

    private var lightGenerator: UIImpactFeedbackGenerator?
    private var mediumGenerator: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?

    // MARK: - Public Methods

    /// GameState.idle → .playing 遷移時に呼び出す（一度だけ）
    func prepare() {
        guard !isPrepared else { return }

        lightGenerator = UIImpactFeedbackGenerator(style: .light)
        mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationGenerator = UINotificationFeedbackGenerator()

        lightGenerator?.prepare()
        mediumGenerator?.prepare()
        notificationGenerator?.prepare()

        isPrepared = true
    }

    /// タップ時に呼び出す（prepare()済みであれば低レイテンシ）
    func provideFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .light:
            lightGenerator?.impactOccurred()
            lightGenerator?.prepare() // 次のタップ用に再準備
        case .medium:
            mediumGenerator?.impactOccurred()
        case .success:
            notificationGenerator?.notificationOccurred(.success)
        }
    }

    /// GameState → .result 遷移時に呼び出す
    func cleanup() {
        lightGenerator = nil
        mediumGenerator = nil
        notificationGenerator = nil
        isPrepared = false
    }
}
