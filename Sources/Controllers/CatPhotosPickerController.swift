//
//  CatImagePickerController.swift
//  CatMediaPicker
//
//  Created by Kcat on 2018/3/10.
//  Copyright © 2018年 ImKcat. All rights reserved.
//
// https://github.com/ImKcat/CatMediaPicker
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import Photos

// MARK: - CatPhotosPickerController Requirements
public class CatPhotosPickerControllerConfigure {

    public var mediaType: PHAssetMediaType = .image {
        didSet {
            switch mediaType {
            case .unknown:
                mediaType = .image
            default: break
            }
        }
    }
    public var maximumSelectCount: Int = 1 {
        didSet {
            if maximumSelectCount < 1 {
                maximumSelectCount = 1
            }
        }
    }
    public init() {}
    
}

public protocol CatPhotosPickerControllerDelegate: NSObjectProtocol {
    
    func didFinishPicking(pickerController: CatPhotosPickerController, media: [CatMedia])
    func didCancelPicking(pickerController: CatPhotosPickerController)
    
}

// MARK: - CatPhotosPickerController
public class CatPhotosPickerController: UINavigationController, UINavigationControllerDelegate, CatPhotosListControllerDelegate {
    
    public weak var pickerControllerDelegate: CatPhotosPickerControllerDelegate?
    
    // MARK: - Initialize
    public init(configure: CatPhotosPickerControllerConfigure? = CatPhotosPickerControllerConfigure()) {
        let listController = CatPhotosListController()
        listController.pickerControllerConfigure = configure!
        super.init(rootViewController: listController)
        listController.listControllerDelegate = self
        self.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CatPhotosListControllerDelegate
    func didTapDoneBarButtonItem(photosListController: CatPhotosListController, pickedAssets: [PHAsset]) {
        if self.pickerControllerDelegate != nil {
            guard pickedAssets.count != 0 else {
                self.pickerControllerDelegate?.didFinishPicking(pickerController: self, media: [])
                return
            }
            let media = pickedAssets.map{
                return CatMedia(type: $0.mediaType, source: $0)
            }
            self.pickerControllerDelegate?.didFinishPicking(pickerController: self, media: media)
        }
    }
    
    func didTapCancelBarButtonItem(photosListController: CatPhotosListController) {
        if self.pickerControllerDelegate != nil {
            self.pickerControllerDelegate?.didCancelPicking(pickerController: self)
        }
    }
    
}

// MARK: - CatPhotosListController Requirements
protocol CatPhotosListControllerDelegate: NSObjectProtocol {
    
    func didTapCancelBarButtonItem(photosListController: CatPhotosListController)
    func didTapDoneBarButtonItem(photosListController: CatPhotosListController, pickedAssets: [PHAsset])
    
}

// MARK: - CatPhotosListController
class CatPhotosListController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var listControllerDelegate: CatPhotosListControllerDelegate?
    var pickerControllerConfigure: CatPhotosPickerControllerConfigure = CatPhotosPickerControllerConfigure()
    var doneBarButtonItem: UIBarButtonItem?
    var cancelBarButtonItem: UIBarButtonItem?
    var photosAssets: [PHAsset] = []
    var selectedAssetIndexPaths: [IndexPath] = []
    
