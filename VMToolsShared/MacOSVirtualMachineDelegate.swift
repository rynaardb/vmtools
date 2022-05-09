//
//  MacOSVirtualMachineDelegate.swift
//  
//
//  Created by Rynaard Burger on 2022/05/02.
//

import Foundation
import Virtualization

class MacOSVirtualMachineDelegate: NSObject, VZVirtualMachineDelegate {
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        NSLog("Virtual machine did stop with error: \(error.localizedDescription)")
        //exit(-1)
    }

    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        NSLog("Guest did stop virtual machine.")
    }
}
