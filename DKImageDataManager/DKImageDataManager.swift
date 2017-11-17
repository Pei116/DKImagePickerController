//
//  DKImageDataManager.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

public func getImageDataManager() -> DKImageDataManager {
	return DKImageDataManager.sharedInstance
}

public class DKImageDataManager {
	
	public class func checkPhotoPermission(_ handler: @escaping (_ granted: Bool) -> Void) {
		func hasPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .authorized
		}
		
		func needsToRequestPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .notDetermined
		}
		
		hasPhotoPermission() ? handler(true) : (needsToRequestPhotoPermission() ?
			PHPhotoLibrary.requestAuthorization({ status in
				DispatchQueue.main.async(execute: { () in
					hasPhotoPermission() ? handler(true) : handler(false)
				})
			}) : handler(false))
	}
	
	static let sharedInstance = DKImageDataManager()
	
    private let manager = PHCachingImageManager()
	
	private lazy var defaultImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		
		return options
	}()
	
	private lazy var defaultVideoRequestOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.deliveryMode = .mediumQualityFormat
		
		return options
	}()
	
	public var autoDownloadWhenAssetIsInCloud = true
	
	public func fetchImage(for asset: DKAsset, size: CGSize, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchImage(for: asset, size: size, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchImage(for asset: DKAsset, size: CGSize, contentMode: PHImageContentMode, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchImage(for: asset, size: size, options: nil, contentMode: contentMode, completeBlock: completeBlock)
	}

	public func fetchImage(for asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchImage(for: asset, size: size, options: options, contentMode: .aspectFill, completeBlock: completeBlock)
	}
	
	public func fetchImage(for asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode,
	                               completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
            let options = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions

            self.manager.requestImage(for: asset.originalAsset!,
                                      targetSize: size,
                                      contentMode: contentMode,
                                      options: options,
                                      resultHandler: { image, info in
                                        if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                                            , image == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
                                            options.isNetworkAccessAllowed = true
                                            self.fetchImage(for: asset, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
                                        } else {
                                            completeBlock(image, info)
                                        }
            })
	}
	
	public func fetchImageData(for asset: DKAsset, options: PHImageRequestOptions?, completeBlock: @escaping (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void) {
        let usedOptions = options ?? self.defaultImageRequestOptions
        
		self.manager.requestImageData(for: asset.originalAsset!,
		                                      options: usedOptions) { (data, dataUTI, orientation, info) in
												if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
													, data == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
                                                    
                                                    if !usedOptions.isNetworkAccessAllowed {
                                                        let requestCloudOptions = usedOptions.copy() as! PHImageRequestOptions
                                                        requestCloudOptions.isNetworkAccessAllowed = true
                                                        self.fetchImageData(for: asset, options: requestCloudOptions, completeBlock: completeBlock)
                                                    } else {
                                                        completeBlock(data, info)
                                                    }
                                                    
												} else {
													completeBlock(data, info)
												}
		}
	}
	
	public func fetchAVAsset(for asset: DKAsset, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchAVAsset(for: asset, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchAVAsset(for asset: DKAsset, options: PHVideoRequestOptions?, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.manager.requestAVAsset(forVideo: asset.originalAsset!,
			options: options ?? self.defaultVideoRequestOptions) { avAsset, audioMix, info in
				if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
					, avAsset == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
					let requestCloudOptions = (options ?? self.defaultVideoRequestOptions).copy() as! PHVideoRequestOptions
					requestCloudOptions.isNetworkAccessAllowed = true
                    self.fetchAVAsset(for: asset, options: requestCloudOptions, completeBlock: completeBlock)
				} else {
					completeBlock(avAsset, info)
				}
		}
	}
    
    public func startCachingAssets(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        self.manager.startCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    
    public func stopCachingAssets(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        self.manager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    
    public func stopCachingForAllAssets() {
        self.manager.stopCachingImagesForAllAssets()
    }
}