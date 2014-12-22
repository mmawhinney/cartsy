//
//  NSString Extensions.swift
//  cartsy
//
//  Created by Alex Popov on 2014-12-21.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import Foundation

extension String {
    /// don't allow trailing or leading new lines/spaces, great for input fields
    func stringByTrimmingWhitespace(andNewLines: Bool = false) -> String {
        var trimmed: NSString?
        
        if andNewLines {
            trimmed = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        } else {
            trimmed = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return trimmed!
    }
}