//
//  CommandMessageProcessor.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/07.
//

import Foundation

public struct CommandMessageProcessor {
    public static func sendMessage(_ message: CommandMessage) {
        guard let messageData = message.encode() else {
            print("Invalid command message.")
            return
        }
        
        let messagePortHelper = MessagePortHelper()
        let port = "com.rynaardburger.VMTools"
        let timeout = 10.0
        let endTime = CFAbsoluteTimeGetCurrent() + timeout
        
        // With this, the main app always needs to be running :(
        while endTime > CFAbsoluteTimeGetCurrent() {
            guard let localMessagePort = try! messagePortHelper.createRemote(port: port) else {
                NSLog("Wait for main application")
                usleep(100_000)
                continue
            }
            
            var unmanagedResponseData: Unmanaged<CFData>? = nil
            let status = messagePortHelper.sendRequest(messagePort: localMessagePort, data: messageData, unmanagedResponseData: &unmanagedResponseData, timeout: timeout)
            let cfData = unmanagedResponseData?.takeRetainedValue()
            
            if status == kCFMessagePortSuccess {
                if let responseData = cfData as Data?,
                   let responseString = String(data: responseData, encoding: .utf8) {
                    print(responseString)
                } else {
                    print("Unknown response received from application.")
                }
                break
            } else {
                print("Message Port Send Request failed with status: \(status)")
            }
        }
    }
    
    public static func readMessage(data: Data) -> CommandMessage? {
        return try? data.decoded() as CommandMessage
    }
}
