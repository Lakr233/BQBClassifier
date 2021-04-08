//
//  BQBClassifier.swift
//  BQB
//
//  Created by Lakr Aream on 4/4/21.
//

import CoreML
import Foundation
import Photos
import SwiftUI

final class BQBClassifierManager {
    
    private let core: BQBClassifier
    public static let shared = BQBClassifierManager()
    private init() {
        let model: MLModel = try! .init(contentsOf: BQBClassifier.urlOfModelInThisBundle)
        core = BQBClassifier(model: model)
    }

    struct ClassifierRecipe {
        let bqbUrls: [URL]
        let otherUrls: [URL]
    }

    func validResult(bqb: Double, bad: Double) -> Bool {
//        if bad > AppStore.shared.confidenceControlBAD {
//            return false
//        }
        if bqb > AppStore.shared.confidenceControlBQB {
            return true
        }
        return false
    }
    
    /// 识别表情包
    /// - Parameter pngData: 图片数据
    /// - Returns: 识别可信度 数据范围 0 到 1

    typealias isBQB = Bool
    public func recognizeImage(cgImage: CGImage, description: String) -> Bool {
        guard let mlObject = try? MLFeatureValue(cgImage: cgImage,
                                                 pixelsWide: 299,
                                                 pixelsHigh: 299,
                                                 pixelFormatType: kCVPixelFormatType_32BGRA,
                                                 options: nil),
            let buffer = mlObject.imageBufferValue
        else {
            print("Failed to load imageBufferValue at \(description)")
            return false
        }
        guard let result = try? core.prediction(image: buffer) else {
            print("Failed to process image prediction at \(description)")
            return false
        }
        let bqbConfidence = result.classLabelProbs["BQB"] ?? 0.0
        let badConfidence = result.classLabelProbs["BAD"] ?? 0.0
        let decision = validResult(bqb: bqbConfidence, bad: badConfidence)
        debugPrint("Prediction at \(description) bqb: \(Int(bqbConfidence * 100))% bad: \(Int(badConfidence * 100))% \(decision ? "🎉" : "❌")")
        return decision
    }

    // TODO: 锁UI界面
    var lock = NSLock()
    public func startJobs(urls: [PHAsset], completion: @escaping (() -> ())) {
        lock.lock()

        // 状态
        AppStore.shared.processedCount = 0
        AppStore.shared.processedAllCount = urls.count

        // 创建 album
        let albumName = AppStore.shared.selectedAlbum
        var collection: PHFetchResult<PHAssetCollection>
        collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumName], options: nil)
        if collection.count == 0 {
            try! PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        }

        let albumObject = collection.firstObject!

        DispatchQueue.global().async { [self] in
            // 开始处理
            // FIX ME: 创建预览列表
//            var assetsList = [PHAsset]()
            var found = 0
            for asset in AppStore.shared.selectedImages {
                autoreleasepool {
                    let recipe = self.generateRecipe(asset: asset)
                    if recipe {
//                        assetsList.append(asset)
                        found += 1
                        addToAlbum(asset: asset, album: albumObject)
                    }
                }
                DispatchQueue.main.async {
                    AppStore.shared.processedCount += 1
                }
            }
            print("BQBClassifier completed!")
//            print("Sending items to album")
//            for item in assetsList {
//                addToAlbum(asset: item, album: albumObject)
//            }
            print("Completed!")
            DispatchQueue.main.async {
                lock.unlock()
                AppStore.shared.selectedImages = []
//                AppStore.shared.selectedAlbum = "表情包整理 - \(Int(Date().timeIntervalSince1970))"
                AppStore.shared.processedCount = 0
                AppStore.shared.processedAllCount = 0
                AppStore.shared.currentStep = 0
                
                completeAlert(imgs: found)
                completion()
            }
        }
    }

    func addToAlbum(asset: PHAsset, album: PHAssetCollection) {
        try? PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCollectionChangeRequest(for: album)
            request?.addAssets([asset] as NSFastEnumeration)
        }
    }

    func generateRecipe(asset: PHAsset) -> Bool {
        let image = getAssetThumbnail(asset: asset)
    
        guard let _image = image, let cg = _image.cgImage else {
            return false
        }
        let ai = recognizeImage(cgImage: cg, description: "none")
        return ai
    }

    func getAssetThumbnail(asset: PHAsset) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        if asset.pixelHeight > AppStore.shared.requireImageSizeSmall
            || asset.pixelWidth > AppStore.shared.requireImageSizeSmall {
            debugPrint("This image's height or width greater than \(AppStore.shared.requireImageSizeSmall), skip.")
            return nil
        }
        manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option, resultHandler: { result, _ in
            if let result = result {
                thumbnail = result
            }
        })
        return thumbnail
    }
}
