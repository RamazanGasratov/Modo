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


