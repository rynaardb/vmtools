//
//  CreateVMCommand.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

struct CreateVMCommand: Command {
    let command: String
    let arguments: Dictionary<String, String>?
    let flags: [String]?
    
    func execute() -> String {
        let vmConfig = VMConfiguration(cpu: 4, memory: 4096, disk: 68719476736)
        
        guard let name = arguments?["name"],
              let path = arguments?["path"],
              let os = arguments?["os"],
              let osType = VMOSType(rawValue: os),
              let restoreImage = arguments?["image"] else {
                  return "Missing required arguments"
              }
        
        let vmBundle = VMBundle(name: name, path: path, osType: osType)
        let installer = MacOSVirtualMachineInstaller(vmConfig: vmConfig, vmBundle: vmBundle)
        
        switch osType {
        case .macOS:
            // Install from an existing restore image
            installer.installMacOS(ipswURL: URL(fileURLWithPath: restoreImage))
        case .linux:
            return ("OS not yet supported")
        }
        
        return "VM created."
    }
}
