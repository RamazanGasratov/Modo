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


