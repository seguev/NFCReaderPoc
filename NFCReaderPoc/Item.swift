//
//  Item.swift
//  NFCReaderPoc
//
//  Created by segev perets on 31/05/2023.
//

import UIKit

struct Item : Hashable {
    let name : String
    private let uuid = UUID()
    
//    static func ==(lhs: Item, rhs: Item) -> Bool {
//        return lhs.uuid == rhs.uuid
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
