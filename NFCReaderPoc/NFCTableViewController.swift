//
//  NFCTableViewController.swift
//  NFCReaderPoc
//
//  Created by segev perets on 31/05/2023.
//

import UIKit
import CoreNFC

class NFCTableViewController: UITableViewController {

    let m = Model()
    var items = [Item]()
    var dataSource : UITableViewDiffableDataSource<Int,Item>!
    var session : NFCNDEFReaderSession?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        dataSourceSetup()
    }
    
    // MARK: DataSource
    private func dataSourceSetup () {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableRowIdentifier) else {fatalError()}
            
            var contentConfig = cell.defaultContentConfiguration()
            
            contentConfig.text = itemIdentifier.name
            
            cell.contentConfiguration = contentConfig
            
            return cell
        })
    }
    // MARK: Swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "🤯", handler: { [weak self] _, _, _ in
            guard let self else {return}
            self.items.remove(at: indexPath.row)
            self.updateSnapShot()
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // MARK: snapShot
    private func updateSnapShot () {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapShot.appendSections([0])
        snapShot.appendItems(items)
        dataSource.apply(snapShot)
    }
    
    // MARK: - buttons
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        present(Factory.textFieldAlertController(complition: { [weak self] text in
            guard let self else {return}
            self.items.append(Item(name: text))
            self.updateSnapShot()
            
        }), animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        var messages = [NFCNDEFMessage]()
        for item in items {
            messages.append(m.itemToMessage(item))
        }
 
        startSession()
    }
    
    @IBAction func readButtonPressed(_ sender: UIButton) {
        startSession()
    }
}
// MARK: - NFC functions
extension NFCTableViewController : NFCNDEFReaderSessionDelegate {

    
    private func startSession () {
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: true)
        session?.alertMessage = "Place the phone on a tag!"
        session?.begin()
        
    }
    
    // MARK: Failed
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        present(Factory.errorAlertController(error: error), animated: true)
        session.invalidate()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        let messagesString = m.readMessages(messages: messages)
        for string in messagesString {
            items.append(Item(name: string))
        }
        updateSnapShot()
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("active")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("writing")
        
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Can not write to more than one tag.")
            return
        }
        
        let tag = tags.first! //fetch first tag
        
        session.connect(to: tag) { [weak self] error in //connect to it
            guard let self else {return}
            if let error {
                self.present(Factory.errorAlertController(error: error), animated: true)
            }
        }
        
        //query for status and write
        tag.queryNDEFStatus { status, i, error in
            if let error {
                self.present(Factory.errorAlertController(error: error), animated: true)
            }
            switch status {
                
            case .notSupported,.readOnly:
                session.invalidate(errorMessage: "Not supported")
                
            case .readWrite:
                for item in self.items {
                    let message = self.m.itemToMessage(item)
                    tag.writeNDEF(message) { error in
                        if let error {
                            self.present(Factory.errorAlertController(error: error), animated: true)
                        }
                    }
                }


            @unknown default:
                fatalError()
            }
            
        }
        
        
    }
    
    
}
// MARK: - ravKav
//NFCISO7816Tag
//com.apple.developer.nfc.readersession.iso7816.select-identifiers
//00a4040008a000000003000000
//a000000003000000

