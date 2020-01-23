//
//  Category.swift
//  MyToDoList
//
//  Created by Graphic Influence on 20/01/2020.
//  Copyright © 2020 marianne massé. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<Item>()
}
