//
//  Category.swift
//  Todoey
//
//  Created by rongbaobao888 on 11/18/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var categoryCellBackgroundColor: String = ""
    let items = List<Item>()
}
