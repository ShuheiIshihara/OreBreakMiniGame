import Foundation
import Combine

/// 高精度タイマー管理とバックグラウンド対応
@Observable
class TimerManager {
    // MARK: - Public Properties

    /// 高精度計測値（Date基準、±0.001秒）
    private(set) var elapsedTime: TimeInterval = 0.0

    // MARK: - Private Properties

    private var timerSubscription: AnyCancellable?
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0.0
    private var isRunning: Bool = false

    // MARK: - Public Methods

    /// タイマーを開始する（Date基準で高精度計測開始）
    func startTimer() {
        guard !isRunning else { return }
        startDate = Date()
        isRunning = true

        // Combine.Timerは1秒ごとにUI更新をトリガー
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
    }

    /// タイマーを一時停止する（pause時点の正確な時間を保存）
    func pauseTimer() {
        guard isRunning else { return }

        // pause時点の正確な経過時間を累積
        if let start = startDate {
            accumulatedTime += Date().timeIntervalSince(start)
        }

        timerSubscription?.cancel()
        timerSubscription = nil
        startDate = nil
        isRunning = false
        elapsedTime = accumulatedTime
    }

    /// タイマーを再開する（accumulatedTimeは保持されたまま）
    func resumeTimer() {
        guard !isRunning else { return }
        startTimer() // accumulatedTimeはそのまま
    }

    /// タイマーを停止する（最終時間を確定）
    func stopTimer() {
        updateElapsedTime() // 最終時間を確定
        timerSubscription?.cancel()
        timerSubscription = nil
        isRunning = false
    }

    /// タイマーを完全リセット
    func reset() {
        timerSubscription?.cancel()
        timerSubscription = nil
        startDate = nil
        accumulatedTime = 0.0
        elapsedTime = 0.0
        isRunning = false
    }

    /// フォーマットされた時間文字列を返す（MM:SS形式）
    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Methods

    /// 経過時間を更新（常にDate基準で高精度計算）
    private func updateElapsedTime() {
        guard let start = startDate else { return }
        elapsedTime = accumulatedTime + Date().timeIntervalSince(start)
    }
}
