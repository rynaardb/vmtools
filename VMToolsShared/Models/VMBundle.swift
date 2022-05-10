//
//  VMBundle.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public enum VMOSType: String {
    case macOS = "macos"
    case linux = "linux"
}

public struct VMBundle: Identifiable {
    public let id = UUID()
    public let name: String
    let path: String
    let fullPath: URL
    let diskImagePath: URL
    let auxiliaryStorageURL: URL
    let machineIdentifierURL: URL
    let hardwareModelURL: URL
    let restoreImageURL: URL
    let osType: VMOSType
    
    public init(name: String, path: String, osType: VMOSType) {
        self.name = name
        self.path = path

        fullPath = URL(fileURLWithPath: path)
        
        diskImagePath = fullPath.appendingPathComponent("Disk.img")
        auxiliaryStorageURL = fullPath.appendingPathComponent("AuxiliaryStorage")
        machineIdentifierURL = fullPath.appendingPathComponent("MachineIdentifier")
        hardwareModelURL = fullPath.appendingPathComponent("HardwareModel")
        restoreImageURL = fullPath.appendingPathComponent("RestoreImage.ipsw")
        self.osType = osType
    }
}
