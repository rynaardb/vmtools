//
//  StopVMCommand.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

struct StopVMCommand: Command {
    let command: String
    let arguments: Dictionary<String, String>?
    let flags: [String]?
    
    func execute() -> String {
//        guard let name = arguments?["name"],
//              let path = arguments?["path"] else {
//                  return "Missing required arguments"
//              }
        
        let vm = VMManager.shared.vmStateObserver.runningVM
        
        if let runningVM = vm, runningVM.canStop, runningVM.state == .running {
            VMManager.shared.stop(vm: runningVM) { completion in
                NSLog(completion.message)
            }
            
            return "VM Stopped"
        } else {
            return "VM already stopped."
        }
    }
}
