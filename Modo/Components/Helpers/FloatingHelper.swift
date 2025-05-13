//
//  FloatingHelper.swift
//  Modo
//
//  Created by Рамазан Гасратов on 13.05.2025.
//

import Foundation
import SwiftUI

class FloatingPanelHelper<Content: View>: NSPanel {
    @Binding private var show: Bool
    
    init(position: CGPoint,                      // ← отступы от правого/верхнего краёв
         show: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content) {
        
        self._show = show
        
        // Временный нулевой rect – потом сразу заменим
        super.init(contentRect: .zero,
                   styleMask: [.nonactivatingPanel, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        
        // Свойства панели
        isFloatingPanel = true
        level = .floating
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        hidesOnDeactivate = false
        
        backgroundColor = .clear
        hasShadow = false
        isMovableByWindowBackground = true
        
        // не скрываем, когда приложение теряет фокус
        // Убираем traffic‑lights
        [.closeButton, .miniaturizeButton, .zoomButton].forEach {
            standardWindowButton($0)?.isHidden = true
        }
        
        // 1) Добавляем SwiftUI‑контент
        let host = NSHostingView(rootView: content())
        contentView = host
        
        // 2) Вычисляем желаемый размер
        let size = host.fittingSize              // 400×600 благодаря .frame(...)
        
        // 3) Выбираем экран (активный или первый доступный)
        guard let screen = self.screen ?? NSScreen.main ?? NSScreen.screens.first else { return }
        let s = screen.visibleFrame              // рабочая область без Dock/меню
        
        // 4) Координата верхнего‑правого угла минус отступы position.x/y
        let origin = CGPoint(
            x: s.maxX - size.width  - position.x,
            y: s.maxY - size.height - position.y
        )
        
        // 5) Ставим окно туда и фиксируем размер
        setFrame(NSRect(origin: origin, size: size), display: false)
        minSize = size
        maxSize = size
    }
    
    // Обновляем Binding, если окно закрыли программно
    override func close() {
        super.close()
        show = false
    }
}
