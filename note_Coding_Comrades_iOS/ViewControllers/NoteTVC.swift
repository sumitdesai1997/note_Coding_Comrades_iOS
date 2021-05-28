//
//  NoteTVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 21/05/21.
//

import UIKit
import CoreData

class NoteTVC: UITableViewController {
    
    var noteList = [Note]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // search bar object
    let searchBar = UISearchController(searchResultsController: nil)
    
    var selectedCategory : Category? = nil {
        didSet{
            fetchNotes()
        }
    }
    
    var selectedNote : Note? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNotes()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print("notelist: \(noteList.count)")
        return noteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNote", for: indexPath)
        cell.textLabel?.text = noteList[indexPath.row].title
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(note: noteList[indexPath.row])
            saveNotes()
            noteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = noteList[indexPath.row]
    }
    
    // fetching the notes from the core data
    func fetchNotes(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name=%@", selectedCategory!.name!)
        
        if let searchPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            noteList = try context.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    // deleting the note from the core data
    func deleteNote(note: Note) {
        context.delete(note)
    }
    
    // updating the note into core data
    func updateNote(title: String, details: String, image: Data, audio: Data, coordinateX: Double, coordinateY: Double, date: Date) {
        let newNote = Note(context: context)
        newNote.title = title
        newNote.details = details
        newNote.image = image
        newNote.audio = audio
        newNote.coordinateX = coordinateX
        newNote.coordinateY = coordinateY
        newNote.parentCategory = selectedCategory
        newNote.date = date
        
        saveNotes()
        noteList.append(newNote)
        fetchNotes()
    }
    
    // saving notes into core data
    func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func showSearchBar() {
        searchBar.searchBar.delegate = self
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Search"
        navigationItem.searchController = searchBar
        definesPresentationContext = true
        searchBar.searchBar.searchTextField.textColor = .black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nevc = segue.destination as! NoteEditVC
        nevc.delegate = self
        
        if let cell = sender as? UITableViewCell {
           if let index = tableView.indexPath(for: cell)?.row {
               nevc.selectedNote = noteList[index]
           }
       }
    }
    
    // sort functionality as per the user choice between title or date
    @IBAction func menuClick(_ sender: UIBarButtonItem) {
        let title = UIAction(title: " Sort by title"){ _ in
            print("title tapped")
            self.noteList = self.noteList.sorted(by: { (note1: Note, note2: Note) -> Bool in
                return note1.title! < note2.title!
            })
            self.tableView.reloadData()
        }
        let date = UIAction(title: " Sort by date"){ _ in
            self.noteList = self.noteList.sorted(by: { (note1: Note, note2: Note) -> Bool in
                return note1.date! > note2.date!
            })
            self.tableView.reloadData()
        }
        let menu = UIMenu(title: "Sort", children: [title, date])
        sender.menu = menu
    }

}

extension NoteTVC: UISearchBarDelegate{
        
    // method to search the products as per the user input after click on search button on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        fetchNotes(predicate: predicate)
    }
    
    // method for cancle button click near search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchNotes()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    // textDidChange method for search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