    // MARK: - Initialize
    init() {
        let photosListCollectionViewLayout = UICollectionViewFlowLayout()
        photosListCollectionViewLayout.minimumInteritemSpacing = 0
        photosListCollectionViewLayout.minimumLineSpacing = 0
        photosListCollectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
        super.init(collectionViewLayout: photosListCollectionViewLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Stack
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
    }
    
    func layoutInit() {
        self.title = String.localizedString(defaultString: "Photos", key: "CatMediaPicker.PhotosPickerControllerTitle", comment: "")
        self.view.backgroundColor = UIColor.white
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.alwaysBounceVertical = true
        self.cancelBarButtonItem = UIBarButtonItem(title: String.localizedString(defaultString: "Cancel", key: "CatMediaPicker.Cancel", comment: ""),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.doneBarButtonItem = UIBarButtonItem(title: String.localizedString(defaultString: "Done", key: "CatMediaPicker.Done", comment: ""),
                                                 style: .done,
                                                 target: self,
                                                 action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        self.collectionView?.register(CatPhotosListCollectionViewCell.self,
                                      forCellWithReuseIdentifier: String(describing: CatPhotosListCollectionViewCell.self))
    }
    
    func refreshData() {
        self.photosAssets.removeAll()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: self.pickerControllerConfigure.mediaType, options: fetchOptions)
        fetchResult.enumerateObjects { (asset, _, _) in
            self.photosAssets.append(asset)
        }
        self.collectionView?.reloadData()
    }
    
    // MARK: - Action
    @objc func cancelAction() {
        if self.listControllerDelegate != nil {
            self.listControllerDelegate?.didTapCancelBarButtonItem(photosListController: self)
        }
    }
    
    @objc func doneAction() {
        if self.listControllerDelegate != nil {
            let selectedIndexPaths = selectedAssetIndexPaths
            let selectedRows = selectedIndexPaths.map{
                return $0.row
            }
            let selectedAssets = selectedRows.map{
                return self.photosAssets[$0]
            }
            self.listControllerDelegate?.didTapDoneBarButtonItem(photosListController: self,
                                                                 pickedAssets: selectedAssets)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let flowLayout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: size.width / 4,
                                     height: size.width / 4)
        self.collectionView?.collectionViewLayout = flowLayout
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CatPhotosListCollectionViewCell.self), for: indexPath) as! CatPhotosListCollectionViewCell
        let photoAsset = photosAssets[indexPath.row]
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.resizeMode = .exact
        imageRequestOptions.normalizedCropRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        PHImageManager.default().requestImage(for: photoAsset,
                                              targetSize: CGSize(width: 200, height: 200),
                                              contentMode: PHImageContentMode.aspectFill,
                                              options: imageRequestOptions) { (photoImage, photoImageInfo) in
                                                guard photoImage != nil else {
                                                    return
                                                }
                                                cell.photoImageView.image = photoImage
        }
        cell.isSelected = selectedAssetIndexPaths.contains(indexPath) ? true : false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard selectedAssetIndexPaths.count < pickerControllerConfigure.maximumSelectCount else {
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAssetIndexPaths.append(indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        for i in 0...(selectedAssetIndexPaths.count - 1) {
            if selectedAssetIndexPaths[i] == indexPath {
                selectedAssetIndexPaths.remove(at: i)
                return
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosAssets.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

class CatPhotosListCollectionViewCell: UICollectionViewCell {
    
    var photoImageView: UIImageView
    var highlightView: UIView
    var checkmarkView: UIView = {
        let checkmarkView = UIView()
        
        let circleLayer = CAShapeLayer()
        let circlePath = UIBezierPath()
        circlePath.move(to: CGPoint(x: 10, y: 0))
        circlePath.addCurve(to: CGPoint(x: 0, y: 10), controlPoint1: CGPoint(x: 4.48, y: 0), controlPoint2: CGPoint(x: 0, y: 4.48))
        circlePath.addCurve(to: CGPoint(x: 10, y: 20), controlPoint1: CGPoint(x: 0, y: 15.52), controlPoint2: CGPoint(x: 4.48, y: 20))
        circlePath.addCurve(to: CGPoint(x: 20, y: 10), controlPoint1: CGPoint(x: 15.52, y: 20), controlPoint2: CGPoint(x: 20, y: 15.52))
        circlePath.addCurve(to: CGPoint(x: 10, y: 0), controlPoint1: CGPoint(x: 20, y: 4.48), controlPoint2: CGPoint(x: 15.52, y: 0))
        circlePath.close()
        circlePath.fill()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor(red: 0.0000000000,
                                        green: 0.4784313738,
                                        blue: 1.0000000000,
                                        alpha: 1.0000000000).cgColor
        
        let checkmarkLayer = CAShapeLayer()
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: 8.46, y: 13.54))
        checkmarkPath.addCurve(to: CGPoint(x: 8.03, y: 13.75),
                               controlPoint1: CGPoint(x: 8.34, y: 13.66),
                               controlPoint2: CGPoint(x: 8.18, y: 13.75))
        checkmarkPath.addCurve(to: CGPoint(x: 7.61, y: 13.54),
                               controlPoint1: CGPoint(x: 7.89, y: 13.75),
                               controlPoint2: CGPoint(x: 7.73, y: 13.65))
        checkmarkPath.addLine(to: CGPoint(x: 4.91, y: 10.85))
        checkmarkPath.addLine(to: CGPoint(x: 5.77, y: 9.99))
        checkmarkPath.addLine(to: CGPoint(x: 8.04, y: 12.26))
        checkmarkPath.addLine(to: CGPoint(x: 14.04, y: 6.22))
        checkmarkPath.addLine(to: CGPoint(x: 14.88, y: 7.09))
        checkmarkPath.addLine(to: CGPoint(x: 8.46, y: 13.54))
        checkmarkPath.close()
        checkmarkPath.usesEvenOddFillRule = true
        checkmarkPath.fill()
        checkmarkLayer.path = checkmarkPath.cgPath
        checkmarkLayer.fillColor = UIColor.white.cgColor
        
        checkmarkView.layer.addSublayer(circleLayer)
        checkmarkView.layer.addSublayer(checkmarkLayer)
        return checkmarkView
    }()
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.checkmarkView.alpha = self.isSelected ? 1 : 0
                self.highlightView.alpha = self.isSelected ? 0.3 : 0
            })
        }
    }
    
    override init(frame: CGRect) {
        self.photoImageView = UIImageView()
        self.highlightView = UIView()
        super.init(frame: frame)
        self.layoutInit()
    }
    
    func layoutInit() {
        self.photoImageView.contentMode = .scaleAspectFill
        self.photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.highlightView.backgroundColor = UIColor.white
        self.highlightView.alpha = 0
        self.highlightView.translatesAutoresizingMaskIntoConstraints = false
        
        self.checkmarkView.alpha = 0
        self.checkmarkView.contentMode = .scaleAspectFit
        self.checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.photoImageView)
        self.contentView.addSubview(self.highlightView)
        self.contentView.addSubview(self.checkmarkView)
        
        var constraintArray: [NSLayoutConstraint] = []
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[photoImageView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterX,
                                                                          metrics: nil,
                                                                          views: ["photoImageView": self.photoImageView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[photoImageView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["photoImageView": self.photoImageView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[highlightView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterX,
                                                                          metrics: nil,
                                                                          views: ["highlightView": self.highlightView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[highlightView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["highlightView": self.highlightView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[checkmarkView(20)]-|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["checkmarkView": self.checkmarkView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[checkmarkView(20)]-|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["checkmarkView": self.checkmarkView]))
        self.addConstraints(constraintArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
