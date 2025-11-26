import Foundation

/// ドロップ判定の乱数生成を抽象化（テスト容易性）
protocol RandomProvider {
    /// 0.0 ~ 1.0の範囲の乱数を返す
    func random() -> Double
}

/// システム標準の乱数生成（本番環境用）
struct SystemRandomProvider: RandomProvider {
    func random() -> Double {
        Double.random(in: 0.0...1.0)
    }
}

/// テスト用の固定値を返すモック実装
struct MockRandomProvider: RandomProvider {
    let fixedValue: Double

    func random() -> Double {
        fixedValue
    }
}
