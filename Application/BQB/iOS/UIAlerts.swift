//
//  UIAlerts.swift
//  BQB (iOS)
//
//  Created by Lakr Aream on 4/6/21.
//

import UIKit

func presentAlert(title: String, message: String) {
    var vc = UIApplication.shared.windows.first?.rootViewController
    while vc?.presentedViewController != nil {
        vc = vc?.presentedViewController
    }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
    vc?.present(alert, animated: true, completion: nil)
}

func completeAlert(imgs: Int) {
    var vc = UIApplication.shared.windows.first?.rootViewController
    while vc?.presentedViewController != nil {
        vc = vc?.presentedViewController
    }
    let alert = UIAlertController(title: "🎉 处理成功", message: "共找到 \(imgs) 张表情包", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "完成", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "打开相册", style: .default, handler: { (_) in
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }))
    vc?.present(alert, animated: true, completion: nil)
}

func haptic() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
