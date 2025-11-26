// MARK: - Game State Enum
/// Represents the overall state of the game flow.
enum GameState {
    case idle          // 初期状態、タップ待ち
    case playing       // 鉱石がタップ可能な状態
    case destroying    // 破壊アニメーション中
    case diamondDrop   // ダイヤモンドがドロップした演出中
    case result        // 結果表示画面
}

// MARK: - Crack Level Enum
/// Visual crack level of the ore block.
enum CrackLevel {
    case none   // ヒビなし
    case small  // 小ヒビ（1回タップ）
    case large  // 大ヒビ（2回タップ）
    case broken // 破壊済み（3回タップ）
}

// MARK: - Ore Block Model
/// Represents a single ore block that the player interacts with.
struct OreBlock {
    /// 現在のタップ回数（0〜3）
    private(set) var tapCount: Int = 0
    /// 現在のヒビレベル
    private(set) var crackLevel: CrackLevel = .none

    /// タップが行われたときに呼び出す。
    /// - Returns: `true` if the block becomes broken (i.e., ready for reset), otherwise `false`.
    mutating func increment() -> Bool {
        guard tapCount < 3 else { return true }
        tapCount += 1
        switch tapCount {
        case 1:
            crackLevel = .small
        case 2:
            crackLevel = .large
        case 3:
            crackLevel = .broken
        default:
            break
        }
        return tapCount == 3
    }

    /// リセットして次のブロックに備える。
    mutating func reset() {
        tapCount = 0
        crackLevel = .none
    }
}

// MARK: - Mining Session Model
/// Tracks overall mining statistics for a game session.
struct MiningSession {
    /// 取得した鉱石の総数
    private(set) var oreCount: Int = 0
    /// 経過時間（秒）
    private(set) var elapsedTime: TimeInterval = 0

    /// 鉱石が破壊されたときに呼び出す。
    mutating func incrementOreCount() {
        oreCount += 1
    }

    /// タイマー更新用。`delta` は前回呼び出しからの経過秒数。
    mutating func updateElapsedTime(delta: TimeInterval) {
        elapsedTime += delta
    }

    /// セッション全体をリセット（新しいゲーム開始時）。
    mutating func reset() {
        oreCount = 0
        elapsedTime = 0
    }
}
