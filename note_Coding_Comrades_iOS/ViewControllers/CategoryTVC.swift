//
//  CategoryTVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 21/05/21.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {

    // creating a category list array to store the categories
    var categoryList = [Category]()
    var isEditable = false
    
    let categorySearchBar = UISearchController(searchResultsController: nil)

    // creating context object to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // reloading the table data just before screen appear
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCategorySearchBar()
        fetchCategoryList()
        // longpress gesture on tableview
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressCell))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 22)
        
        cell.detailTextLabel?.text = String(categoryList[indexPath.row].notes!.count)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 22)
        cell.detailTextLabel?.textColor = .lightGray
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteCategory(category: categoryList[indexPath.row])
            saveCategory    ()
            categoryList.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @objc func handleLongPressCell(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Rename category", message: "please set a name", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Accept", style: .default) { (action) in
                let categoryNames = self.categoryList.map({$0.name?.lowercased()}).filter({$0 != self.categoryList[indexPath!.row].name!.lowercased()})
                guard textField.text != "" else {return self.showAlert(title: "Empty field", message: "Not able to edit the category name")}
                guard !categoryNames.contains(textField.text?.lowercased()) else {return self.showAlert(title: "Name Taken", message: "Please choose another name")}
                
                self.categoryList[indexPath!.row].name = textField.text!
                self.saveCategory()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            // change the color of the cancel button action
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            alert.addTextField { (field) in
                textField = field
                textField.placeholder = "Category name"
                textField.text = self.categoryList[indexPath!.row].name
            }
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func createCategory(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create new category", message: "Please give a name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let categoryNames = self.categoryList.map {$0.name?.lowercased()}
            guard textField.text != "" else {return self.showAlert(title: "Empty field", message: "Not able to create the category")}
            guard !categoryNames.contains(textField.text?.lowercased()) else {return self.showAlert(title: "Name Taken", message: "Please choose another name")}
            
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
            textField.placeholder = "Category name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // show alert when the name of the category is taken
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // to provide the edit funationality
    @IBAction func toggleEditable(_ sender: Any) {
        isEditable = !isEditable
        tableView.setEditing(isEditable, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // loading from from core data
    func fetchCategoryList(categoryPredicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        if let searchPredicate = categoryPredicate {
            request.predicate = searchPredicate
        } else {
            
        }
        
        do {
            categoryList = try context.fetch(request)
        } catch {
            print("Error loading category list \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    // saving data to context
    func saveCategory() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the category \(error.localizedDescription)")
        }
    }
    
    // delete from core data
    func deleteCategory(category: Category) {
        context.delete(category)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let ntvc = segue.destination as! NoteTVC
        if let indexPath = tableView.indexPathForSelectedRow {
            ntvc.selectedCategory = categoryList[indexPath.row]
        }
    }
    
    func showCategorySearchBar() {
        
        categorySearchBar.searchBar.delegate = self
        categorySearchBar.obscuresBackgroundDuringPresentation = false
        categorySearchBar.searchBar.placeholder = "Search category by name"
        navigationItem.searchController = categorySearchBar
        definesPresentationContext = true
        categorySearchBar.searchBar.searchTextField.textColor = .black
    }

}

extension CategoryTVC: UISearchBarDelegate{
        
    // method to search the products as per the user input after click on search button on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        fetchCategoryList(categoryPredicate: predicate)
    }
    
    // method for cancle button click near search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchCategoryList()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    // textDidChange method for search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchCategoryList()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
