//
//  FloatingWindowViewModel.swift
//  Modo
//
//  Created by Рамазан Гасратов on 14.05.2025.
//

import Combine
import SwiftUI

final class FloatingWindowViewModel: ObservableObject {
    @Published var selection: String
    @Published var timers: [TimerSquareViewModel]

    let pickerValues = ["Modo", "Аналитика"]

    init(initialSelection: String = "Modo", timerCount: Int = 5) {
        self.selection = initialSelection
        self.timers = (0..<timerCount).map { _ in
            TimerSquareViewModel(title: "Переписать Network слой")
        }
    }
}

final class TimerSquareViewModel: ObservableObject {
    // Configuration
    private let totalTime: TimeInterval = 60
     let timerStep: TimeInterval = 0.1

    // Published state
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var isRunning: Bool = false

    // Title or task description
    let title: String

    // Timer
    private var timerCancellable: AnyCancellable?

    init(title: String) {
        self.title = title
        self.timeRemaining = totalTime
    }

    var progress: CGFloat {
        max(0, min(1, timeRemaining / totalTime))
    }

    var timeString: String {
        let intSec = Int(ceil(timeRemaining))
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // Public controls
    func start() {
        guard !isRunning, timeRemaining > 0 else { return }
        isRunning = true
        timerCancellable = Timer.publish(every: timerStep, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stop() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard timeRemaining > 0 else {
            timeRemaining = 0
            stop()
            return
        }
        timeRemaining -= timerStep
    }
}
