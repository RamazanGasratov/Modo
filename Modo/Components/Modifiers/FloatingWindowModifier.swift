//
//  FloatingWindowModifier.swift
//  Modo
//
//  Created by Рамазан Гасратов on 14.05.2025.
//

import Foundation
import SwiftUI

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
           if panel == nil {
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
