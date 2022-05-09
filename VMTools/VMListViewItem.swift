//
//  VMListViewItem.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/08.
//

import SwiftUI
import VMToolsShared

struct VMListViewItem: View {
    var title: String
    var vmIdentifier: String
    
    @State private var vmIsRunning = false
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Button {
                let vmBundle = VMBundle(name: "xcode-13-2-1", path: "/Users/rynaardburger/", osType: .macOS)
                let vmManager = VMManager.shared
                let vm = vmManager.initializeVM(vmBundle: vmBundle)!
                vmManager.strart(vm: vm.vzVirtualMachine!) { result in
                    vmIsRunning = true
                    VMToolsApp.openVMViewerWindow(vm: vm)
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
                    VMToolsApp.closeVMViewer()
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
        VMListViewItem(title: " macoS Test VM", vmIdentifier: "")
            .frame(width: 350, height: 50)
    }
}
