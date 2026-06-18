//
//  LocalizedNavigationTitle.swift
//  TakeHome
//

import SwiftUI

private struct LocalizedNavigationTitle: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                }
            }
    }
}

extension View {
    func localizedNavigationTitle(_ title: String) -> some View {
        modifier(LocalizedNavigationTitle(title: title))
    }
}
