//
//  FloatingWindowView.swift
//  Modo
//
//  Created by Рамазан Гасратов on 14.05.2025.
//
import SwiftUI
import Combine

import SwiftUI
import Combine

///// Любой таймер, который можно нарисовать в квадрате
//protocol TimerRepresentable: ObservableObject, Identifiable {
//    // данные
//    var title:          String         { get }
//    var color:          Color          { get }   // акцент‑цвет (из календаря или Accent)
//    var totalTime:      TimeInterval   { get }
//    var timeRemaining:  TimeInterval   { get set }
//
//    // управление
//    var isRunning:      Bool           { get }
//    var isControllable: Bool           { get }   // календарные – нет
//    func start()
//    func stop()
//}
//
//extension TimerRepresentable {
//    var progress: CGFloat {             // 1 → 0
//        max(0, min(1, timeRemaining / totalTime))
//    }
//    var timeString: String {
//        let secs = Int(ceil(timeRemaining))
//        return String(format: "%02d:%02d", secs/60, secs%60)
//    }
//}




//final class CalendarTimerVM: ObservableObject, TimerRepresentable {
//    let id = UUID()
//    let title: String
//    let color: Color
//    let totalTime: TimeInterval                  // = duration
//    @Published var timeRemaining: TimeInterval   // меняем под UI
//    var isRunning: Bool { state == .running }
//    let isControllable = false
//    
//    private enum State { case pending, running, finished }
//    private var state: State
//    private let event: EventTimer
//    private var tick: AnyCancellable?
//    
//    init(event: EventTimer) {
//        self.event = event
//        self.title = event.title
//        self.color = event.color
//        self.totalTime = event.duration
//        
//        let now = Date()
//        switch event.state {
//        case .pending:
//            self.state = .pending
//            self.timeRemaining = totalTime            // 30 минут, не «+ ожидание»
//        case .running:
//            self.state = .running
//            self.timeRemaining = event.remaining
//        case .finished:
//            self.state = .finished
//            self.timeRemaining = 0
//        }
//        
//        // единый таймер каждую секунду
//        tick = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in self?.update() }
//    }
//
//    
//    private func update() {
//        let now = Date()
//        switch state {
//        case .pending:
//            if now >= event.start {
//                state = .running
//            }
//        case .running:
//            timeRemaining = max(0, event.end.timeIntervalSince(now))
//            if timeRemaining == 0 { state = .finished }
//        case .finished:
//            tick?.cancel()
//        }
//    }
//    
//    // календарные таймеры не останавливаются вручную
//    func start() {}
//    func stop()  {}
//}

struct FloatingWindowView: View {
    @StateObject private var viewModel = FloatingWindowViewModel()
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selection) {
                ForEach(viewModel.pickerValues, id: \.self) { value in
                    Text(value)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()
            
            
//            List(todayTimers) { timer in
//                HStack {
//                    Circle()
//                        .fill(Color(timer.color))
//                        .frame(width: 12, height: 12)
//                    Text(timer.title)
//                    Spacer()
//                    Text("\(Int(timer.duration / 60)) мин")
//                }
//            }.task {
//                try? await CalendarService.shared.requestCalendarPermission()
//                CalendarService.shared.start()
//            }
//            .onReceive(CalendarService.shared.publisher) { todayTimers = $0 }

            ScrollView {
                VStack {
                    HStack {
                        Text("Календарь")
                        
                        Spacer()
                    }
                    .padding()
                    
                    TimersView()
                    
//                    ForEach(vms) { vm in
//                        TimerSquareView(viewModel: vm)   // 👈 дописали <CalendarTimerVM>
//                            .padding(.horizontal)
//                    }
                    
                    
                    Divider()
                    
                    HStack {
                        Text("Дополнительное Modo")
                        
                        Spacer()
                    }
                    .padding()
                    
//                    ForEach(viewModel.timers, id: \.title) { timerVM in
//                        TimerSquareView(viewModel: timerVM)
//                            .padding(.horizontal, 15)
//                    }
                }
            }

            Spacer()
        }
        .frame(width: 400, height: 600)
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

struct TimerSquareView<VM: TimerRepresentable>: View {
    @ObservedObject var viewModel: VM
    
    var body: some View {
        HStack {
            CircularProgressView(progress: viewModel.progress,
                                 timeString: viewModel.timeString, progressColor: viewModel.color)
                .tint(viewModel.color)                       // цвет рамки
    
            Text(viewModel.title).lineLimit(1)
            Spacer()
            
            if viewModel.isControllable {                   // кнопка только для Manual
                Button {
                    viewModel.isRunning ? viewModel.stop() : viewModel.start()
                } label: {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        .padding(10)
        .background(viewModel.color.opacity(0.15))
        .cornerRadius(15)
        .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
        .animation(.linear(duration: 0.1), value: viewModel.progress)
    }
}

// MARK: - Preview

struct FloatingWindowView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingWindowView()
    }
}


import Foundation
import Combine
import SwiftUI

/// Протокол, ожидаемый `TimerSquareView`.
/// Если в проекте уже есть свой протокол — удалите этот и замените импортом.
// MARK: - Протокол, который ожидает TimerSquareView
public protocol TimerRepresentable: ObservableObject, Identifiable {
    var title: String { get }
    var progress: Double { get }     // 0…1
    var timeString: String { get }   // «mm:ss»
    var color: Color { get }

    var timeRemaining: TimeInterval { get } // сек
    var isRunning: Bool { get }
    var isControllable: Bool { get }

    func start()
    func stop()
}
