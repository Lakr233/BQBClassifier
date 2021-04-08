//
//  HomeCardBase.swift
//  BQB (iOS)
//
//  Created by Innei on 2021/4/4.
//

import SwiftUI

struct HomeCardBase<Content>: View where Content: View {
    var content: Content
    @inlinable public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .background(Color
                        .systemBackground
                        .cornerRadius(12)
                        .shadow(radius: 12, y: 6)
                        .opacity(0.5))
    }
}
