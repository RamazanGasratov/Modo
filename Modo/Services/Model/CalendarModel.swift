//
//  CalendarModel.swift
//  Modo
//
//  Created by Рамазан Гасратов on 26.05.2025.
//

import Foundation
import AppKit

struct TimerEvent: Identifiable {
    let id: String                  // можно взять event.eventIdentifier
    let title: String
    let notes: String?
    let color: NSColor
    let startDate: Date
    let endDate: Date

    /// Оставшееся время (в секундах). Если минус — таймер закончился.
    func timeRemaining(currentDate: Date) -> TimeInterval {
        return endDate.timeIntervalSince(currentDate)
    }
}
