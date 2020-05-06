//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Apple User on 30.04.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct ImageModel {
    var url: URL
    var ascpectRatio: Double
}

struct ImageGalleryModel {
    var name: String
    var images = [ImageModel]()
    
    init(withName name: String) {
        self.name = name
    }
}
