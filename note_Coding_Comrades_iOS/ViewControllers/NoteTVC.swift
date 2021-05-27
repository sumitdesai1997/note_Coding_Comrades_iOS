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
    
    var selectedCategory : Category? = nil {
        didSet{
            fetchNotes()
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
    
    // fetching the notes from the core data
    func fetchNotes(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentCategory.name=%@", selectedCategory!.name!)
        request.predicate = folderPredicate
        
        
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
    func updateNote(title: String, details: String, image: Data, audio: String, coordinateX: Double, coordinateY: Double, date: Date) {
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

}
