//
//  FadingBorderTimerView.swift
//  Modo
//
//  Created by Рамазан Гасратов on 13.05.2025.
//

import Foundation
import SwiftUI

/// Квадратный таймер с «угасающей» рамкой
struct FadingBorderTimerView: View {
    // сколько секунд в сессии
    let totalSeconds: Int
    
    // оставшееся время
    @State private var remaining: Int
    // системный таймер раз в секунду
    private let ticker = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    init(totalSeconds: Int) {
        self.totalSeconds = totalSeconds
        _remaining        = State(initialValue: totalSeconds)
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                // время по центру
                Text(timeString)
                    .font(.system(size: g.size.width * 0.3,
                                  weight: .bold, design: .monospaced))
            }
            .frame(width: g.size.width, height: g.size.width)   // квадрат
            // динамический бордюр
            .overlay(
                Rectangle()
                    .strokeBorder(
                        Color.accentColor.opacity(opacity),
                        lineWidth: 4
                    )
            )
        }
        .aspectRatio(1, contentMode: .fit)       // сохраняем квадратность
        .onReceive(ticker) { _ in
            guard remaining > 0 else {
                ticker.upstream.connect().cancel()  // стоп таймер
                return
            }
            remaining -= 1
        }
        .animation(.linear(duration: 0.25), value: remaining)   // плавное угасание
    }
    
    // MARK: – helpers
    
    private var opacity: Double {
        Double(remaining) / Double(totalSeconds)   // от 1 до 0
    }
    
    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}
