//
//  CircularProgressView.swift
//  Modo
//
//  Created by Рамазан Гасратов on 14.05.2025.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var timeString: String
    var size: CGFloat = 45
    var lineWidth: CGFloat = 3
    var progressColor: Color 
    var backgroundColor: Color = Color.gray.opacity(0.3)

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 1 - progress, to: 1)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(progressColor)
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)

            Text(timeString)
                .font(.system(size: 9))
        }
    }
}
