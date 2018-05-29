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
    var authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus() {
        didSet {
            switch authorizationStatus {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: self.pickerControllerConfigure.mediaType, options: fetchOptions)
                fetchResult.enumerateObjects { (asset, _, _) in
                    self.photosAssets.append(asset)
                }
            default: break
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    var unauthorizedPlaceholderView: UIView = {
        
        let unauthorizedPlaceholderView = UIView()
        let lockLayer = CAShapeLayer()
        
        let lockPath = UIBezierPath()
        lockPath.move(to: CGPoint(x: 10.75, y: 17.3))
        lockPath.addLine(to: CGPoint(x: 13.6, y: 17.3))
        lockPath.addLine(to: CGPoint(x: 13.6, y: 11.69))
        lockPath.addCurve(to: CGPoint(x: 24.85, y: -0.01), controlPoint1: CGPoint(x: 13.6, y: 5.35), controlPoint2: CGPoint(x: 18.59, y: 0.09))
        lockPath.addCurve(to: CGPoint(x: 36.4, y: 11.53), controlPoint1: CGPoint(x: 31.19, y: -0.09), controlPoint2: CGPoint(x: 36.4, y: 5.14))
        lockPath.addLine(to: CGPoint(x: 36.4, y: 17.3))
        lockPath.addLine(to: CGPoint(x: 39.25, y: 17.3))
        lockPath.addCurve(to: CGPoint(x: 44, y: 22.11), controlPoint1: CGPoint(x: 41.86, y: 17.3), controlPoint2: CGPoint(x: 44, y: 19.47))
        lockPath.addLine(to: CGPoint(x: 44, y: 45.19))
        lockPath.addCurve(to: CGPoint(x: 39.25, y: 50), controlPoint1: CGPoint(x: 44, y: 47.84), controlPoint2: CGPoint(x: 41.86, y: 50))
        lockPath.addLine(to: CGPoint(x: 10.75, y: 50))
        lockPath.addCurve(to: CGPoint(x: 6, y: 45.19), controlPoint1: CGPoint(x: 8.14, y: 50), controlPoint2: CGPoint(x: 6, y: 47.84))
        lockPath.addLine(to: CGPoint(x: 6, y: 22.11))
        lockPath.addCurve(to: CGPoint(x: 10.75, y: 17.3), controlPoint1: CGPoint(x: 6, y: 19.47), controlPoint2: CGPoint(x: 8.14, y: 17.3))
        lockPath.close()
        lockPath.move(to: CGPoint(x: 23.34, y: 32.31))
        lockPath.addLine(to: CGPoint(x: 23.34, y: 40.58))
        lockPath.addCurve(to: CGPoint(x: 24.92, y: 42.31), controlPoint1: CGPoint(x: 23.34, y: 41.48), controlPoint2: CGPoint(x: 24.03, y: 42.26))
        lockPath.addCurve(to: CGPoint(x: 26.66, y: 40.62), controlPoint1: CGPoint(x: 25.87, y: 42.35), controlPoint2: CGPoint(x: 26.66, y: 41.59))
        lockPath.addLine(to: CGPoint(x: 26.66, y: 32.31))
        lockPath.addCurve(to: CGPoint(x: 28.79, y: 28.49), controlPoint1: CGPoint(x: 28.03, y: 31.63), controlPoint2: CGPoint(x: 28.93, y: 30.17))
        lockPath.addCurve(to: CGPoint(x: 25.27, y: 25.01), controlPoint1: CGPoint(x: 28.62, y: 26.63), controlPoint2: CGPoint(x: 27.11, y: 25.14))
        lockPath.addCurve(to: CGPoint(x: 21.2, y: 28.84), controlPoint1: CGPoint(x: 23.05, y: 24.85), controlPoint2: CGPoint(x: 21.2, y: 26.63))
        lockPath.addCurve(to: CGPoint(x: 23.34, y: 32.31), controlPoint1: CGPoint(x: 21.2, y: 30.37), controlPoint2: CGPoint(x: 22.07, y: 31.68))
        lockPath.close()
        lockPath.move(to: CGPoint(x: 16.93, y: 17.3))
        lockPath.addLine(to: CGPoint(x: 33.08, y: 17.3))
        lockPath.addLine(to: CGPoint(x: 33.08, y: 11.53))
        lockPath.addCurve(to: CGPoint(x: 30.7, y: 5.76), controlPoint1: CGPoint(x: 33.08, y: 9.36), controlPoint2: CGPoint(x: 32.23, y: 7.31))
        lockPath.addCurve(to: CGPoint(x: 25, y: 3.36), controlPoint1: CGPoint(x: 29.17, y: 4.21), controlPoint2: CGPoint(x: 27.15, y: 3.36))
        lockPath.addCurve(to: CGPoint(x: 19.3, y: 5.76), controlPoint1: CGPoint(x: 22.85, y: 3.36), controlPoint2: CGPoint(x: 20.83, y: 4.21))
        lockPath.addCurve(to: CGPoint(x: 16.93, y: 11.53), controlPoint1: CGPoint(x: 17.77, y: 7.31), controlPoint2: CGPoint(x: 16.93, y: 9.36))
        lockPath.addLine(to: CGPoint(x: 16.93, y: 17.3))
        lockPath.close()
        
        lockLayer.path = lockPath.cgPath
        lockLayer.fillColor = UIColor.lightGray.cgColor
        unauthorizedPlaceholderView.layer.addSublayer(lockLayer)
        return unauthorizedPlaceholderView
    }()

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
    
    /// Layout initialize
    func layoutInit() {
        title = String.localizedString(defaultString: "Photos", key: "CatMediaPicker.PhotosPickerControllerTitle", comment: "")
        view.backgroundColor = UIColor.white
        collectionView?.allowsMultipleSelection = true
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.alwaysBounceVertical = true
        cancelBarButtonItem = UIBarButtonItem(title: String.localizedString(defaultString: "Cancel", key: "CatMediaPicker.Cancel", comment: ""),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(cancelAction))
        navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        doneBarButtonItem = UIBarButtonItem(title: String.localizedString(defaultString: "Done", key: "CatMediaPicker.Done", comment: ""),
                                                 style: .done,
                                                 target: self,
                                                 action: #selector(doneAction))
        navigationItem.rightBarButtonItem = self.doneBarButtonItem
        collectionView?.register(CatPhotosListCollectionViewCell.self,
                                      forCellWithReuseIdentifier: String(describing: CatPhotosListCollectionViewCell.self))
        unauthorizedPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unauthorizedPlaceholderView)
        
        var constraintArray: [NSLayoutConstraint] = []
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[superView]-(<=1)-[unauthorizedPlaceholderView(50)]",
                                                                          options: NSLayoutFormatOptions.alignAllCenterX,
                                                                          metrics: nil,
                                                                          views: ["superView": view,
                                                                                  "unauthorizedPlaceholderView": unauthorizedPlaceholderView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[superView]-(<=1)-[unauthorizedPlaceholderView(50)]",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["superView": view,
                                                                                  "unauthorizedPlaceholderView": unauthorizedPlaceholderView]))
        view.addConstraints(constraintArray)
    }
    
    /// Refresh list
    func refreshData() {
        self.photosAssets.removeAll()
        if authorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { authorizationStatus in
                self.authorizationStatus = authorizationStatus
            }
        } else {
            self.authorizationStatus = PHPhotoLibrary.authorizationStatus()
        }
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
        UIView.animate(withDuration: 0.1) {
            self.unauthorizedPlaceholderView.alpha = self.photosAssets.count == 0 ? 1 : 0
        }
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
        photoImageView = UIImageView()
        highlightView = UIView()
        super.init(frame: frame)
        self.layoutInit()
    }
    
    func layoutInit() {
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        highlightView.backgroundColor = UIColor.white
        highlightView.alpha = 0
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        
        checkmarkView.alpha = 0
        checkmarkView.contentMode = .scaleAspectFit
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(photoImageView)
        contentView.addSubview(highlightView)
        contentView.addSubview(checkmarkView)
        
        var constraintArray: [NSLayoutConstraint] = []
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[photoImageView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterX,
                                                                          metrics: nil,
                                                                          views: ["photoImageView": photoImageView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[photoImageView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["photoImageView": photoImageView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[highlightView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterX,
                                                                          metrics: nil,
                                                                          views: ["highlightView": highlightView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[highlightView]|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["highlightView": highlightView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[checkmarkView(20)]-|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["checkmarkView": checkmarkView]))
        constraintArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[checkmarkView(20)]-|",
                                                                          options: NSLayoutFormatOptions.alignAllCenterY,
                                                                          metrics: nil,
                                                                          views: ["checkmarkView": checkmarkView]))
        self.addConstraints(constraintArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
