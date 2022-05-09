//
//  VMInventory.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/05.
//

import Foundation

struct VMInventoryEntry {
    let name: String
    let dateStarted: Date
}

struct VMInventory {
    var runningVMS: Dictionary<String, VMInventoryEntry>
    
    mutating func addRunningVM(entry: VMInventoryEntry) {
        runningVMS[UUID().uuidString] = entry
    }
}
