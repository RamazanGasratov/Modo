//
//  CalendarService.swift
//  Modo
//
//  Created by Рамазан Гасратов on 15.05.2025.
//

import Foundation
import EventKit
import Combine

class TimersManager: ObservableObject {
    @Published var timers: [TimerEvent] = []
    
    private var cancellable: AnyCancellable?
    private let eventStore = EKEventStore()
    
    init() {
            requestAccessAndLoad()
            // Подписываемся на системное уведомление об изменении EventStore
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(eventStoreDidChange),
                name: .EKEventStoreChanged,
                object: eventStore
            )
        }

        @objc private func eventStoreDidChange(_ note: Notification) {
            // Перезагружаем список при любом изменении
            loadTodayEvents()
        }
    
    private func requestAccessAndLoad() {
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
               guard granted else { return }
               self?.loadTodayEvents()
           }
       }

       private func loadTodayEvents() {
           let (start, end) = startAndEndOfToday()
           let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
           let events = eventStore.events(matching: predicate)

           // Преобразуем в нашу модель
           let timers = events.map { event in
               TimerEvent(
                   id: event.eventIdentifier,
                   title: event.title ?? "Без названия",
                   notes: event.notes,
                   color: event.calendar.color,
                   startDate: event.startDate,
                   endDate: event.endDate
               )
           }
           DispatchQueue.main.async {
               self.timers = timers
           }
       }
    
    private func startAndEndOfToday() -> (Date, Date) {
           let calendar = Calendar.current
           let now = Date()
           let start = calendar.startOfDay(for: now)
           let end = calendar.date(byAdding: .day, value: 1, to: start)!
                         .addingTimeInterval(-1)
           return (start, end)
       }
}

import SwiftUI

struct TimersView: View {
    @StateObject private var manager = TimersManager()
    private let timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        return f
    }()
    

    var body: some View {
        ForEach(manager.timers) { timerEvent in
            LazyVStack {
                TimerRow(event: timerEvent)
            }
        }
        .padding(.horizontal, 18)
    }
}

extension Color {
    init(_ nsColor: NSColor) {
        // Приводим к sRGB-пространству
        let rgb = nsColor.usingColorSpace(.sRGB) ?? .black
        self.init(
            .sRGB,
            red:   rgb.redComponent,
            green: rgb.greenComponent,
            blue:  rgb.blueComponent,
            opacity: rgb.alphaComponent
        )
    }
}

import SwiftUI
import Combine

struct TimerRow: View {
    let event: TimerEvent

    // Параметры таймера
    @State private var isRunning: Bool = false
    @State private var remaining: TimeInterval
    @State private var initialDuration: TimeInterval
    @State private var lastDate: Date = Date()
    @State private var subscription: AnyCancellable? = nil
    private var isFinished: Bool { remaining <= 0 }

    // Форматер для отображения строки времени
    private let timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        return f
    }()

    init(event: TimerEvent) {
           self.event = event
           let duration = event.endDate.timeIntervalSince(event.startDate)
           _initialDuration = State(initialValue: duration)
           _remaining       = State(initialValue: duration)
       }

    var body: some View {
        HStack {
            // Цветной индикатор
            // Вставляем кружочек с прогрессом
            CircularProgressView(
                progress: initialDuration > 0 ? (remaining / initialDuration) : 0,
                timeString: timeFormatter.string(from: max(remaining, 0)) ?? "--:--:--",
                size: 45,
                lineWidth: 3,
                progressColor: Color(nsColor: event.color)
            )
            .opacity(isFinished ? 0.5 : 1.0)


                Text(event.title)
                    .font(.headline)
                    .strikethrough(isFinished, color: .gray)
//
//                if let notes = event.notes {
//                    Text(notes)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
            

            Spacer()


            // Кнопка плея/паузы
            Button(action: toggleRun) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(isFinished)
        }
        .padding(10)
        .background(Color(nsColor: event.color).opacity(isFinished ? 0.5 : 0.15))
        .cornerRadius(15)
        .scaleEffect(isRunning ? 1.05 : 1.0)
               .animation(.easeInOut(duration: 0.2), value: isRunning)
               .foregroundColor(isFinished ? .gray : .primary)
               .strikethrough(isFinished)
        
        .onChange(of: event.startDate, { _ , _ in
            let dur = event.endDate.timeIntervalSince(event.startDate)
            initialDuration = dur
            remaining       = dur
        })
        .onChange(of: event.endDate, { _ , _ in
            let dur = event.endDate.timeIntervalSince(event.startDate)
            initialDuration = dur
            remaining       = dur
        })
        .onDisappear { subscription?.cancel() }
    }

    private func toggleRun() {
        isRunning.toggle()
        if isRunning {
            lastDate = Date()
            startTimer()
        } else {
            subscription?.cancel()
        }
    }

    private func startTimer() {
        subscription = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { now in
                let delta = now.timeIntervalSince(lastDate)
                lastDate = now
                remaining -= delta

                if remaining <= 0 {
                    remaining = 0
                    isRunning = false
                    subscription?.cancel()
                    NotificationManager.shared.scheduleTimerFinishedNotification(for: event)
                }
            }
    }
}
