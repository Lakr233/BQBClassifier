//
//  CardProcessing.swift
//  BQB
//
//  Created by Lakr Aream on 4/4/21.
//

import Photos
import SwiftUI

struct HomeCardProcessing: View {
    @EnvironmentObject var env: AppStore
    var progressProcessed: Int {
        env.processedCount
    }

    var progressAllItem: Int {
        env.processedAllCount
    }

    var body: some View {
        HomeCardBase {
            Group {
                HStack {
                    Image(systemName: "tortoise.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer().frame(width: 8)
                    Text("处理")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(Color("AccentColor"))
                Spacer().frame(height: 4)
                HStack {
                    Text("请稍等片刻 我们正在处理这些照片\n我们将会在处理完成以后显示处理的结果")
                        .frame(height: 40)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.6)
                }
                Spacer().frame(height: 4)
                Rectangle()
                    .frame(height: 0.5)
                    .opacity(0.6)
            }

            HStack {
                Spacer()
                Text(progressAllItem == 0
                    ? "无任务"
                        : (AppStore.shared.processedCount == AppStore.shared.processedAllCount
                        ? "处理完成 🎉"
                        : "处理进度 \(progressProcessed)/\(progressAllItem)"))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                Spacer()
            }
            if progressProcessed != 0 {
                ProgressView(value: Float(progressProcessed), total: Float(progressAllItem))
                    .animation(.easeIn(duration: 0.5), value: progressProcessed)
            }
        }
    }
}

struct HomeCardProcessing_Preview: PreviewProvider {
    static var previews: some View {
        HomeCardProcessing()
    }
}
