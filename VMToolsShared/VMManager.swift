//
//  VMManager.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/04.
//

import Foundation
import Virtualization

public struct VMOperationResult {
    enum OperationResult {
        case success
        case failure
    }
    
    let result: OperationResult
    let message: String
}

public class VMManager: NSObject {
    public static let shared = VMManager()
    public var vmStateObserver: VMStateObserver
    private var vmDelegate: MacOSVirtualMachineDelegate?

    private override init() {
        vmStateObserver = VMStateObserver()
    }
    
    public func initializeVM(vmBundle: VMBundle) -> VM? {
        let virtualMachineConfiguration = createVirtualMachineConfiguration(vmBundle: vmBundle)
        let vzVirtualMachine: VZVirtualMachine?
        
        do {
            try virtualMachineConfiguration.validate()
            vzVirtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        } catch {
            NSLog("VM configuration validation failed with error: \(error.localizedDescription)")
            return nil
        }
        
        let vm = VM(name: vmBundle.name, identifier: "TODO", vzVirtualMachine: vzVirtualMachine)
        
        return vm
    }
    
    public func strart(vm: VZVirtualMachine, completionHandler: @escaping (VMOperationResult) -> Void) {
        vmDelegate = MacOSVirtualMachineDelegate()
        vm.delegate = vmDelegate
        
        if vm.canStart {
            vm.start(completionHandler: { [self] result in
                switch result {
                case let .failure(error):
                    completionHandler(VMOperationResult(result: .failure, message: "VM failed to start with error: \(error.localizedDescription)."))
                    
                default:
                    completionHandler(VMOperationResult(result: .success, message: "VM successfully started."))
                    vmStateObserver.runningVM = vm
                }
            })
        }
    }
    
    public func stop(vm: VZVirtualMachine, completionHandler: @escaping (VMOperationResult) -> Void) {
        if vm.canStop {
            vm.stop { [self] error in
                if let error = error {
                    completionHandler(VMOperationResult(result: .failure, message: "VM failed to stop with error: \(error.localizedDescription)."))
                } else {
                    completionHandler(VMOperationResult(result: .success, message: "VM successfully stopped."))
                    vmStateObserver.runningVM = nil
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func createVirtualMachineConfiguration(vmBundle: VMBundle) -> VZVirtualMachineConfiguration {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        switch vmBundle.osType {
        case .macOS:
            virtualMachineConfiguration.platform = createMacPlaformConfiguration(vmBundle: vmBundle)
        case .linux:
            virtualMachineConfiguration.platform = createMacPlaformConfiguration(vmBundle: vmBundle)
        }
        
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImagePath: vmBundle.diskImagePath)]
        virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
        virtualMachineConfiguration.audioDevices = [MacOSVirtualMachineConfigurationHelper.createAudioDeviceConfiguration()]
        
        return virtualMachineConfiguration
    }
    
    private func createMacPlaformConfiguration(vmBundle: VMBundle) -> VZMacPlatformConfiguration {
        let macPlatform = VZMacPlatformConfiguration()

        let auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: vmBundle.auxiliaryStorageURL)
        macPlatform.auxiliaryStorage = auxiliaryStorage

        if !FileManager.default.fileExists(atPath: vmBundle.path) {
            fatalError("Missing Virtual Machine Bundle at \(vmBundle.path). Run InstallationTool first to create it.")
        }

        // Retrieve the hardware model; you should save this value to disk during installation.
        guard let hardwareModelData = try? Data(contentsOf: vmBundle.hardwareModelURL) else {
            fatalError("Failed to retrieve hardware model data.")
        }

        guard let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
            fatalError("Failed to create hardware model.")
        }

        if !hardwareModel.isSupported {
            fatalError("The hardware model is not supported on the current host")
        }
        macPlatform.hardwareModel = hardwareModel

        // Retrieve the machine identifier; you should save this value to disk during installation.
        guard let machineIdentifierData = try? Data(contentsOf: vmBundle.machineIdentifierURL) else {
            fatalError("Failed to retrieve machine identifier data.")
        }

        guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) else {
            fatalError("Failed to create machine identifier.")
        }
        macPlatform.machineIdentifier = machineIdentifier

        return macPlatform
    }
    
    private func createLinuxPlaformConfiguration() -> VZMacPlatformConfiguration? {
        return nil
    }
}
