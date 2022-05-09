//
//  MacOSRestoreImage.swift
//  
//
//  Created by Rynaard Burger on 2022/05/02.
//

import Foundation
import Virtualization

public class MacOSRestoreImage: NSObject {
    private var downloadObserver: NSKeyValueObservation?
    private var ipswDownloadPath = URL(fileURLWithPath: "/tmp/RestoreImage.ipsw")

    // MARK: Observe the download progress
    public func download(completionHandler: @escaping () -> Void) {
        NSLog("Attempting to download latest available restore image.")
        VZMacOSRestoreImage.fetchLatestSupported { [self](result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
                case let .failure(error):
                    fatalError(error.localizedDescription)

                case let .success(restoreImage):
                    downloadRestoreImage(restoreImage: restoreImage, completionHandler: completionHandler)
            }
        }
    }

    // MARK: - Private
    
    private func downloadRestoreImage(restoreImage: VZMacOSRestoreImage, completionHandler: @escaping () -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: restoreImage.url) { [self] localURL, response, error in
            if let error = error {
                fatalError("Download failed. \(error.localizedDescription).")
            }

            guard (try? FileManager.default.moveItem(at: localURL!, to: ipswDownloadPath)) != nil else {
                fatalError("Failed to move downloaded restore image to \(ipswDownloadPath).")
            }

            completionHandler()
        }

        downloadObserver = downloadTask.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            NSLog("Restore image download progress: \(change.newValue! * 100).")
        }
        downloadTask.resume()
    }
}
