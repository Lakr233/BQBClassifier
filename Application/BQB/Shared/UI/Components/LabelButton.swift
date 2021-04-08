//
//  LabelButton.swift
//  BQB (iOS)
//
//  Created by Innei on 2021/4/4.
//

import SwiftUI

struct LabelButton: View {
    var action: () -> Void
    var title: String
    var systemImage: String
    var body: some View {
        Button(action: action, label: {
            HStack {
                Spacer()
                Label(title, systemImage: systemImage)
                Spacer()
            }.padding()
        })
    }
}
