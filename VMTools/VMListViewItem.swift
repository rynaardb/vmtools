//
//  VMListViewItem.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/08.
//

import SwiftUI
import VMToolsShared

struct VMListViewItemViewModel {
    let vmBundle: VMBundle
}

struct VMListViewItem: View {
    var viewModel: VMListViewItemViewModel
    
    @State private var vmIsRunning = false
    
    let vmViewerWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                                         styleMask: [.titled, .closable, .resizable],
                                         backing: .buffered, defer: false)
    
    func openVMViewerWindow(vm: VM) {
        vmViewerWindow.contentView = NSHostingView(rootView: VMViewer(vm: vm.vzVirtualMachine!))
        vmViewerWindow.title = " " + vm.name
        vmViewerWindow.isReleasedWhenClosed = false
        vmViewerWindow.makeKeyAndOrderFront(nil)
    }
    
    func closeVMViewer() {
        vmViewerWindow.close()
    }
    
    var body: some View {
        HStack {
            Text(viewModel.vmBundle.name)
            
            Spacer()
            
            Button {
                let vmManager = VMManager.shared
                let vm = vmManager.initializeVM(vmBundle: viewModel.vmBundle)!
                vmManager.strart(vm: vm.vzVirtualMachine!) { result in
                    vmIsRunning = true
                    openVMViewerWindow(vm: vm)
                }
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.plain)
            .disabled(vmIsRunning)
            
            Button {
                
            } label: {
                Image(systemName: "pause.fill")
            }
            .buttonStyle(.plain)
            .disabled(!vmIsRunning)
            
            Button {
                VMManager.shared.stop(vm: VMManager.shared.vmStateObserver.runningVM!) { result in
                    vmIsRunning = false
                    closeVMViewer()
                }
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(.plain)
            .disabled(!vmIsRunning)
            
            Button {
                // open window
            } label: {
                Image(systemName: "macwindow")
            }
            .buttonStyle(.plain)
        }
        .padding(2)
    }
}

struct VMListViewItem_Previews: PreviewProvider {
    static var previews: some View {
        let vmBundle = VMBundle(name: "xcode-13-2-1", path: "/Users/rynaardburger/", osType: .macOS)
        let viewModel = VMListViewItemViewModel(vmBundle: vmBundle)
        
        VMListViewItem(viewModel: viewModel)
            .frame(width: 350, height: 50)
    }
}
