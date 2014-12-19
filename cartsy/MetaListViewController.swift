//
//  MetaListsViewController.swift
//  cartsy
//
//  Created by Matheson Mawhinney and Alex Popov on 2014-12-13.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MetaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var metaListTable: UITableView!
    var tableData = [List]()
    lazy var managedObjectContext: NSManagedObjectContext? =  {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    // MARK: Boiletplate Overrides
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        var error: NSError?
        
        let fetchedResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [List]
        
        if let results = fetchedResults {
            tableData = results
        } else {
            println("Could not fetch: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        metaListTable.delegate = self
        metaListTable.dataSource = self
        metaListTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ListCell")
//        tableData.append("Grocery List")            // TODO: make a tableCreation method
//        tableData.append("Other List")              // TODO: fill table from Core Data, not hardcoded
    }
    
    // MARK: Table View Delegate Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "ListCell")
        cell.accessoryType = .DisclosureIndicator
        var rowData = tableData[indexPath.row]
//        cell.textLabel?.text = rowData
        cell.textLabel!.text = rowData.valueForKey("name") as String?
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row at index path \(indexPath)")            
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let groceryList = self.storyboard!.instantiateViewControllerWithIdentifier("MainList")! as GroceryListViewController // TODO: don't hardcode what list to go to.
        self.navigationController?.pushViewController(groceryList, animated: true)
    }
    
    // MARK: Homerolled Functions
    
    @IBAction func addNewList(sender: AnyObject) {
        var alert = UIAlertController(title: "Add", message: "Add new list", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.saveList(textField.text)
            self.metaListTable.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            //nothing
        }
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) -> Void in
        })
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        presentViewController(alert, animated: true, completion: nil)
    }
        
    func saveList(name: String) -> Void {
        let managedContext = self.managedObjectContext!
        let item = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: managedContext) as List
        item.name = name
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save! \(error)")
        }
        tableData.append(item)
    }
    
}