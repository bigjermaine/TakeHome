//
//  UndoBanner.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct UndoBanner: View {
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .lineLimit(1)
            Spacer()
            Button(actionTitle, action: action)
                .fontWeight(.semibold)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 8, y: 4)
    }
}
