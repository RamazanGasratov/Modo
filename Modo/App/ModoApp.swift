//
//  ModoApp.swift
//  Modo
//
//  Created by Рамазан Гасратов on 06.05.2025.
//

import SwiftUI

//MARK: - App

@main
struct ModoApp: App {
    @State var timer = "0:00"
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraContent()
        } label: {
            MenuBarExtraView(
                timer: $timer
            )
        }
    }
}

//MARK: - Content

struct MenuBarExtraContent: View {
    @State private var showFloatingWindow: Bool = true
    let pickerValues = ["One", "Two", "Three"]
    @State private var selection = "One"
    
    var body: some View {
        VStack {
            menuBarExtraButton(
                title: AppConstants.MenuTitle.add,
                shortcut: AppConstants.Shortcut.add
            ) {
                
            }
            menuBarExtraButton(
                title: AppConstants.MenuTitle.openList,
                shortcut: AppConstants.Shortcut.openList
            ) {
                showFloatingWindow.toggle()
            }
            Divider()
            menuBarExtraButton(
                title: AppConstants.MenuTitle.about,
                shortcut: AppConstants.Shortcut.about
            ) {
                
            }
            menuBarExtraButton(
                title: AppConstants.MenuTitle.quit,
                shortcut: AppConstants.Shortcut.quit
            ) {
                NSApp.terminate(nil)
            }
        }
        .floatingWindow(position: CGPoint(x: 16, y: 16), show: $showFloatingWindow) {
            /// - Floating Window Content
            VStack {
                // Segmented picker style.
                Picker("", selection: $selection) {
                    pickerContent()
                }
                .pickerStyle(.segmented)
                .padding()
            }
            .frame(width: 400, height: 600)
            .background(Color.gray)
            .clipShape(
                RoundedRectangle(cornerRadius: 30)
            )
        }
    }
    
    @ViewBuilder
        func pickerContent() -> some View {
            ForEach(pickerValues, id: \.self) {
                Text($0)
            }
        }

    
    private func menuBarExtraButton(
        title: String,
        shortcut: Character,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Text(title)
        }
        .keyboardShortcut(.init(shortcut), modifiers: .command)
    }
}

//MARK: - Custom View Modifier for Floating Window

extension View {
    @ViewBuilder
    func floatingWindow<Content: View>(
        position: CGPoint,
        show: Binding<Bool>,
        @ViewBuilder content: @escaping
        () -> Content
    ) -> some View {
        self
            .modifier(
                FloatingWindowModifier(
                    windowView: content(),
                    position: position,
                    show: show
                )
            )
    }
}

fileprivate struct FloatingWindowModifier<WindowView: View>: ViewModifier {
    var windowView: WindowView
    var position: CGPoint
    @Binding var show: Bool
    @State private var panel: FloatingPanelHelper<WindowView>?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanelHelper(
                    position: position,
                    show: $show,
                    content: {
                        windowView
                    })
            }
            .onChange(of: show) {
                panel?.orderFront(nil)
                panel?.makeKey()
            }
    }
}

/// - Creating Floating Panel Using NSPanel

// ─────────────────────────────────────────────────────────────────────────────
// FloatingPanelHelper.swift
// ─────────────────────────────────────────────────────────────────────────────
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
