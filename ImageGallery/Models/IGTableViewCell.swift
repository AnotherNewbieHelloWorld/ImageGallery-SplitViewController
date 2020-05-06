//
//  IGTableViewCell.swift
//  ImageGallery
//
//  Created by Apple User on 05.05.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class IGTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(startEditing))
            doubleTap.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap)
            textField.delegate = self
        }
    }
    
    @objc func startEditing() {
        textField.isEnabled = true
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
}
