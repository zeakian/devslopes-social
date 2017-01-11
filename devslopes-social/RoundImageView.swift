//
//  RoundImageView.swift
//  devslopes-social
//
//  Created by zeakian on 1/11/17.
//  Copyright © 2017 zeakian. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()

        // Create shadow
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make imageview a circle (can't do this in awakeFromNib because self.frame isn't set yet
        layer.cornerRadius = self.frame.width / 2
    }
}
