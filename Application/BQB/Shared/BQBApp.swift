//
//  BQBApp.swift
//  Shared
//
//  Created by Lakr Aream on 4/4/21.
//

import SwiftUI

@main
struct BQBApp: App {
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some Scene {
        WindowGroup {
            Group {
                NavigationView {
                    if idiom == .pad {
                        EmptyView()
                    }
                    HolderView()
                        .navigationTitle("表情包管理大师 🕶️")
                        .environmentObject(AppStore.shared)
                        .accentColor(Color("AccentColor"))
                        .navigationBarTitleDisplayMode(idiom == .pad ? .inline : .large)
                }
                
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                AppStore.shared.updatePrivacyStatus()
            }
        }
    }
}

let rootVC = UIApplication.shared.windows.first?.rootViewController!
