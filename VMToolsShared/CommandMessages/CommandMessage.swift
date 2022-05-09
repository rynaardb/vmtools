//
//  CommandMessage.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public struct CommandMessage: Codable {
    var command: String
    var arguments: Dictionary<String, String>?
    var flags: [String]?
    
    public init(command: String, arguments: Dictionary<String, String>?, flags: [String]?) {
        self.command = command
        self.arguments = arguments
        self.flags = flags
    }
}

extension CommandMessage {
    public func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
