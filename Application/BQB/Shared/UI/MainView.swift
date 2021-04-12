//
//  MainView.swift
//  BQB
//
//  Created by Lakr Aream on 4/4/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var env: AppStore
    var currentStep: Int {
        get { env.currentStep }
        set {
            env.currentStep = newValue
        }
    }

    var body: some View {
        ScrollViewReader { reader in
            VStack {
                
                Spacer().frame(height: 1).id("veryTop")
                
                if env.permissionRequired {
                    HomeCardBase {
                        Group {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer().frame(width: 8)
                                Text("警告")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(Color("AccentColor"))
                            Spacer().frame(height: 4)
                            HStack {
                                Text("相册权限错误\n这款 App 需要您提供相册权限才能帮您分类并识别表情包")
                                    .font(.system(size: 10, weight: .semibold))
                                    .opacity(0.6)
                            }
                            Spacer().frame(height: 4)
                            Rectangle()
                                .frame(height: 0.5)
                                .opacity(0.6)
                        }

                        if !env.permissionDenied {
                            Button(action: {
                                haptic()
                                fireAuthorizationAlert()
                            }, label: {
                                HStack {
                                    Image(systemName: "arrow.forward.circle.fill")
                                    Text("尝试获取权限")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .padding(4)
                            })
                        } else {
                            Button(action: {
                                haptic()
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }, label: {
                                HStack {
                                    Image(systemName: "arrow.forward.circle.fill")
                                    Text("打开设置")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .padding(4)
                            })
                        }
                    }
                    Spacer().frame(height: 20)
                    HStack {
                        Color(.red).frame(height: 0.5).opacity(0.5)
                        Text("WARNING")
                            .font(.system(size: 10, weight: .semibold))
                            .opacity(0.5)
                        Color(.red).frame(height: 0.5).opacity(0.5)
                    }
                    Spacer().frame(height: 20)
                        .id("start")
                }

                Group {
                    
                    Spacer()
                        .frame(height: 1)
                        .offset(y: -18)
                    
                    HomeCardStart()
                        .disabled(currentStep != 0).id("top")

                    Button(action: {
                        haptic()
                        if env.selectedImages.count < 1 {
                            presentAlert(title: "错误", message: "需要选择至少一张照片")
                            return
                        }
                        env.currentStep += 1
                        withAnimation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 0)) {
                            reader.scrollTo("second", anchor: .top)
                        }
                    }, label: {
                        HStack {
                            if currentStep == 0 {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("确认并继续")
                            } else {
                                Image(systemName: "arrowtriangle.down.circle.fill")
                                Text("检查点已确认")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .padding()
                    })
                        .disabled(currentStep != 0)
                        .id("second")
                }

                Group {
                    
                    Spacer()
                        .frame(height: 1)
                        .offset(y: -18)
                    
                    HomeCardSecond()
                        .disabled(currentStep != 1)

                    Button(action: {
                        haptic()
                        if env.selectedAlbum.count < 1 {
                            presentAlert(title: "错误", message: "相册名字不能为空")
                            return
                        }
                        env.currentStep += 1
                        withAnimation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 0)) {
                            reader.scrollTo("adjust", anchor: .top)
                        }
                        
                    }, label: {
                        HStack {
                            if currentStep == 1 {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("下一步")
                            } else if currentStep > 1 {
                                Image(systemName: "arrowtriangle.down.circle.fill")
                                Text("检查点已确认")
                            } else {
                                Image(systemName: "arrowtriangle.up.circle.fill")
                                Text("请先完成上面的检查点")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .padding()
                    })
                        .disabled(currentStep != 1)
                        .id("adjust")
                }

                Group {
                    
                    HomeCardAdjust()
                        .disabled(currentStep != 2)

                    Button(action: {
                        haptic()
                        BQBClassifierManager.shared.startJobs(urls: env.selectedImages) {
                            withAnimation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 0)) {
                                reader.scrollTo("veryTop", anchor: .top)
                            }
                        }
                        env.currentStep += 1
                        withAnimation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 0)) {
                            reader.scrollTo("final", anchor: .bottom)
                        }
                    }, label: {
                        HStack {
                            if currentStep == 2 {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("开始处理")
                            } else if currentStep > 2 {
                                Image(systemName: "arrowtriangle.down.circle.fill")
                                Text("检查点已确认")
                            } else {
                                Image(systemName: "arrowtriangle.up.circle.fill")
                                Text("请先完成上面的检查点")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .padding()
                    })
                        .disabled(currentStep != 2)
                }

                Group {
                    
                    Spacer()
                        .frame(height: 1)
                        .offset(y: -18)
                        .id("progress")
                    
                    HomeCardProcessing()
                        .disabled(currentStep != 2)
                }

                Group {
                    Spacer()
                        .frame(height: 20)
                    Text("Copyright (c) 2021 Lakr Aream & Innei - All rights reserved")
                        .font(.system(size: 8, weight: .semibold, design: .default))
                        .opacity(0.6)
                        .padding(.vertical, 5)
                    Button(action: {
                        haptic()
                        let url = URL(string: "https://github.com/Co2333/BQBClassifier")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }, label: {
                        Text("获取项目源码 ->")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    })
                    
                    Spacer()
                        .frame(height: 1)
                        .offset(y: 18)
                }

                // 避免 adjust 被移动到 top 的时候 超出范围
                // 然后用户拉动 scrollview 就很开心的反复横跳
                Spacer()
                    .frame(height: 25)
                    .id("final")
                Spacer()
                    .frame(height: 233)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
