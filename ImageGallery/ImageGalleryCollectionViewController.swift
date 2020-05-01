//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Apple User on 22.04.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate,UICollectionViewDragDelegate, UICollectionViewDelegateFlowLayout {
    
    var images = [ImageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            imageCell.changeAspectRatio = { [weak self] in
                if let aspectRatio = self?.images[indexPath.item].ascpectRatio,
                    aspectRatio < 0.95 || aspectRatio > 1.05 {
                    self?.images[indexPath.item].ascpectRatio = 1.0
                    self?.flowLayout?.invalidateLayout()
                }
            }
            imageCell.imageURL = images[indexPath.item].url
        }
        return cell
    }
    
    
    struct Constants {
        static let columnCount = 3.0
        static let minWidthRatio = CGFloat(0.03)
    }
    
    var boundsCollectionWidth: CGFloat {
        return (collectionView?.bounds.width)!
    }
    
    var gapItems: CGFloat {
        return (flowLayout?.minimumInteritemSpacing)! * CGFloat((Constants.columnCount - 1.0))
    }
    
    var gapSections: CGFloat {
        return (flowLayout?.sectionInset.right)! * 2.0
    }
    
    var scale: CGFloat = 1  {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    var predefinedWidth: CGFloat {
        let width = floor((boundsCollectionWidth - gapItems - gapSections) / CGFloat(Constants.columnCount)) * scale
        return  min(max(width, boundsCollectionWidth * Constants.minWidthRatio), boundsCollectionWidth)}
    
    
    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = predefinedWidth
        let aspectRatio = CGFloat(images[indexPath.item].ascpectRatio)
        return CGSize(width: width, height: width / aspectRatio)
    }
    
    
    // MARK: - Image Fetcher && Drag and Drop
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let imageCell = collectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell,
            let image = imageCell.imageForCell.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = images[indexPath.item]
            return [dragItem]
        }
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
/// 1
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: NSURL.self) &&
            session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
/// 2
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    /// 3
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                // do the local case
                if let image = item.dragItem.localObject as? ImageModel {
                    collectionView.performBatchUpdates({
                         images.remove(at: sourceIndexPath.item)
                         images.insert(image, at: destinationIndexPath.item)
                        
                         collectionView.deleteItems(at: [sourceIndexPath])
                         collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                
                var optionalImageURL: URL?
                var optionalAspectRatio: Double?
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            optionalAspectRatio = Double(image.size.width)/Double(image.size.height)
                        }
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (nsurl, error) in
                    DispatchQueue.main.async {
                        if let url = nsurl as? URL {
                            optionalImageURL = url.imageURL
                        }
                        if optionalImageURL != nil, optionalAspectRatio != nil {
                            placeholderContext.commitInsertion(dataSourceUpdates: {
                                insertionIndexPath in
                                self.images.insert(ImageModel(url: optionalImageURL!, ascpectRatio: optionalAspectRatio!), at: insertionIndexPath.item)
                            })
                        } else {
                            print(error?.localizedDescription ?? "Error")
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}
/*
extension URL {
    var imageURL: URL {
        if let url = UIImage.urlToStoreLocallyAsJPEG(named: self.path) {
            // this was created using UIImage.storeLocallyAsJPEG
            return url
        } else {
            // check to see if there is an embedded imgurl reference
            for query in query?.components(separatedBy: "&") ?? [] {
                let queryComponents = query.components(separatedBy: "=")
                if queryComponents.count == 2 {
                    if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                        return url
                    }
                }
            }
            return self.baseURL ?? self
        }
    }
}

extension UIImage
{
    private static let localImagesDirectory = "UIImage.storeLocallyAsJPEG"
    
    static func urlToStoreLocallyAsJPEG(named: String) -> URL? {
        var name = named
        let pathComponents = named.components(separatedBy: "/")
        if pathComponents.count > 1 {
            if pathComponents[pathComponents.count-2] == localImagesDirectory {
                name = pathComponents.last!
            } else {
                return nil
            }
        }
        if var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent(localImagesDirectory)
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                url = url.appendingPathComponent(name)
                if url.pathExtension != "jpg" {
                    url = url.appendingPathExtension("jpg")
                }
                return url
            } catch let error {
                print("UIImage.urlToStoreLocallyAsJPEG \(error)")
            }
        }
        return nil
    }
}
*/
