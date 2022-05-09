//
//  VMViewer.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/04.
//

import SwiftUI
import VMToolsShared
import Virtualization

struct VMViewer: View {
    //@EnvironmentObject var vmStateObserver: VMStateObserver
    let vm: VZVirtualMachine?
    
    var body: some View {
        VStack {
            Spacer()
            //VirtualMachineView(vm: vmStateObserver.runningVM)
            VirtualMachineView(vm: vm)
            Spacer()
        }
    }
}

struct VMViewer_Previews: PreviewProvider {
    static var previews: some View {
        VMViewer(vm: nil)
    }
}
