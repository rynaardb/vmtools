//
//  VMStateObserver.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/05.
//

import Foundation
import Virtualization

final public class VMStateObserver: ObservableObject {
    @Published public var runningVM: VZVirtualMachine?
}
