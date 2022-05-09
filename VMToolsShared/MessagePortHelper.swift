//
//  MessagePortHelper.swift
//  VMToolsShared
//
//  Created by Rynaard Burger on 2022/05/05.
//

import Foundation
import CoreVideo

extension Data {
    func decoded<T: Codable>(using decoder: JSONDecoder = .init()) throws -> T {
        return try decoder.decode(T.self, from: self)
    }
}

struct MessagePortError: Error {
    enum MessagePortErrorType {
        case createLocal
        case createRemote
    }
    
    let errorType: MessagePortErrorType
    let message: String
}

// TODO: Rename to MachPortsHelper
public class MessagePortHelper: NSObject {
    func callbackFunc(messagePort: CFMessagePort?,
                      messageID: Int32,
                      cfData: CFData?,
                      info: UnsafeMutableRawPointer?) -> Unmanaged<CFData>? {
        return Unmanaged.passRetained(Data("function callback".utf8) as CFData);
    }
    
    private lazy var callback: CFMessagePortCallBack = { messagePort, messageID, cfData, info in
        guard let pointer = info,
              let messageData = cfData as Data? else {
                  return nil
              }
        
        guard let commandMessage = try? messageData.decoded() as CommandMessage else {
            return nil
        }
        
        var returnMessage = ""
        
        switch KnownCommands(rawValue:commandMessage.command) {
        case .createVM:
            returnMessage = CommandFactory.create(.createVM, message: commandMessage).execute()
        case .startVM:
            returnMessage = CommandFactory.create(.startVM, message: commandMessage).execute()
        case .stopVM:
            returnMessage = CommandFactory.create(.stopVM, message: commandMessage).execute()
        case .none:
            returnMessage = "Not a known command"
        }
        
        let dataToSend = Data(returnMessage.utf8)
        
        return Unmanaged.passRetained(dataToSend as CFData)
    }
    
    public func createLocal(port: String) throws -> CFMessagePort? {
        let info = Unmanaged.passUnretained(self).toOpaque()
        var context = CFMessagePortContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        
        guard let messagePort = CFMessagePortCreateLocal(nil, port as CFString, callback, &context, nil) else {
            throw MessagePortError(errorType: .createLocal, message: "Unable to create Local Message Port.")
        }
        
        return messagePort
    }
    
    public func createRemote(port: String) throws -> CFMessagePort? {
        guard let messagePort = CFMessagePortCreateRemote(nil, port as CFString) else {
            throw MessagePortError(errorType: .createRemote, message: "Unable to create Remote Message Port.")
        }
        
        return messagePort
    }
    
    // TODO: Make sure this unmanagedResponseData: inout Unmanaged<CFData>? works
    public func sendRequest(messagePort: CFMessagePort,
                            data: Data,
                            unmanagedResponseData: inout Unmanaged<CFData>?,
                            timeout: Double) -> Int32 {
        return CFMessagePortSendRequest(messagePort, 0, data as CFData, timeout, timeout, CFRunLoopMode.defaultMode.rawValue, &unmanagedResponseData)
    }
}
