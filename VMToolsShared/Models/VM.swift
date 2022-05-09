//
//  VM.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation
import Virtualization

public struct VM {
    public let name: String
    public let identifier: String
    public let vzVirtualMachine: VZVirtualMachine?
}
