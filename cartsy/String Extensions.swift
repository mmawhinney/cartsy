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
        var trimmed: String?
        
        if andNewLines {
            trimmed = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        } else {
            trimmed = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return trimmed!
    }
    
    /// capitalize string and remove any occurances of double+ spacing
    ///
    /// :param: capitalize Will capitalize first letter of each word. Defaults to TRUE
    /// :param: singeSpaces Will compress multiple spaces down to one and will trim whitespace. Defaults to TRUE.
    ///
    func sanitize(capitalize: Bool = true, singleSpaces: Bool = true) -> String {
        var tempString: String = self
        if (capitalize) {
            tempString = tempString.capitalizedString
        }
        if (singleSpaces) {
            tempString = tempString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            tempString = tempString.replace(tempString, regexPattern: "[ ]+", replacementPattern: " ")!
        }
        return tempString
    }
    
    /// Regex Function
    ///
    /// :param: searchString string to search/remove from
    /// :param: regexPattern Regular Expression pattern to match with
    /// :param: replacementPattern Substitution string when pattern is matched
    /// 
    /// :returns: Optional String: nil if regex failss
    func replace(searchString:String, regexPattern : String, replacementPattern:String)->String?{
        var error: NSError?
        let regex = NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: &error)
        if (error == nil) {
            let searchString = regex?.stringByReplacingMatchesInString(searchString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, countElements(searchString)), withTemplate: replacementPattern)
            println("No error in Regex: \(error)")
            return searchString
        }
        println("Error in Regex: \(error)")
        return nil
    }
}