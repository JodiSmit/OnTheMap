//
//  RoundedButton.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

 @IBDesignable class RoundedButton: UIButton
    {
        override func layoutSubviews() {
            super.layoutSubviews()
            
            updateCornerRadius()
        }
        
        @IBInspectable var rounded: Bool = false {
            didSet {
                updateCornerRadius()
            }
        }
        
        func updateCornerRadius() {
            layer.cornerRadius = rounded ? frame.size.height / 6 : 0
        }
    }

