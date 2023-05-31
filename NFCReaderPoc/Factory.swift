//
//  Factory.swift
//  NFCReaderPoc
//
//  Created by segev perets on 31/05/2023.
//

import UIKit

struct Factory {
    
    private init () {}
    
    static func textFieldAlertController (complition: @escaping (String)->Void) -> UIAlertController {
        
        let alert = UIAlertController(title: "Write Somting", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "DONE", style: .default,handler: { _ in
            guard let text = alert.textFields![0].text else {fatalError()}
            complition(text)
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        return alert
    }
    
    
}
