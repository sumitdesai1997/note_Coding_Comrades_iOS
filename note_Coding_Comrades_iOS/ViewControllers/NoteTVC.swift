//
//  NoteTVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 21/05/21.
//

import UIKit

class NoteTVC: UITableViewController {
    
    var noteList = [Note]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? = nil {
        didSet{
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return noteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNote", for: indexPath)
        cell.textLabel?.text = noteList[indexPath.row].title
        
        return cell
    }

}
