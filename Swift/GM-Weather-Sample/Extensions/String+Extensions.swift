//
//  String+Extensions.swift
//  GM-Weather-Sample
//
//  Created by Michael Dautermann on 6/1/18.
//  Copyright © 2018 Michael Dautermann. All rights reserved.
//

import Foundation

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var isProbableZipCode : Bool {
        return isNumber && self.count == 5
    }
}
