//
//  List.swift
//  cartsy
//
//  Created by Matheson Mawhinney on 2014-12-18.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import Foundation
import CoreData

class List: NSManagedObject {

    // Attributes
    @NSManaged var name:            String
    @NSManaged var isParent:          Bool
    // Relationships
    @NSManaged var toItems:         NSSet
    @NSManaged var toConjugalList:  List
    
    func addItem(item: Item) -> Void {
        var manyItems = self.mutableSetValueForKey("toItems")
        manyItems.addObject(item)
    }

}


