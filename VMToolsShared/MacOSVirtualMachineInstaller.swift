//
//  MacOSVirtualMachineInstaller.swift
//  
//
//  Created by Rynaard Burger on 2022/05/02.
//

import Foundation
import Virtualization

public class MacOSVirtualMachineInstaller: NSObject {
    private var installationObserver: NSKeyValueObservation?
    private var virtualMachine: VZVirtualMachine!
    private var virtualMachineResponder: MacOSVirtualMachineDelegate?
    private var vmConfig: VMConfiguration
    private var vmBundle: VMBundle

    public required init(vmConfig: VMConfiguration, vmBundle: VMBundle) {
        self.vmConfig = vmConfig
        self.vmBundle = vmBundle
    }

    // Install macOS onto the Virtual Machine from IPSW
    public func installMacOS(ipswURL: URL) {
        NSLog("Creating VM bundle.")
        createVMBundle(path: vmBundle.fullPath)
        
        NSLog("Attempting to install from IPSW at \(ipswURL).")
        VZMacOSRestoreImage.load(from: ipswURL) { [self] result in
            switch result {
                case .failure(let error):
                    NSLog("Error: \(error.localizedDescription)")
                    
                case .success(let restoreImage):
                    installMacOS(restoreImage: restoreImage)
            }
        }
    }

    // MARK: - Private
    
    private func createVMBundle(path: URL) {
        let bundleFd = mkdir(vmBundle.fullPath.path, S_IRWXU | S_IRWXG | S_IRWXO)
        
        if bundleFd == -1 {
            if errno == EEXIST {
                fatalError("Failed to create VM.bundle: the base directory already exists.")
            }
            fatalError("Failed to create VM.bundle.")
        }

        let result = close(bundleFd)
        
        if result != 0 {
            fatalError("Failed to close VM.bundle.")
        }
    }
    
    private func installMacOS(restoreImage: VZMacOSRestoreImage) {
        NSLog("Installing MacOS")
        
        guard let macOSConfiguration = restoreImage.mostFeaturefulSupportedConfiguration else {
            fatalError("No supported configuration available.")
        }

        if !macOSConfiguration.hardwareModel.isSupported {
            fatalError("macOSConfiguration configuration is not supported on the current host.")
        }

        setupVirtualMachine(macOSConfiguration: macOSConfiguration)
        
        startInstallation(restoreImageURL: restoreImage.url)
    }

    private func createMacPlatformConfiguration(macOSConfiguration: VZMacOSConfigurationRequirements) -> VZMacPlatformConfiguration {
        let macPlatformConfiguration = VZMacPlatformConfiguration()

        guard let auxiliaryStorage = try? VZMacAuxiliaryStorage(creatingStorageAt: vmBundle.auxiliaryStorageURL,
                                                                    hardwareModel: macOSConfiguration.hardwareModel,
                                                                          options: []) else {
            fatalError("Failed to create auxiliary storage.")
        }
        macPlatformConfiguration.auxiliaryStorage = auxiliaryStorage
        macPlatformConfiguration.hardwareModel = macOSConfiguration.hardwareModel
        macPlatformConfiguration.machineIdentifier = VZMacMachineIdentifier()

        // Store the hardware model and machine identifier to disk so that we can retrieve them for subsequent boots.
        try! macPlatformConfiguration.hardwareModel.dataRepresentation.write(to: vmBundle.hardwareModelURL)
        try! macPlatformConfiguration.machineIdentifier.dataRepresentation.write(to: vmBundle.machineIdentifierURL)

        return macPlatformConfiguration
    }

    // MARK: Create the Virtual Machine Configuration and instantiate the Virtual Machine
    private func setupVirtualMachine(macOSConfiguration: VZMacOSConfigurationRequirements) {
        NSLog("Setting up VM")
        
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        virtualMachineConfiguration.platform = createMacPlatformConfiguration(macOSConfiguration: macOSConfiguration)
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        
        if virtualMachineConfiguration.cpuCount < macOSConfiguration.minimumSupportedCPUCount {
            fatalError("CPUCount is not supported by the macOS configuration.")
        }

        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        
        if virtualMachineConfiguration.memorySize < macOSConfiguration.minimumSupportedMemorySize {
            fatalError("memorySize is not supported by the macOS configuration.")
        }

        // Create a 64 GB disk image.
        createDiskImage()

        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration()]
        virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImagePath: vmBundle.diskImagePath)]
        virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
        virtualMachineConfiguration.audioDevices = [MacOSVirtualMachineConfigurationHelper.createAudioDeviceConfiguration()]

        try! virtualMachineConfiguration.validate()

        virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
        virtualMachineResponder = MacOSVirtualMachineDelegate()
        virtualMachine.delegate = virtualMachineResponder
    }
    
    // Create an empty disk image for the Virtual Machine
    private func createDiskImage() {
        let diskFd = open(vmBundle.diskImagePath.path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)
        
        if diskFd == -1 {
            fatalError("Cannot create disk image.")
        }

        // 64GB disk space.
        var result = ftruncate(diskFd, 64 * 1024 * 1024 * 1024)
        
        if result != 0 {
            fatalError("ftruncate() failed.")
        }

        result = close(diskFd)
        
        if result != 0 {
            fatalError("Failed to close the disk image.")
        }
    }

    private func startInstallation(restoreImageURL: URL) {
        DispatchQueue.main.async { [self] in
            let installer = VZMacOSInstaller(virtualMachine: virtualMachine, restoringFromImageAt: restoreImageURL)

            NSLog("Starting installation.")
            installer.install(completionHandler: { (result: Result<Void, Error>) in
                if case let .failure(error) = result {
                    fatalError(error.localizedDescription)
                } else {
                    NSLog("Installation succeeded.")
                }
            })

            // Observe installation progress
            installationObserver = installer.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
                NSLog("Installation progress: \(change.newValue! * 100).")
            }
        }
    }
}
