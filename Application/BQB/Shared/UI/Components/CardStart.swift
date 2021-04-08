//
//  CardStart.swift
//  BQB
//
//  Created by Lakr Aream on 4/4/21.
//

import Photos
import SwiftUI

struct HomeCardStart: View {

    @State var confirmed: Bool = false
    @State var processing: Bool = false
    @State var pickerOpen = false
    @State var albumPickerOpen = false
    
    enum SheetType {
        case album
        case element
    }
    @State var sheetType: SheetType = .album
    
    @EnvironmentObject var env: AppStore

    var body: some View {
        HomeCardBase {
            Group {
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer().frame(width: 8)
                    Text("起点")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    ProgressView()
                        .opacity(processing ? 1 : 0)
                }
                .foregroundColor(Color("AccentColor"))
                Spacer().frame(height: 4)
                HStack {
                    Text("选择需要整理和识别的照片范围\n我们将为您从这些照片里面查找并识别表情包")
                        .frame(height: 40)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.6)
                }
                Spacer().frame(height: 4)
                Rectangle()
                    .frame(height: 0.5)
                    .opacity(0.6)
                Spacer().frame(height: 4)
                Text("您已选择了 \(env.selectedImages.count) 张照片")
                    .font(.system(size: 10, weight: .semibold))
                    .opacity(0.6)
                Spacer().frame(height: 8)
            }
            VStack {
                HStack {
                    Button(action: {
                        haptic()
                        processing = true
                        #if os(iOS)
                            DispatchQueue.global(qos: .background).async {
                                let items = (try? obtainAllPhotos()) ?? []
                                DispatchQueue.main.async {
                                    env.selectedImages = items
                                    processing = false
                                }
                            }
                        #else
                            fatalError()
                        #endif
                    }, label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("选择全部照片")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding(4)
                    })
                        .disabled(processing)
                    Spacer()
                }
                HStack {
                    Button(action: {
                        haptic()
                        env.selectedImages = []
                        sheetType = .album
                        pickerOpen.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("选择一个相册")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding(4)
                    })
                        .disabled(processing)

                    Spacer()
                }
                HStack {
                    Button(action: {
                        haptic()
                        env.selectedImages = []
                        sheetType = .element
                        pickerOpen.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("选择一些照片")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding(4)
                    })
                        .disabled(processing)
                    Spacer()
                }
            }
            Button(action: {
                haptic()
                env.selectedImages = []
            }, label: {
                Text("重置选择")
                    .font(.system(size: 12, weight: .semibold, design: .default))
            })
                .disabled(processing)
        }
        .sheet(isPresented: $pickerOpen) {
            if sheetType == .album {
                AlbumPickerView { (title, assets, _) in
                    env.selectedImages = assets
                }
            } else {
                ImagePickerView(showPicker: $pickerOpen) { (assets) in
                    env.selectedImages = assets
                }
            }
        }
    }
    
}

struct HomeCardStart_Previews: PreviewProvider {
    static var previews: some View {
        HomeCardStart()
    }
}
