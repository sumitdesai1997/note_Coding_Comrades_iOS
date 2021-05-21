//
//  CategoryTVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 21/05/21.
//

import UIKit

class CategoryTVC: UITableViewController {

    // creating a category list array to store the categories
    var categoryList = [Category]()
    
    // creating context object to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // reloading the table data just before screen appear
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
        return categoryList.count
    }
    
    // method to define the cell and prepare for value for elements inside the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath)
                
        cell.textLabel?.text = categoryList[indexPath.row].name
        return cell
    }
    
    // creating method for new category addition
    @IBAction func createCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create new category", message: "please give a name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let categoryNames = self.categoryList.map {$0.name?.lowercased()}
            guard !categoryNames.contains(textField.text?.lowercased()) else {return}
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryList.append(newCategory)
            self.saveCategory()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // change the color of the cancel button action
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "folder name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // saving data to context
    func saveCategory() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the folder \(error.localizedDescription)")
        }
    }

}
