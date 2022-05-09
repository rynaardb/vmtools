//
//  CommandFactory.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public enum KnownCommands: String {
    case createVM = "create"
    case startVM = "start"
    case stopVM = "stop"
}

public class CommandFactory {
    public static func create(_ command: KnownCommands, message: CommandMessage) -> Command {
        switch command {
        case .createVM:
            return CreateVMCommand(command: message.command, arguments: message.arguments, flags: message.flags)
        case .startVM:
            return StartVMCommand(command: message.command, arguments: message.arguments, flags: message.flags)
        case .stopVM:
            return StopVMCommand(command: message.command, arguments: message.arguments, flags: message.flags)
        }
    }
}
