//
//  VMListView.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/06.
//

import SwiftUI

struct VMListView: View {
    let viewModel: VMListViewModel
    
    var body: some View {
        List(viewModel.avialableVMs) { vmBundle in
            VMListViewItem(viewModel: VMListViewItemViewModel(vmBundle: vmBundle))
                //.listRowBackground(Color.green.opacity(0.1))
        }
    }
}

struct VMListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = VMListViewModel()
        VMListView(viewModel: viewModel)
            .frame(width: 330, height: 300)
    }
}
