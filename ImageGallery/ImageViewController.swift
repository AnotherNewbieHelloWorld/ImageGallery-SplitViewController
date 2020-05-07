//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Apple User on 07.05.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
        
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var autoZoomed = true
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
            autoZoomed = true
            zoomScaleToFit()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zoomScaleToFit()
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        autoZoomed = false
    }
    
    var imageView = UIImageView()

    private func fetchImage() {
        autoZoomed = true
        if let url = imageURL {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data, url == self?.imageURL {
                        self?.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func zoomScaleToFit() {
        guard !autoZoomed else { return }
        if let scrollView = scrollView, image != nil && imageView.bounds.size.width > 0  && scrollView.bounds.size.width > 0 {
            let widthRatio = scrollView.bounds.size.width  / imageView.bounds.size.width
            let heightRatio = scrollView.bounds.size.height / self.imageView.bounds.size.height
            scrollView.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio
            scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.size.width) / 2, y: (imageView.frame.size.height - scrollView.frame.size.height) / 2)
        }
    }

}
