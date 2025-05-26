//
//  MainWindowView.swift
//  Modo
//
//  Created by Рамазан Гасратов on 12.05.2025.
//

import Foundation


import SwiftUI

//struct CalendarTimersView: View {
////    @StateObject private var calendar = CalendarService()
//    @State private var tick = Date()   // триггер обновления UI
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            ForEach(calendar.todayTimers) { timer in
//                HStack {
//                    Text(timer.title)
//                    Spacer()
//                    Text(display(timer))
//                        .monospacedDigit()
//                        .bold()
//                        .foregroundStyle(color(timer))
//                }
//            }
//            if calendar.todayTimers.isEmpty {
//                Text("📅 Нет задач на сегодня")
//                    .foregroundStyle(.secondary)
//            }
//        }
//        .padding()
//        // тикаем каждую секунду, чтобы UI обновлялся
//        .onReceive(Publishers.everySecond) { _ in
//            tick = Date()
//        }
//    }
//    
//    private func display(_ t: EventTimer) -> String {
//        switch t.state {
//        case .pending:   return timeString(t.start.timeIntervalSinceNow) + " ▶︎"
//        case .running:   return timeString(t.remaining)
//        case .finished:  return "✓"
//        }
//    }
//    private func color(_ t: EventTimer) -> Color {
//        switch t.state {
//        case .pending:  .yellow
//        case .running:  .green
//        case .finished: .secondary
//        }
//    }
//    
//    private func timeString(_ ti: TimeInterval) -> String {
//        let sec = Int(ti.rounded())
//        return String(format: "%02d:%02d", sec/60, sec%60)
//    }
//}
//
//import Combine
//extension Publishers {
//    static var everySecond: Publishers.Autoconnect<Timer.TimerPublisher> {
//        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    }
//}
