//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Apple User on 22.04.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageForCell: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet { updateUI() }
    }
    
    var changeAspectRatio: (() -> Void)?
    
    private func updateUI() {
        if let url = imageURL {
            imageForCell.image = nil
            spinner.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let data = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    if let imData = data, url == self.imageURL, let image = UIImage(data: imData) {
                        self.imageForCell.image = image
                    }
//                    else {
//                        self.imageForCell.image = UIImage(systemName: "photo")
//                        self.changeAspectRatio?()
//                    }
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}

