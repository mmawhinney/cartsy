//
//  CartsyViewController.swift
//  cartsy
//
//  Created by Alex Popov on 2014-12-26.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import UIKit
import CoreData

class CartsyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // +++++++++++++++++++++++++++
    // |    MARK: Our Objects    |
    // +++++++++++++++++++++++++++
    
    /// Array of Lists to populate tableView
    var mainList = List?()
    
    /// Manages Save Files
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let persistentStoreCoordinator = appDelegate.persistentStoreCoordinator {
            return persistentStoreCoordinator
        } else {
            return nil
        }
    }()
    
    /// Our interface to the Core Data; who you Fetch from and Save to.
    /// This class's entrypoint to The Context.
    lazy var managedObjectContext: NSManagedObjectContext? =  {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate     // select our app delegate
        if let managedObjectContext = appDelegate.managedObjectContext {                // this was created in AppDelegate as part of CoreData boilerplate
            return managedObjectContext
        } else {
            return nil
        }
    }()

    
    // +++++++++++++++++++++++++++++++++++++++++++++
    // |    MARK: Table View Delegate Functions    |
    // +++++++++++++++++++++++++++++++++++++++++++++
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "ListCell")
        return cell
    }
    
    /// Navigates to subList selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Homerolled Functions     |
    // +++++++++++++++++++++++++++++++++++++
    
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
    
    /// deletes swiped object from context.
    ///
    /// :returns: Void. Removes selected item from Core Data
    func deleteObject(fromArray: [AnyObject], atIndexPath: NSIndexPath) { // TODO: consider using MGSwipeTableCell to have Mailbox-style swipable thingies.
        var error : NSError?
        var object = fromArray[atIndexPath.row] as NSManagedObject
        
        managedObjectContext?.deleteObject(object)
        if !managedObjectContext!.save(&error) {
            println("Could not save! \(error)")
        }
    }
    
    /// fetch List entities for tableView
    ///
    /// :param: mainList Boolean, is this a sublist or our Main Fridge List
    ///
    /// :returns: Optional Array of Lists. If no lists were fetched we may return a nil. This must be handled properly.
    func fetchLists(managedObjectContext: NSManagedObjectContext, mainList: Bool = false) -> [List]? { // TODO: if we couldn't fetch results, think of an elegant way of recovering instead of unwrapping a nil as we do currently
        let fetchRequest = NSFetchRequest(entityName: "List") // want all lists
        fetchRequest.predicate = NSPredicate(format: "isMain = %@", mainList)
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
