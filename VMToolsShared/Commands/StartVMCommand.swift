//
//  StartVMCommand.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation
import AppKit

struct StartVMCommand: Command {
    let command: String
    let arguments: Dictionary<String, String>?
    let flags: [String]?
    
    func execute() -> String {
        guard let name = arguments?["name"],
              let path = arguments?["path"],
              let os = arguments?["os"],
              let osType = VMOSType(rawValue: os) else {
                  return "Missing required arguments"
              }
        
        let vmBundle = VMBundle(name: name, path: path, osType: osType)
        let vm = VMManager.shared.initializeVM(vmBundle: vmBundle)
        
        if let newVM = vm?.vzVirtualMachine, newVM.canStart, newVM.state == .stopped {
            VMManager.shared.strart(vm: newVM) { completion in
                NSLog(completion.message)
//                if let url = URL(string: "vmtools://VMViewerWindow") {
//                    NSWorkspace.shared.open(url)
//                }
            }
            
            return "VM started."
        } else {
            return "VM already started."
        }
    }
}
