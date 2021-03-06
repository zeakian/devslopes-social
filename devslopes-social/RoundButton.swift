//
//  RoundButton.swift
//  devslopes-social
//
//  Created by zeakian on 1/10/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        // Create shadow on button
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        // Set image (Facebook logo) to aspect fit
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make button a circle (can't do this in awakeFromNib because self.frame isn't set yet
        layer.cornerRadius = self.frame.width / 2
    }
}
