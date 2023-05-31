//
//  Model.swift
//  NFCReaderPoc
//
//  Created by segev perets on 31/05/2023.
//

import UIKit
import CoreNFC

class Model {
    
    
    
    func readMessages (messages:[NFCNDEFMessage]) -> [String] {
        var strings = [String]()
        for message in messages {
            for record in message.records {
                let data = record.payload
                guard let s = String(data: data, encoding: .utf8) else {fatalError("Could not parse message")}
                strings.append(s)
            }
        }
        return strings
    }
    func createMessage (_ text:String) -> NFCNDEFMessage {
        
        let data = try! JSONEncoder().encode(text)
        
        let payload = NFCNDEFPayload(format: .unknown,type: Data(),identifier: Data(),payload: data)
        
        return NFCNDEFMessage(records: [payload])
    }
    
    func itemToMessage (_ item:Item) -> NFCNDEFMessage {
        return createMessage(item.name)
    }
    
    
    
    
    
}
