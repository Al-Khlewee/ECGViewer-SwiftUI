//
//  CardView.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/Components/CardView.swift
import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat

    init(padding: CGFloat = 0, cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
