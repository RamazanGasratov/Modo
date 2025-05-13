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
    @State private var showFloatingWindow: Bool = false
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
                Divider()
                
                ScrollView {
                    ForEach(0..<10) { _ in
                        FadingBorderTimerView(totalSeconds: 15) // 25‑минутный «помидор»
                            .frame(width: 180)                    // любой размер — всегда квадрат
                            .padding()
                    }
                }
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
                if show { makePanelAndShow() }
            }
            .onChange(of: show) { _, newVal in
                if newVal {
                    makePanelAndShow()
                } else {
                    
                    panel?.close()
            }
        }
    }
    
    private func makePanelAndShow() {
           if panel == nil {               // создаём один раз
               panel = FloatingPanelHelper(
                   position: position,
                   show: $show,
                   content: { windowView }
               )
           }
           panel?.orderFront(nil)
           panel?.makeKey()
       }
}
