//
//  Item.swift
//  MyToDoList
//
//  Created by Graphic Influence on 09/12/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
