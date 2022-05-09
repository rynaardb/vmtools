//
//  main.swift
//  VMToolsCLI
//
//  Created by Rynaard Burger on 2022/05/04.
//

import Foundation
import ArgumentParser
import VMToolsShared

struct VMToolsCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Tools to create, provision, and manage VMs on Apple Silicon Macs.",
        version: "1.0.0",
        subcommands: [Create.self, Validate.self, Provision.self, Start.self, Stop.self]
    )
    
    init() { }
}

struct Create: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Create a new VM bundle with macOS installed.")
    
    @Option(name: .shortAndLong, help: "The name of the VM bundle.")
    private var name: String
    
    @Option(name: .shortAndLong, help: "The path where the VM bundle will be created.")
    private var path: String
    
    @Option(name: .shortAndLong, help: "The OS that will be installed (macos, linux).")
    private var os: String
    
    @Option(name: .shortAndLong, help: "Restore image.")
    private var image: String
    
    @Flag(name: .shortAndLong, help: "Show verbose logging output.")
    private var verbose: Bool = false
    
    func run() throws {
        let commandMessage = CommandMessage(command: "create",
                                            arguments: ["name": name,
                                                        "path": path,
                                                        "os": os,
                                                        "image": image],
                                            flags: nil)
        
        CommandMessageProcessor.sendMessage(commandMessage)
        //dispatchMain()
    }
}

struct Validate: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Validate a VM bundle.")
    
    func run() throws {
    }
}

struct Provision: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Provisiong a VM.")
    
    func run() throws {
    }
}

struct Start: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Start a VM.")
    
    @Option(name: .shortAndLong, help: "The name of the VM bundle.")
    private var name: String
    
    @Option(name: .shortAndLong, help: "The path of the VM bundle.")
    private var path: String
    
    @Option(name: .shortAndLong, help: "The OS that will be installed. Valid options: macos, linux")
    private var os: String
    
    func run() throws {
        
        let commandMessage = CommandMessage(command: "start",
                                            arguments: ["name": name,
                                                        "path": path,
                                                        "os": os],
                                            flags: nil)
        
        CommandMessageProcessor.sendMessage(commandMessage)
        //dispatchMain()
    }
}

struct Stop: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Stop a VM.")
    
    @Option(name: .shortAndLong, help: "The name of the VM bundle.")
    private var name: String
    
    @Option(name: .shortAndLong, help: "The path of the VM bundle.")
    private var path: String
    
    func run() throws {
        let commandMessage = CommandMessage(command: "stop",
                                            arguments: ["name": name,
                                                        "path": path],
                                            flags: nil)
        
        CommandMessageProcessor.sendMessage(commandMessage)
        //dispatchMain()
    }
}

VMToolsCLI.main()

