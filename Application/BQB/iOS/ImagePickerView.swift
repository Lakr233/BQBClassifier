//
//  ImagePickerView.swift
//  BQB (iOS)
//
//  Created by Innei on 2021/4/4.
//

import Foundation
import PhotosUI
import SwiftUI
struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var showPicker: Bool
    var onCompleteSheet: (([PHAsset]) -> ())

    func makeUIViewController(context: Context) -> some UIViewController {
        
        // just present alert for privacy rights
        let fetchOpts = PHFetchOptions()
        fetchOpts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let _ = PHAsset.fetchAssets(with: .image, options: fetchOpts)
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.filter = .images
        config.selectionLimit = 65535
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.showPicker = false

            let identifiers = results.compactMap(\.assetIdentifier)
            let fetchedRes = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            var fetchedAssets = [PHAsset]()
            fetchedRes.enumerateObjects { asset, _, _ in
                fetchedAssets.append(asset)
            }
            parent.onCompleteSheet(fetchedAssets)
            
        }
    }
}
