//
//  MenuBarExtraContent.swift
//  Modo
//
//  Created by Рамазан Гасратов on 14.05.2025.
//

import SwiftUI

struct MenuBarExtraContent: View {
    @State private var showFloatingWindow: Bool = false
    
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
            FloatingWindowView()
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

