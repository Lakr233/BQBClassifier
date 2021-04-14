//
//  CardAdjust.swift
//  BQB (iOS)
//
//  Created by Lakr Aream on 4/8/21.
//

import SwiftUI

fileprivate var prevVals: [String: String] = [:]

struct HomeCardAdjust: View {
    @EnvironmentObject var env: AppStore

    @State var bqbConfidence = 0.75
    @State var badConfidence = 0.25
    @State var requiredSizePercent: Double = 0.5

    var body: some View {
        HomeCardBase {
            Group {
                HStack {
                    Image(systemName: "lasso.sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer().frame(width: 8)
                    Text("优化调整")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(Color("AccentColor"))
                Spacer().frame(height: 4)
                HStack {
                    Text("在进行处理之前您可以指定识别的灵敏度\n较高的灵敏度会要求更高的匹配可信度也会有更少的照片被选中")
                        .frame(height: 35)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.6)
                }
                Spacer().frame(height: 4)
                Rectangle()
                    .frame(height: 0.5)
                    .opacity(0.6)
            }

            VStack(spacing: 0) {
                HStack {
                    Text("期望图片尺寸")
                        .opacity(0.8)
                    Spacer()
                    Text("<= \(env.requireImageSizeSmall)px")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .font(.system(size: 16, weight: .semibold))

                Slider(value: $requiredSizePercent.onChange({ newValue in
                    if prevVals["size", default: ""] != "<= \(newValue)px" {
                        haptic()
                        prevVals["size", default: ""] = "<= \(newValue)px"
                    }
                    env.requireImageSizeSmall = Int(newValue * Double(AppStore.requiredSizeScale))
                }), in: 0 ... 1).onAppear {
                    requiredSizePercent = Double(env.requireImageSizeSmall) / Double(AppStore.requiredSizeScale)
                }
            }
            Spacer().frame(height: 20)
            VStack(spacing: 0) {
                HStack {
                    Text("期望表情可信度")
                        .opacity(0.8)
                    Spacer()
                    Text(">= \(Int(env.confidenceControlBQB * 100))%")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .font(.system(size: 16, weight: .semibold))

                Slider(value: $bqbConfidence.onChange({ newValue in
                    if prevVals["bqb", default: ""] != ">= \(Int(newValue * 100))%" {
                        haptic()
                        prevVals["bqb", default: ""] = ">= \(Int(newValue * 100))%"
                    }
                    env.confidenceControlBQB = newValue
                }), in: 0 ... 1).onAppear {
                    bqbConfidence = env.confidenceControlBQB
                }
            }
            
            Spacer().frame(height: 20)
            VStack(spacing: 0) {
                HStack {
                    Text("排除二维码")
                        .opacity(0.8)
                    Spacer()
                    Button(action: {
                        haptic()
                        env.detectQRCode.toggle()
                    }, label: {
                        HStack {
                            Text(env.detectQRCode ? "已启用" : "启用")
                            Image(systemName: env.detectQRCode ? "qrcode.viewfinder" : "viewfinder")
                        }
                        .font(.system(size: 16, weight: .semibold))
                    })
                }
                .font(.system(size: 16, weight: .semibold))
                HStack {
                    Text("检测二维码会消耗大量的计算资源 会显著影响处理时间")
                        .frame(height: 35)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.6)
                    Spacer()
                }

                
            }
            

            Spacer().frame(height: 20)
            Text("""
            小贴士

            机器学习并不是万能的
            即使测试样本中我们的模型识别成功率高达90%
            实际使用中也依然有可能出现一张都无法识别的可能性
            请考虑前往 GitHub 提交一些学习数据
            感谢
            """)
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .opacity(0.6)
        }
    }
}
