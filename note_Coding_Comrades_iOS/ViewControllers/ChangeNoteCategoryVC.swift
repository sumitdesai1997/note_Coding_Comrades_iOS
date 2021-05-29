//
//  ChangeNoteCategoryVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Eduardo Cardona on 2021-05-29.
//

import UIKit
import CoreData
class ChangeNoteCategoryVC: UIViewController {

    var otherCategories = [Category]()
    var selectedNotes: [Note]? {
        didSet {
            loadCategories()
        }
    }
    
    // context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - core data interaction methods
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // predicate
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?[0].parentCategory?.name ?? "")
        request.predicate = folderPredicate
        
        do {
            otherCategories = try context.fetch(request)
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
    }
    @IBAction func cancelReturn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ChangeNoteCategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = otherCategories[indexPath.row].name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(otherCategories[indexPath.row].name!)", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            for note in self.selectedNotes! {
                note.parentCategory = self.otherCategories[indexPath.row]
            }
            // dismiss the vc
            self.performSegue(withIdentifier: "dismissChangeNoteCategoryVC", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    
}
