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

    @NSManaged var name: String
    @NSManaged var toItem: NSSet

}
