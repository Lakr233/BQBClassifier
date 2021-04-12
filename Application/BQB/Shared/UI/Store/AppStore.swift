//
//  Environment.swift
//  BQB (iOS)
//
//  Created by Innei on 2021/4/4.
//

import Combine
import Foundation
#if os(iOS)
import UIKit
import Photos
#endif

@propertyWrapper
public struct UserDefaultsWrapper<Value> {

    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

public extension UserDefaultsWrapper where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
}

class AppStore: ObservableObject {
    
    static let shared = AppStore()
    
    private init() {
        confidenceControlBQB = AppDiskStore.shared.confidenceControlBQB
        if confidenceControlBQB < 0.5 {
            confidenceControlBQB = 0.8
        }
//        confidenceControlBAD = AppDiskStore.shared.confidenceControlBAD
        requireImageSizeSmall = AppDiskStore.shared.requireImageSizeSmall
        updatePrivacyStatus()
    }
    
    func updatePrivacyStatus() {
        let status = checkPrivacy()
        if status == -1 {
            permissionDenied = true
            permissionRequired = true
        } else if status == 1 {
            permissionRequired = true
            permissionDenied = false
        } else {
            permissionDenied = false
            permissionRequired = false
        }
    }
    
    @Published var selectedImages: [PHAsset] = []
    @Published var selectedAlbum: String = "表情包整理 - \(Int(Date().timeIntervalSince1970))"
    @Published var processedCount: Int = 0
    @Published var processedAllCount: Int = 0
    @Published var currentStep: Int = 0
    
    static let requiredSizeScale = 1500
    @Published var confidenceControlBQB: Double = 0.8 {
        didSet {
            AppDiskStore.shared.confidenceControlBQB = confidenceControlBQB
        }
    }
    @Published var requireImageSizeSmall: Int = 500 {
        didSet {
            AppDiskStore.shared.requireImageSizeSmall = requireImageSizeSmall
        }
    }
    @Published var detectQRCode: Bool = false {
        didSet {
            AppDiskStore.shared.detectQRCode = detectQRCode
        }
    }
    
    @Published var permissionRequired: Bool = false
    @Published var permissionDenied: Bool = false
    
}

class AppDiskStore {
    
    static let shared = AppDiskStore()
    private init() {}

    @UserDefaultsWrapper(key: "wiki.qaq.confidenceControlBQB", defaultValue: 0.8)
    var confidenceControlBQB: Double
    
    @UserDefaultsWrapper(key: "wiki.qaq.requireImageSizeSmall", defaultValue: 500)
    var requireImageSizeSmall: Int
    
    @UserDefaultsWrapper(key: "wiki.qaq.detectQRCode", defaultValue: false)
    var detectQRCode: Bool
    
}
