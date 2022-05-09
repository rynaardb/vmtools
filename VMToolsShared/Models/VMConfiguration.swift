//
//  VMConfiguration.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public struct VMConfiguration: Codable {
    let cpu: Int
    let memory: UInt64
    let disk: UInt64
    
    public init(cpu: Int, memory: UInt64, disk: UInt64) {
        self.cpu = cpu
        self.memory = memory
        self.disk = disk
    }
}
