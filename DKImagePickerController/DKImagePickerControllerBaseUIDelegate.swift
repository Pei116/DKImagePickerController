//
//  DKImagePickerControllerBaseUIDelegate.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKImagePickerControllerBaseUIDelegate: NSObject, DKImagePickerControllerUIDelegate {
	
	open weak var imagePickerController: DKImagePickerController!
	
	open var doneButton: UIButton?
    
    public required init(imagePickerController: DKImagePickerController) {
        self.imagePickerController = imagePickerController
        
        super.init()
    }
	
	open func createDoneButtonIfNeeded() -> UIButton {
        if self.doneButton == nil {
            let button = UIButton(type: UIButtonType.custom)
            button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, for: .normal)
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: UIControlEvents.touchUpInside)
            self.doneButton = button
            self.updateDoneButtonTitle(button)
        }
		
		return self.doneButton!
	}
    
    open func updateDoneButtonTitle(_ button: UIButton) {
        if self.imagePickerController.selectedAssetIdentifiers.count > 0 {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: Locale.current.identifier)
            
            let formattedSelectableCount = formatter.string(from: NSNumber(value: self.imagePickerController.selectedAssetIdentifiers.count))
            
            button.setTitle(String(format: DKImagePickerControllerResource.localizedStringWithKey("picker.select.title"),
                                   formattedSelectableCount ?? self.imagePickerController.selectedAssetIdentifiers.count), for: .normal)
        } else {
            button.setTitle(DKImagePickerControllerResource.localizedStringWithKey("picker.select.done.title"), for: .normal)
        }
        
        button.sizeToFit()
        
        if #available(iOS 11.0, *) { // Handle iOS 11 BarButtonItems bug
            if button.constraints.count == 0 {
                button.widthAnchor.constraint(equalToConstant: button.bounds.width).isActive = true
                button.heightAnchor.constraint(equalToConstant: button.bounds.height).isActive = true
            } else {
                for constraint in button.constraints {
                    if constraint.firstAttribute == .width {
                        constraint.constant = button.bounds.width
                    } else if constraint.firstAttribute == .height {
                        constraint.constant = button.bounds.height
                    }
                }
            }
        }
    }
	
	// Delegate methods...
	
	open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createDoneButtonIfNeeded())
	}
        	
	open func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(imagePickerController.dismiss as () -> Void))
	}
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
    
    open func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
    }
	    
    open func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
    }
	
	open func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: Locale.current.identifier)
        
        let formattedMaxSelectableCount = formatter.string(from: NSNumber(value: imagePickerController.maxSelectableCount))
        
        let alert = UIAlertController(title: DKImagePickerControllerResource.localizedStringWithKey("picker.select.maxLimitReached.error.title"), message: nil, preferredStyle: .alert)
        
        alert.message = String(format: DKImagePickerControllerResource.localizedStringWithKey("picker.select.maxLimitReached.error.message"), formattedMaxSelectableCount ?? imagePickerController.maxSelectableCount)
        
        alert.addAction(UIAlertAction(title: DKImagePickerControllerResource.localizedStringWithKey("picker.alert.ok"), style: .cancel) { _ in })
        
        imagePickerController.present(alert, animated: true){}
	}
	
	open func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
    
    open func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    open func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return DKAssetGroupDetailImageCell.self
    }
    
    open func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type {
        return DKAssetGroupDetailCameraCell.self
    }
    
    open func imagePickerControllerCollectionVideoCell() -> DKAssetGroupDetailBaseCell.Type {
        return DKAssetGroupDetailVideoCell.self
    }
		
}
