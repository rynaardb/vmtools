//
//  VMListViewModel.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/10.
//

import Foundation
import VMToolsShared

struct VMListViewModel {
    var avialableVMs: [VMBundle] {
        var vmBundles: [VMBundle] = []
        
        let fileManager = FileManager.default
        
        //let enumerator = fileManager.enumerator(atPath: UserDefaults.vmSearchPath)
        //let filePaths = enumerator?.allObjects as! [String]
        //let bundlePaths = filePaths.filter { $0.contains(".bundle") }
        
        let bundlesURL = URL(fileURLWithPath: UserDefaults.vmSearchPath)
        
        let bundlePaths = try! fileManager.contentsOfDirectory(at: bundlesURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsHiddenFiles)
        
        bundlePaths.forEach { bundleURL in
            let vmBundle = VMBundle(name: bundleURL.lastPathComponent, path: bundleURL.path, osType: .macOS)
            vmBundles.append(vmBundle)
        }
        
        return vmBundles
    }
}
