//
//  VMListView.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/06.
//

import SwiftUI

struct VMListView: View {
    var body: some View {
        List {
            VMListViewItem(title: " xcode-13-2-1", vmIdentifier: "")
                .listRowBackground(Color.green.opacity(0.1))
            VMListViewItem(title: " xcode-13-3", vmIdentifier: "")
                .listRowBackground(Color.red.opacity(0.1))
            VMListViewItem(title: " xcode-13-3-1", vmIdentifier: "")
                .listRowBackground(Color.orange.opacity(0.1))
            VMListViewItem(title: " xcode-13-2", vmIdentifier: "")
                .listRowBackground(Color.red.opacity(0.1))
            VMListViewItem(title: " xcode-13-1", vmIdentifier: "")
                .listRowBackground(Color.red.opacity(0.1))
        }
        .listStyle(.sidebar)
    }
}

struct VMListView_Previews: PreviewProvider {
    static var previews: some View {
        VMListView()
            .frame(width: 330, height: 300)
    }
}
