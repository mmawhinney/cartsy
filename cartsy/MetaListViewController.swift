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
    @IBOutlet weak var addListButton: UIBarButtonItem!
    @IBOutlet weak var metaListTable: UITableView!
    var tableData = [String]()
    
    // MARK: Boiletplate Overrides
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        metaListTable.delegate = self
        metaListTable.dataSource = self
        tableData.append("Grocery List")            // TODO: make a tableCreation method
        tableData.append("Other List")              // TODO: fill table from Core Data, not hardcoded
        metaListTable.reloadData()
    }
    
    // MARK: Table View Delegate Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "myCell")
        cell.accessoryType = .DisclosureIndicator
        var rowData = tableData[indexPath.row]
        cell.textLabel?.text = rowData
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row at index path \(indexPath)")            
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let groceryList = self.storyboard!.instantiateViewControllerWithIdentifier("MainList")! as GroceryListViewController // TODO: don't hardcode what list to go to.
        self.navigationController?.pushViewController(groceryList, animated: true)
    }
    
    // MARK: Homerolled Functions
    
    
    
}