//
//  MaxLengthTextField.swift
//  MyCloudNotes
//
//  Created by Jason Chang on 1/13/17.
//  Copyright © 2017 Jason Chang. All rights reserved.
//

import Foundation
import UIKit

// 1
class MaxLengthTextField: UITextField, UITextFieldDelegate {
    
    // 2
    private var characterLimit: Int?
    
    
    // 3
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    // 4
    @IBInspectable var maxLength: Int {
        get {
            guard let length = characterLimit else {
                return Int.max
            }
            return length
        }
        set {
            characterLimit = newValue
        }
    }
    
}
