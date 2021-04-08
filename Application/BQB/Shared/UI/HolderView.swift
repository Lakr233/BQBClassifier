//
//  HolderView.swift
//  Shared
//
//  Created by Lakr Aream on 4/4/21.
//

/*

    这个 view 拿来拿来存放 MainView
    实现剧中布局和以后可能要处理的一些东西
    QAQ

 */

import SwiftUI

struct HolderView: View {
    var body: some View {
        ScrollView(showsIndicators: UIDevice.current.userInterfaceIdiom != .pad) {
            Spacer().frame(height: 25)
            HStack {
                Spacer()
                Group {
                    MainView()
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: 500)
                .padding(EdgeInsets(top: 0,
                                    leading: 12,
                                    bottom: 0,
                                    trailing: 12))
                Spacer()
            }
        }
    }
}
