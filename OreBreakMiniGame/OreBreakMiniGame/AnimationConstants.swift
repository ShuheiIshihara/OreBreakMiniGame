import Foundation

/// アニメーション時間定数（一か所で管理）
enum AnimationConstants {
    /// 破壊アニメーション時間（0.4秒）
    static let destroyDuration: TimeInterval = 0.4

    /// ダイヤモンドドロップ演出時間（1.5秒）
    static let diamondDropDuration: TimeInterval = 1.5

    /// ヒビ表示トランジション時間（0.15秒）
    static let crackTransitionDuration: TimeInterval = 0.15

    /// 「タップして開始」ヒントのフェード周期（1.0秒）
    static let startHintFadeDuration: TimeInterval = 1.0
}
