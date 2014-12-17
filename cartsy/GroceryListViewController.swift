//
//  GroceryListViewController.swift
//  cartsy
//
//  Created by Alex Popov on 2014-12-15.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var groceryListTable: UITableView!
    //var tableData = [String]()
    var tableData = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        groceryListTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell") // what does this do?
        
        groceryListTable.delegate = self
        groceryListTable.dataSource = self
//        tableData.append("Green eggs")
//        tableData.append("Ham")
        // groceryListTable.reloadData() // needed?
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier:  "Cell")
        // cell.accessoryType = .DisclosureIndicator
//        var rowData = tableData[indexPath.row]
//        cell.textLabel?.text = rowData
        let item = tableData[indexPath.row]
        cell.textLabel!.text = item.valueForKey("name") as String?
        return cell
    }
    
    func saveName(name: String) -> Void {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(name, forKey: "name")
        
        var error : NSError?
        
        if !managedContext.save(&error) {
            println("Could not save! \(error)")
        }
        
        tableData.append(item)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Save", message: "Savey!", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
//            self.tableData.append(textField.text)
            self.saveName(textField.text)
            self.groceryListTable.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            // nothing
        }
        
        alert.addTextFieldWithConfigurationHandler( {
            (textField: UITextField!) -> Void in
        } )
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Item")
        var error : NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            tableData = results
        } else {
            println("Could not fetch: \(error)")
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
