//
//  DisableableButton.swift
//  SwiftBank
//
//  Created by Macbook Air on 23.02.2023.
//

import Foundation
import UIKit


class DisableableButton : UIButton {
    
    var disabledBackgroundColor : UIColor!
    var enabledBackgroundColor : UIColor!
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled { self.backgroundColor = disabledBackgroundColor }
            else    { self.backgroundColor = enabledBackgroundColor  }
        }
    }
    
    
    
    
    
    
}
