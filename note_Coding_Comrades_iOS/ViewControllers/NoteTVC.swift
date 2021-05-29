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
    
    var currentPredicate : NSPredicate? = nil
    var ascendingSort = true
    var sortingType = "date"
    
    var selectMode = false
    
    var selectedCategory : Category? = nil {
        didSet{
            navigationItem.title = selectedCategory?.name
            fetchNotes()
        }
    }
    @IBOutlet weak var changeCategoryBtn: UIBarButtonItem!
    
    @IBOutlet weak var deleteNotesBtn: UIBarButtonItem!
    var selectedNote : Note? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        menuSet()
        showSearchBar()
        // longpress gesture on tableview
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressCell))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
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
        let formatter1 = DateFormatter()
        formatter1.dateFormat  = "E, d MMM y HH:mm "
        
        cell.detailTextLabel?.text = formatter1.string(from: noteList[indexPath.row].date!)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(note: noteList[indexPath.row])
            saveNotes()
            noteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = noteList[indexPath.row]
    }
    
    @objc func handleLongPressCell(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Quick title edit", message: "Please set a title for the note", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Accept", style: .default) { (action) in
                let notesTitles = self.noteList.filter({$0.title?.lowercased() != self.noteList[indexPath!.row].title!.lowercased()}).map({$0.title?.lowercased()})
                guard textField.text != "" else {return self.showAlert(title: "Empty field", message: "Not able to edit the category")}
                guard !notesTitles.contains(textField.text?.lowercased()) else {return self.showAlert(title: "Title Taken", message: "Please choose another title")}
                self.noteList[indexPath!.row].title = textField.text!
                self.saveNotes()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            // change the color of the cancel button action
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            alert.addTextField { (field) in
                textField = field
                textField.placeholder = "Note Title"
                textField.text = self.noteList[indexPath!.row].title
            }
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // show alert when the title of the note is taken
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // fetching the notes from the core data
    func fetchNotes(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name=%@", selectedCategory!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: sortingType , ascending: ascendingSort)]

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
            tableView.reloadData()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func showSearchBar() {
        searchBar.searchBar.delegate = self
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Search note by name"
        navigationItem.searchController = searchBar
        definesPresentationContext = true
        searchBar.searchBar.searchTextField.textColor = .black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nevc = segue.destination as? NoteEditVC {
            nevc.delegate = self
            
            if let cell = sender as? UITableViewCell {
               if let index = tableView.indexPath(for: cell)?.row {
                   nevc.selectedNote = noteList[index]
               }
           }
        }
        
        if let destination = segue.destination as? ChangeNoteCategoryVC {
            if let index = tableView.indexPathsForSelectedRows {
                let rows = index.map {$0.row}
                destination.selectedNotes = rows.map {noteList[$0]}
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "changeNotesCategory" else {
            return true
        }
        return selectMode ? false : true
    }
    
    
    func menuSet(){
        let title = UIAction(title: "Sort by title" , image: UIImage(systemName: "textformat.abc")){ element in
            self.sortingType = "title"
            
            self.fetchNotes(predicate: self.currentPredicate)
        }
        let date = UIAction(title: "Sort by date" , image: UIImage(systemName: "calendar")){ element in
            self.sortingType = "date"
            self.fetchNotes(predicate: self.currentPredicate)
        }
        let menuSort = UIMenu(title: "Sort" , image: UIImage(systemName: "list.bullet")  ,children: [title, date] )
        
        let select = UIAction(title: "Toggle Selection" , image: UIImage(systemName: "square.and.pencil") ){ _ in
            
            
            self.changeCategoryBtn.isEnabled = !self.changeCategoryBtn.isEnabled
            self.deleteNotesBtn.isEnabled = !self.deleteNotesBtn.isEnabled
            self.selectMode = !self.selectMode
            
            self.tableView.setEditing(self.selectMode, animated: true)
            
            
        }
        let create = UIAction(title: "Create note", image: UIImage(systemName: "note.text.badge.plus")){ _ in
            self.performSegue(withIdentifier: "toCreateNote", sender: self)
        }
        
        let menuEdit = UIMenu( title: "Edit Options", children: [create, select , menuSort])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menuEdit)
    }

    //MARK: - Action methods
    
    @IBAction func changeCategoryClick(_ sender: Any) {
        
    }
    /// trash bar button functionality
    /// - Parameter sender: bar button
    @IBAction func deleteNotes(_ sender: Any) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            
            let _ = rows.map {deleteNote(note: noteList[$0])}
            let _ = rows.map {noteList.remove(at: $0)}
            
            tableView.reloadData()
            saveNotes()
        }
    }
    
    
    // shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        ascendingSort = !ascendingSort
        fetchNotes(predicate: currentPredicate)
    }
    
    // dismiss modal for changing category
    @IBAction func unwindToNoteTVC(_ unwindSegue: UIStoryboardSegue) {
        saveNotes()
        fetchNotes()
        tableView.setEditing(false, animated: true)
    }

}

extension NoteTVC: UISearchBarDelegate{
        
    // method to search the products as per the user input after click on search button on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        currentPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        fetchNotes(predicate: currentPredicate)
    }
    
    // method for cancle button click near search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchNotes()
        currentPredicate = nil
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    // textDidChange method for search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchNotes()
            currentPredicate = nil
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
