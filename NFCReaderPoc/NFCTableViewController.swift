//
//  NFCTableViewController.swift
//  NFCReaderPoc
//
//  Created by segev perets on 31/05/2023.
//

import UIKit

class NFCTableViewController: UITableViewController {

    var items = [Item]()
    
    var dataSource : UITableViewDiffableDataSource<Int,Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        dataSourceSetup()
    }
    
    private func dataSourceSetup () {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reusableRowIdentifier) else {fatalError()}
            
            var contentConfig = cell.defaultContentConfiguration()
            
            contentConfig.text = itemIdentifier.name
            
            cell.contentConfiguration = contentConfig
            
            return cell
        })
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "🤯", handler: { [weak self] _, _, _ in
            guard let self else {return}
            self.items.remove(at: indexPath.row)
            self.updateSnapShot()
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    private func updateSnapShot () {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapShot.appendSections([0])
        snapShot.appendItems(items)
        dataSource.apply(snapShot)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        present(Factory.textFieldAlertController(complition: { [weak self] text in
            guard let self else {return}
            self.items.append(Item(name: text))
            self.updateSnapShot()
            
        }), animated: true)
    }
 
}
