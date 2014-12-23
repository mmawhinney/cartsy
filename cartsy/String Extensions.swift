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
    
    // capitalize string and remove any occurances of double+ spacing
    func sanitize(capitalize: Bool = true, singleSpaces: Bool = true) -> String {
        var tempString: String = self // had to cast because finding out length of a Swift String is impossible
        if (capitalize) {
            tempString = tempString.capitalizedString
        }
        if (singleSpaces) {
            tempString = tempString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            var newString = tempString.replace(tempString, regexPattern: "[ ]+", replacementPattern: " ")!
            return newString
        }
        return tempString
    }
    
//    func compressSpaces(input: String) -> String {
//        do {
//        input = input.
//        }e
//    }
//    return input
    
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