//
//  AlbumPickerView.swift
//  BQB (iOS)
//
//  Created by Innei on 2021/4/5.
//
import PhotosUI
import SwiftUI
import UIKit

fileprivate let fixedWidth: CGFloat = 160
fileprivate let imageManager = PHCachingImageManager()

struct AlbumPickerView: View {
    @State var albums: [PHCollection] = []
    @State var thumbnails: [UIImage?] = []
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var env: AppStore
    private var onSelectAlbum: (String, [PHAsset], PHCollection) -> Void

    init(onSelectAlbum: @escaping ((String, [PHAsset], PHCollection) -> Void)) {
        self.onSelectAlbum = onSelectAlbum
    }

    let columns = [
        GridItem(.adaptive(minimum: fixedWidth)),
    ]
    
    var emptyThumbnail: some View {
        Rectangle().frame(height: fixedWidth).foregroundColor(.gray).opacity(0.6).overlay(Image(systemName: "rectangle.on.rectangle").font(.custom("", size: 40)).foregroundColor(.gray))
    }
    var body: some View {
        ScrollView {
        
            HStack {
                Text("选择一个相册").bold().font(.title).padding()
                Spacer()
            }

            if albums.count < 1 {
                HStack {
                    Text("您没有相册 😭 向下滑动来关闭")
                        .font(.system(size: 14, weight: .semibold))
                        .padding()
                    Spacer()
                }
            }
            
            LazyVGrid(columns: columns) {
                ForEach(0 ..< albums.count, id: \.self) { index in
                    Button(action: {
                        haptic()
                        let album = albums[index]
                        if let assetCollection = album as? PHAssetCollection {
                            let fetchedRes = PHAsset.fetchAssets(in: assetCollection, options: nil)
                            var fetchedAssets = [PHAsset]()
                            fetchedRes.enumerateObjects { asset, _, _ in
                                fetchedAssets.append(asset)
                            }
                            let title = album.localizedTitle ?? "Unknown"
                            onSelectAlbum(title, fetchedAssets, album)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        VStack {
                            Group {
                                if index < thumbnails.count {
                                    if let uiImage = thumbnails[index] {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: fixedWidth, height: fixedWidth, alignment: .center)
                                    } else {
                                        emptyThumbnail
                                    }
                                } else {
                                    emptyThumbnail
                                }
                            }

                            Text("\(albums[index].localizedTitle ?? "未命名相册")").font(.caption).foregroundColor(.black)
                        }
                    })
                }
            }
        }
        .padding()
        .onAppear {
            fetchAlbum()
            for album in albums {
                fetchThumbnail(collection: album, targetSize: .init(width: fixedWidth, height: fixedWidth)) { image in

                    guard let image = image else {
                        thumbnails.append(nil)
                        return
                    }

                    thumbnails.append(image)
                }
            }
        }
    }

    func fetchAlbum() {
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)

        var albums = [PHCollection]()

        for i in 0 ..< userCollections.count {
            albums.append(userCollections.object(at: i))
        }

        self.albums.append(contentsOf: albums)
    }
}

func fetchThumbnail(collection: PHCollection, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
    func fetchAsset(asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        // We could use PHCachingImageManager for better performance here
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { image, _ in
            completion(image)
        })
    }

    func fetchFirstImageThumbnail(collection: PHAssetCollection, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // We could sort by creation date here if we want
        let assets = PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
        if let asset = assets.firstObject {
            fetchAsset(asset: asset, targetSize: targetSize, completion: completion)
        } else {
            completion(nil)
        }
    }

    if let collection = collection as? PHAssetCollection {
        let assets = PHAsset.fetchKeyAssets(in: collection, options: PHFetchOptions())

        if let keyAsset = assets?.firstObject {
            fetchAsset(asset: keyAsset, targetSize: targetSize) { image in
                if let image = image {
                    completion(image)
                } else {
                    fetchFirstImageThumbnail(collection: collection, targetSize: targetSize, completion: completion)
                }
            }
        } else {
            fetchFirstImageThumbnail(collection: collection, targetSize: targetSize, completion: completion)
        }
    } else if let collection = collection as? PHCollectionList {
        // For folders we get the first available thumbnail from sub-folders/albums
        // possible improvement - make a "tile" thumbnail with 4 images
        let inner = PHCollection.fetchCollections(in: collection, options: PHFetchOptions())
        inner.enumerateObjects { innerCollection, idx, stop in
            fetchThumbnail(collection: innerCollection, targetSize: targetSize, completion: { image in
                if image != nil {
                    completion(image)
                    stop.pointee = true
                } else if idx >= inner.count - 1 {
                    completion(nil)
                }
            })
        }
    } else {
        // We shouldn't get here
        completion(nil)
    }
}
