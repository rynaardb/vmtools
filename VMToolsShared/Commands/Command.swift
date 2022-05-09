//
//  Command.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public protocol Command {
    var command: String { get }
    var arguments: Dictionary<String, String>? { get }
    var flags: [String]? { get }
    
    func execute() -> String
}
