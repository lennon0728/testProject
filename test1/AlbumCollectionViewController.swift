//
//  AlbumCollectionViewController.swift
//  test1
//
//  Created by Curry Lee on 15/07/2019.
//  Copyright © 2019 wanseok lee. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class AlbumCollectionViewController: UICollectionViewController {
    
    private var fetchResult: PHFetchResult<PHAsset>?
    private var albums: [PHAssetCollection]?
    private let cellReuseIdentifier: String = "albumCell"
    private lazy var cachingImageManager: PHCachingImageManager = {PHCachingImageManager() }()
    
}

extension AlbumCollectionViewController{
    
    private var systemAlbums: [PHAssetCollection]? {
        var albumList : [PHAssetCollection] = [PHAssetCollection]()
        
        if let cameraRoll: PHAssetCollection =
            PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: nil).firstObject{
            albumList.append(cameraRoll)
        }
    
    if let selfieAlbum: PHAssetCollection =
        PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits, options: nil).firstObject{
             albumList.append(selfieAlbum)
    }
    
    if let favoriteAlbum: PHAssetCollection =
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil).firstObject{
        albumList.append(favoriteAlbum)

    }
        return albumList
    }
}


extension AlbumCollectionViewController {
    
    /// 사용자 생성 앨범
    private var userAlbums: [PHAssetCollection]? {
        var albumList: [PHAssetCollection] = [PHAssetCollection]()
        
        let userAlbums: PHFetchResult<PHCollection>
        userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        for index in 0..<userAlbums.count {
            if let collection: PHAssetCollection =
                userAlbums.object(at: index) as? PHAssetCollection {
                
                albumList.append(collection)
            }
        }
        
        return albumList
    }
}

extension AlbumCollectionViewController {
    
    /// 시스템 앨범 + 사용자 앨범 불러오기
    private func loadAllAlbums() {
        self.fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        
        guard let systemAlbums = self.systemAlbums else { return }
        guard let userAlbums = self.userAlbums else { return }
        
        let albumList: [PHAssetCollection] = systemAlbums + userAlbums
        
        // 에셋이 존재하는 에셋 콜렉션만 필터링
        self.albums = albumList.filter { (collection: PHAssetCollection) -> Bool in
            PHAsset.fetchAssets(in: collection, options: nil).count > 0
        }
        
        OperationQueue.main.addOperation {
            self.collectionView?.reloadSections(IndexSet(0...0))
        }
    }
}

extension AlbumCollectionViewController {
    
    /// 사진첩 접근 권한 확인
    private func requestAlbumAuth() {
        
        let requestHandler = { (status: PHAuthorizationStatus) in
            switch status {
            case PHAuthorizationStatus.authorized:  self.loadAllAlbums()
            case PHAuthorizationStatus.denied:      print("사진첩 접근 거부됨")
            default: break
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case PHAuthorizationStatus.authorized:      self.loadAllAlbums()
        case PHAuthorizationStatus.denied:          print("사진첩 접근 거부됨")
        case PHAuthorizationStatus.restricted:      print("사집첩 접근 불가")
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization(requestHandler)
        }
    }
}

extension AlbumCollectionViewController {
    
    private func configureCell(_ cell: AlbumCollectionViewCell,
                               collectionView: UICollectionView,
                               indexPath: IndexPath) {
        
        guard let collection: PHAssetCollection = self.albums?[indexPath.item]
            else { return }
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection,
                                                             options: nil)
        
        guard let asset: PHAsset = fetchResult.lastObject else { return }
        
        cell.titleLabel.text = collection.localizedTitle
        cell.countLabel.text = "\(fetchResult.count)"
        
        let manager: PHCachingImageManager = self.cachingImageManager
        let handler: (UIImage?, [AnyHashable:Any]?) -> Void = { image, _ in
            
            let cellAtIndex: UICollectionViewCell? = collectionView.cellForItem(at: indexPath)
            guard let cell: AlbumCollectionViewCell = cellAtIndex as? AlbumCollectionViewCell
                else { return }
            
            cell.imageView.image = image
        }
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 200, height: 200),
                             contentMode: PHImageContentMode.aspectFill,
                             options: nil,
                             resultHandler: handler)
    }
}

extension AlbumCollectionViewController {
    
    // MARK:- UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        return self.albums?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: AlbumCollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier,
                                                  for: indexPath) as! AlbumCollectionViewCell
        
        self.configureCell(cell, collectionView: collectionView, indexPath: indexPath)
        
        return cell
    }
}

extension AlbumCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let flowLayout: UICollectionViewFlowLayout =
            self.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero}
        
        let numberOfCellsInRow: CGFloat = 2
        let viewSize: CGSize = self.view.frame.size
        let sectionInset: UIEdgeInsets = flowLayout.sectionInset
        
        let interitemSpace: CGFloat = flowLayout.minimumInteritemSpacing * (numberOfCellsInRow - 1)
        
        var itemWidth: CGFloat
        itemWidth = viewSize.width - sectionInset.left - sectionInset.right - interitemSpace
        itemWidth /= numberOfCellsInRow
        
        let itemSize = CGSize(width: itemWidth, height: itemWidth * 1.3)
        
        return itemSize
    }
}


extension AlbumCollectionViewController: PHPhotoLibraryChangeObserver {
    
    // MARK:- Reset Cache
    private func resetCachedAssets() {
        self.cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    // MARK:- PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult else { return }
        
        DispatchQueue.main.sync {
            guard let _ = changeInstance.changeDetails(for: fetchResult)
                else { return }
            
            self.resetCachedAssets()
            self.loadAllAlbums()
            self.collectionView?.reloadSections(IndexSet(0...0))
        }
    }
}

extension AlbumCollectionViewController  {
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestAlbumAuth()
        
        // 사진 라이브러리 변경을 감지할 수 있도록 등록
        PHPhotoLibrary.shared().register(self)
    }
}

extension AlbumCollectionViewController {
    
    // MARK:- Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? PhotoCollectionViewController,
            let cell: AlbumCollectionViewCell = sender as? AlbumCollectionViewCell,
            let indexPath: IndexPath = collectionView?.indexPath(for: cell)
            else { return }
        
        guard let assetCollection: PHAssetCollection = self.albums?[indexPath.item]
            else { return }
        
        destination.title = cell.titleLabel?.text
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: true)]
        OperationQueue().addOperation {
            
            destination.fetchResult = PHAsset.fetchAssets(in: assetCollection,
                                                          options: fetchOptions)
            
            destination.assetCollection = assetCollection
        }
    }
}
