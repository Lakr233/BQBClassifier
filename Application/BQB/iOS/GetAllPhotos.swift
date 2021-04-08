//
//  GetAllPhotos.swift
//  BQB (iOS)
//
//  Created by Lakr Aream on 4/4/21.
//

import Photos
import SwiftUI

private let cachingManager = PHCachingImageManager()

typealias AuthorizationStatus = Int
func checkPrivacy() -> AuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus()
    if status == .denied || status == .limited || status == .restricted {
        return -1
    }
    if status == .notDetermined {
        return 1
    }
    return 0
}

func fireAuthorizationAlert() {
    PHPhotoLibrary.requestAuthorization { (_) in
        DispatchQueue.main.async {
            AppStore.shared.updatePrivacyStatus()
        }
    }
}

func obtainAllPhotos() throws -> [PHAsset] {
    let fetchOpts = PHFetchOptions()
    fetchOpts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    let fetchedRes = PHAsset.fetchAssets(with: .image, options: fetchOpts)
    var fetchedAssets = [PHAsset]()
    fetchedRes.enumerateObjects { asset, _, _ in
        fetchedAssets.append(asset)
    }
    return fetchedAssets
}

extension PHAsset {
    func getURL(completionHandler: @escaping ((_ responseURL: URL?) -> Void)) {
        if mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { (_: PHAdjustmentData) -> Bool in
                true
            }
            requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: { (asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable: Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
