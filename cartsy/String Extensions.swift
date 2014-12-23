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
    
    // capitalize string and remove any occurances of double+ spacing
    func sanitize(capitalize: Bool = true, singleSpaces: Bool = true) -> String {
        var tempString = self as NSString // had to cast because finding out length of a Swift String is impossible
        if (capitalize) {
            tempString = tempString.capitalizedString
        }
        if (singleSpaces) {
            tempString = tempString.stringByReplacingOccurrencesOfString("[ ]+", withString: " ", options: NSStringCompareOptions.RegularExpressionSearch, range: NSRangeFromString(tempString)) /// FIXME: regex doesn't eliminate all double+ spaces
            tempString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return tempString
    }
}