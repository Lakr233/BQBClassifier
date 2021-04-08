//
//  CardSecond.swift
//  BQB
//
//  Created by Lakr Aream on 4/4/21.
//

import SwiftUI
import Photos

struct HomeCardSecond: View {
    
    // TODO 名字不是唯一的 改用 id
    // TODO 更好的名字
    @EnvironmentObject var env: AppStore
    @State var albumPickerOpen = false
    @State var foo = ""

    var body: some View {
        HomeCardBase {
            Group {
                HStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer().frame(width: 8)
                    Text("第二步")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(Color("AccentColor"))
                Spacer().frame(height: 4)
                HStack {
                    Text("现在需要您选择一个相册\n处理完成以后将会为你把表情包批量保存到这个相册")
                        .frame(height: 40)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.6)
                }
                Spacer().frame(height: 4)
                Rectangle()
                    .frame(height: 0.5)
                    .opacity(0.6)
            }
            
            VStack(spacing: 4) {
                HStack {
                    Text("当前相册")
                        .font(.system(size: 10, weight: .semibold, design: .default))
                        .opacity(0.6)
                    Spacer()
                }
                TextField("请给新的相册起个名", text: Binding<String>(
                            get: { () -> String in
                                foo
                            }, set: { (str) in
                                env.selectedAlbum = str
                                foo = str
                            }))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .opacity(0.8)
                HStack {
                    Button(action: {
                        setMagicAlbumName()
                        haptic()
                    }, label: {
                        HStack {
                            Text("使用默认名称")
                        }
                        .font(.system(size: 10, weight: .semibold))
                    })
                    Spacer()
                }
                .sheet(isPresented: $albumPickerOpen, content: {
                    AlbumPickerView { (title, assets, album) in
                        env.selectedAlbum = album.localIdentifier
                        foo = title
                    }
                })
            }
            .onAppear(perform: {
                setMagicAlbumName()
            })
            
        }
    }
    func setMagicAlbumName() {
        env.selectedAlbum = "表情包整理 - \(Int(Date().timeIntervalSince1970) / 60)"
        foo = env.selectedAlbum
    }
}

