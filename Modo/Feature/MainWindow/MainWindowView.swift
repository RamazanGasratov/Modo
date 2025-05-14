//
//  MainWindowView.swift
//  Modo
//
//  Created by Рамазан Гасратов on 12.05.2025.
//

import Foundation

import EventKit
import Combine

@MainActor
final class CalendarService: ObservableObject {
    @Published var todayTimers: [EventTimer] = []
    
    private let store = EKEventStore()
    private var updateTask: Task<Void, Never>?
    
    init() {
        Task { await request() }
    }
    
    // 1) Запрашиваем доступ
    private func request() async {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:       startPolling()
        case .notDetermined:
            let ok = try? await store.requestFullAccessToEvents()
            if ok == true { startPolling() }
        default: break
        }
    }
    
    // 2) Каждую минуту (и на didChange) обновляем список
    private func startPolling() {
        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: store,
            queue: .main) { [weak self] _ in self?.reload() }
        
        updateTask = Task {
            while !Task.isCancelled {
                reload()
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }
    
    // 3) Загружаем события ТОЛЬКО на сегодня
    private func reload() {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: Date())
        let dayEnd   = cal.date(byAdding: .day, value: 1, to: dayStart)!
                         .addingTimeInterval(-1)
        
        let pred = store.predicateForEvents(withStart: dayStart,
                                            end: dayEnd,
                                            calendars: nil)
        
        // все сегодняшние события, отсортированные по реальному start
        let events = store.events(matching: pred)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
        
        // ── строим очередность без перекрытий ───────────────────────────
        var cursor = Date()                                   // когда «освободится экран»
        todayTimers = []
        
        for ev in events {
            // если событие полностью уже прошло до cursor – пропускаем
            if ev.endDate <= cursor { continue }
            
            let effectiveStart = max(ev.startDate, cursor)
            let effectiveEnd   = effectiveStart
                .addingTimeInterval(ev.endDate.timeIntervalSince(ev.startDate))
            
            cursor = effectiveEnd                            // хвост сдвигается
            
            todayTimers.append(
                EventTimer(event: ev,
                           effectiveStart: effectiveStart,
                           effectiveEnd:   effectiveEnd)
            )
        }
    }
}

struct EventTimer: Identifiable {
    let id    : String
    let title : String
    let start : Date       // скорректированный
    let end   : Date
    let color : Color
    
    init(event: EKEvent,
         effectiveStart: Date,
         effectiveEnd:   Date)
    {
        id    = event.eventIdentifier
        title = event.title
        start = effectiveStart
        end   = effectiveEnd
        
        if #available(macOS 14, iOS 17, *) {
            color = Color(event.calendar.color)
        } else {
            let ns = NSColor(cgColor: event.calendar.cgColor) ?? .controlAccentColor
            color = Color(ns)
        }
    }
    
    var duration  : TimeInterval { end.timeIntervalSince(start) }
    var remaining : TimeInterval { max(0, end.timeIntervalSinceNow) }
    var state: TimerState {
        let now = Date()
        if now < start { return .pending }
        if now < end   { return .running }
        return .finished
    }
}
enum TimerState { case pending, running, finished }

import SwiftUI

struct CalendarTimersView: View {
    @StateObject private var calendar = CalendarService()
    @State private var tick = Date()   // триггер обновления UI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(calendar.todayTimers) { timer in
                HStack {
                    Text(timer.title)
                    Spacer()
                    Text(display(timer))
                        .monospacedDigit()
                        .bold()
                        .foregroundStyle(color(timer))
                }
            }
            if calendar.todayTimers.isEmpty {
                Text("📅 Нет задач на сегодня")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        // тикаем каждую секунду, чтобы UI обновлялся
        .onReceive(Publishers.everySecond) { _ in
            tick = Date()
        }
    }
    
    private func display(_ t: EventTimer) -> String {
        switch t.state {
        case .pending:   return timeString(t.start.timeIntervalSinceNow) + " ▶︎"
        case .running:   return timeString(t.remaining)
        case .finished:  return "✓"
        }
    }
    private func color(_ t: EventTimer) -> Color {
        switch t.state {
        case .pending:  .yellow
        case .running:  .green
        case .finished: .secondary
        }
    }
    
    private func timeString(_ ti: TimeInterval) -> String {
        let sec = Int(ti.rounded())
        return String(format: "%02d:%02d", sec/60, sec%60)
    }
}

import Combine
extension Publishers {
    static var everySecond: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}
