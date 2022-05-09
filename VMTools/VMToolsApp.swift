//
//  VMToolsApp.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/04.
//

import SwiftUI
import VMToolsShared
import Virtualization

@main
struct VMToolsApp: App {
    @StateObject var vmStateObserver: VMStateObserver = VMManager.shared.vmStateObserver
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    static let vmViewerWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                                         styleMask: [.titled, .closable, .resizable],
                                         backing: .buffered, defer: false)
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        //        WindowGroup("VM Viewer") {
        //            VMViewer()
        //                .environmentObject(vmStateObserver)
        //                .handlesExternalEvents(preferring: Set(arrayLiteral: "VMViewerWindow"), allowing: Set(arrayLiteral: "*"))
        //        }
        //        .handlesExternalEvents(matching: Set(arrayLiteral: "VMViewerWindow"))
    }
    
    static func openVMViewerWindow(vm: VM) {
        vmViewerWindow.contentView = NSHostingView(rootView: VMViewer(vm: vm.vzVirtualMachine!))
        vmViewerWindow.title = " " + vm.name
        vmViewerWindow.makeKeyAndOrderFront(nil)
    }
    
    static func closeVMViewer() {
        vmViewerWindow.close()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    func setupLocalMessagePort() {
        let messagePortHelper = MessagePortHelper()
        let port = (Bundle.main.bundleIdentifier ?? "")
        let localMessagePort = try! messagePortHelper.createLocal(port: port)
        
        let source = CFMessagePortCreateRunLoopSource(nil, localMessagePort, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupLocalMessagePort()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "rectangle.stack.badge.play", accessibilityDescription: "VMTools Button")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 330, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: VMListView())
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
