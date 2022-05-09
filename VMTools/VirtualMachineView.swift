//
//  VirtualMachineView.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/04.
//

import Foundation
import SwiftUI
import Virtualization

struct VirtualMachineView: NSViewRepresentable {
    var vm: VZVirtualMachine!
    
    func makeNSView(context: Context) -> NSView {
        let view = VZVirtualMachineView()
        view.virtualMachine = vm
        
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
