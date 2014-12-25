//
//  ViewController Extensions.swift
//  cartsy
//
//  Created by Alex Popov on 2014-12-21.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    /// Add Button Pressed
    ///
    /// :param: object String representation of what you're saving, only used in alert dialogue
    /// :param: inTable UITableView of current View to reload data.
    /// :param: savedAs Save function for this type so that we can handle Lists and Items differents
    ///
    /// :returns: Void. Calls savedAs function and reloads view.
    func addNewPressed(#object: String, inTable: UITableView, savedAs: (String) -> Void) { /// TODO: try to make an optional closure at the end, should we need it
        // make alert with a save/cancel dialogue
        var alert = UIAlertController(title: "Add", message: "Add new \(object)", preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            var name = textField.text.stringByTrimmingWhitespace()
            name = name.sanitize(capitalize: true, singleSpaces: true)
            if name.isEmpty == false {
                savedAs(name)
            } else {
                println("we fucked up, empty string!") /// TODO: give a proper dialog saying not to save bullshit
            }
            inTable.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {(action: UIAlertAction!) -> Void in } // do nothing on Cancel
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) -> Void in })
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// fetch List entities for tableView
    ///
    /// :param: mainList Boolean, is this a sublist or our Main Fridge List
    ///
    /// :returns: Optional Array of Lists. If no lists were fetched we may return a nil. This must be handled properly.
    func fetchLists(managedObjectContext: NSManagedObjectContext, mainList: Bool = false) -> [List]? { // TODO: if we couldn't fetch results, think of an elegant way of recovering instead of unwrapping a nil as we do currently
        let fetchRequest = NSFetchRequest(entityName: "List") // want all lists
        fetchRequest.predicate = NSPredicate(format: "ANY isParent = %@", mainList)
        var error: NSError?
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [List] // fetch Lists from Context
        
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch: \(error)")
            return nil
        }
    }
    
}